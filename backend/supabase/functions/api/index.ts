// Single authenticated API edge function.
//
// Pattern: every product endpoint here delegates to a Postgres `api_*`
// RPC. Tables are RLS-locked and inaccessible to `anon` / `authenticated`
// — all writes go through SECURITY DEFINER functions so business rules
// stay in one place.
//
// Add new routes by:
//   1. creating a SQL migration with `api_<verb_resource>(p_user_id, …)`,
//   2. wiring a tiny `handleX(req, userId)` helper here that calls `rpc`,
//   3. routing it from the `Deno.serve` switch below.
import { handleCors } from '../_shared/cors.ts';
import { requireUser } from '../_shared/auth.ts';
import { getAdminClient } from '../_shared/db.ts';
import { requiredEnv } from '../_shared/env.ts';
import {
  isProEntitlementId,
  resolveProEntitlementIdsFromEnv,
} from '../_shared/revenuecat_entitlements.ts';
import {
  ApiHttpError,
  type ApiErrorCode,
  fromError,
  ok,
} from '../_shared/responses.ts';
import {
  deleteMyAccountSchema,
  parseJsonBody,
  profileUpdateSchema,
} from '../_shared/validation.ts';

type ProfileRow = {
  user_id: string;
  email: string;
  display_name: string | null;
  avatar_url: string | null;
  locale: string;
  plan: 'free' | 'pro';
  revenuecat_app_user_id: string | null;
  created_at: string;
  updated_at: string;
};

type MePayload = { profile: ProfileRow };

const PRO_ENTITLEMENT_IDS = resolveProEntitlementIdsFromEnv();

function routePath(req: Request): string {
  const url = new URL(req.url);
  const parts = url.pathname.split('/').filter(Boolean);
  const apiIndex = parts.indexOf('api');
  const routeParts = apiIndex >= 0 ? parts.slice(apiIndex + 1) : parts;
  return `/${routeParts.join('/')}`;
}

function parseDbError(error: unknown): ApiHttpError {
  if (
    typeof error === 'object'
    && error !== null
    && 'message' in error
    && typeof (error as { message: unknown }).message === 'string'
  ) {
    const message = (error as { message: string }).message;
    const match = message.match(/^([A-Z_]+):\s*(.+)$/);
    if (match) {
      const code = match[1] as ApiErrorCode;
      const detail = match[2];
      switch (code) {
        case 'VALIDATION_ERROR':
          return new ApiHttpError(400, code, detail);
        case 'UNAUTHORIZED':
          return new ApiHttpError(401, code, detail);
        case 'FORBIDDEN':
          return new ApiHttpError(403, code, detail);
        case 'NOT_FOUND':
          return new ApiHttpError(404, code, detail);
        case 'CONFLICT':
          return new ApiHttpError(409, code, detail);
        case 'RATE_LIMITED':
          return new ApiHttpError(429, code, detail);
        case 'EXTERNAL_API_ERROR':
          return new ApiHttpError(502, code, detail);
        default:
          return new ApiHttpError(500, 'INTERNAL_ERROR', detail);
      }
    }
    return new ApiHttpError(500, 'INTERNAL_ERROR', message);
  }
  return new ApiHttpError(500, 'INTERNAL_ERROR', 'Unknown database error');
}

async function rpc<T>(fn: string, params: Record<string, unknown>): Promise<T> {
  const db = getAdminClient();
  const { data, error } = await db.rpc(fn, params);
  if (error) {
    throw parseDbError(error);
  }
  return data as T;
}

function handleHealth(userId: string): Response {
  return ok({
    status: 'ok',
    user_id: userId,
    timestamp: new Date().toISOString(),
  });
}

async function handleGetMe(userId: string): Promise<Response> {
  const data = await rpc<MePayload>('api_get_me', { p_user_id: userId });
  return ok(data);
}

async function handleProfileUpdate(req: Request, userId: string): Promise<Response> {
  const body = await parseJsonBody(req, profileUpdateSchema);
  const data = await rpc<MePayload>('api_profile_update', {
    p_user_id: userId,
    p_display_name: body.displayName ?? null,
    p_avatar_url: body.avatarUrl ?? null,
    p_locale: body.locale ?? null,
  });
  return ok(data);
}

async function handleDeleteMyAccount(req: Request, userId: string): Promise<Response> {
  await parseJsonBody(req, deleteMyAccountSchema);
  const db = getAdminClient();
  const { error } = await db.auth.admin.deleteUser(userId, true);
  if (error) {
    throw new ApiHttpError(500, 'INTERNAL_ERROR', 'Failed to delete auth user', error);
  }
  return ok({ deleted: true });
}

async function handleRevenuecatRefresh(userId: string): Promise<Response> {
  const apiKey = requiredEnv('REVENUECAT_API_KEY');
  const me = await rpc<MePayload>('api_get_me', { p_user_id: userId });
  const appUserId = me.profile.revenuecat_app_user_id ?? userId;

  const response = await fetch(
    `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(appUserId)}`,
    {
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
    },
  );

  if (!response.ok) {
    const details = await response.text().catch(() => '');
    throw new ApiHttpError(502, 'EXTERNAL_API_ERROR', 'RevenueCat refresh request failed', {
      status: response.status,
      details,
    });
  }

  const payload = (await response.json()) as Record<string, unknown>;
  const subscriber = payload.subscriber as Record<string, unknown> | undefined;
  const entitlements = (subscriber?.entitlements ?? {}) as Record<
    string,
    { expires_date?: string | null } | undefined
  >;

  const now = Date.now();
  const isPro = Object.entries(entitlements).some(([entitlementId, entitlement]) => {
    if (!isProEntitlementId(entitlementId, PRO_ENTITLEMENT_IDS)) return false;
    if (!entitlement) return false;
    const expiresAt = entitlement.expires_date;
    if (!expiresAt) return true;
    const expiresMs = new Date(expiresAt).getTime();
    return Number.isFinite(expiresMs) && expiresMs > now;
  });

  const externalId = `refresh:${appUserId}:${new Date().toISOString()}`;
  const sync = await rpc<unknown>('api_apply_revenuecat_event', {
    p_source: 'revenuecat_refresh',
    p_external_id: externalId,
    p_app_user_id: appUserId,
    p_payload: payload,
    p_is_pro: isPro,
  });

  return ok({ appUserId, isPro, sync });
}

Deno.serve(async (req) => {
  const startedAt = Date.now();
  const cors = handleCors(req);
  if (cors) return cors;

  const path = routePath(req);
  const method = req.method.toUpperCase();

  try {
    const user = await requireUser(req);
    const userId = user.id;

    let response: Response;
    if (method === 'GET' && path === '/health') {
      response = handleHealth(userId);
    } else if (method === 'GET' && path === '/me') {
      response = await handleGetMe(userId);
    } else if (method === 'POST' && path === '/profile/update') {
      response = await handleProfileUpdate(req, userId);
    } else if (method === 'POST' && path === '/delete_my_account') {
      response = await handleDeleteMyAccount(req, userId);
    } else if (method === 'POST' && path === '/revenuecat/refresh') {
      response = await handleRevenuecatRefresh(userId);
    } else {
      throw new ApiHttpError(404, 'NOT_FOUND', 'Route not found');
    }

    console.log(
      JSON.stringify({
        function: 'api',
        user_id: userId,
        method,
        path,
        status: response.status,
        duration_ms: Date.now() - startedAt,
      }),
    );
    return response;
  } catch (error) {
    const failure = fromError(error);
    console.error(
      JSON.stringify({
        function: 'api',
        method,
        path,
        status: failure.status,
        error: error instanceof Error ? error.message : 'unknown_error',
        duration_ms: Date.now() - startedAt,
      }),
    );
    return failure;
  }
});
