# API surface

The single source of truth for what the backend exposes. Add a row
here whenever a new edge function route lands; remove rows when the
backend stops serving a route.

## Conventions

- Base URL: `https://<project-ref>.supabase.co/functions/v1/api`.
- Authentication: every route requires a valid Supabase JWT in the
  `Authorization: Bearer <token>` header (see `config.toml`).
  The only exception is the public `revenuecat_webhook` function,
  guarded by a shared secret instead of a JWT.
- Envelope: every response uses
  `{ ok: true, data, meta? }` or
  `{ ok: false, error: { code, message, details? } }`.
- Error codes the backend emits today: `UNAUTHORIZED`, `FORBIDDEN`,
  `NOT_FOUND`, `VALIDATION_ERROR`, `CONFLICT`, `RATE_LIMITED`,
  `EXTERNAL_API_ERROR`, `INTERNAL_ERROR`. Clients switch on these
  strings, never on `message`.

## Routes

| Method | Path                       | Body / query                                     | Returns                       | Notes |
| ------ | -------------------------- | ------------------------------------------------ | ----------------------------- | ----- |
| GET    | `/health`                  | —                                                | `{ status, user_id, timestamp }` | Smoke test. |
| GET    | `/me`                      | —                                                | `{ profile }`                 | Reads `public.profiles` for the JWT user. Profile row is auto-created by the `handle_new_user` trigger. |
| POST   | `/profile/update`          | `{ displayName?, avatarUrl?, locale? }`          | `{ profile }`                 | Partial PATCH; nulls/missing fields are ignored. Validates URL/length per `_shared/validation.ts`. |
| POST   | `/delete_my_account`       | `{ confirm: true }`                              | `{ deleted: true }`           | Calls `auth.admin.deleteUser`; cascade deletes the profile via FK. |
| POST   | `/revenuecat/refresh`      | —                                                | `{ appUserId, isPro, sync }`  | Pulls the latest entitlements from the RevenueCat REST API and writes the resulting plan back via `api_apply_revenuecat_event`. |

## Public routes (no JWT)

| Method | Function                   | Auth                                              | Notes |
| ------ | -------------------------- | ------------------------------------------------- | ----- |
| POST   | `revenuecat_webhook`       | Shared secret in `Authorization: Bearer <…>`      | Receives RevenueCat webhook events, idempotency via `webhook_events(source, external_id)`, applies plan changes via `api_apply_revenuecat_event`. |

## Adding a route

1. Write a SQL migration with a `SECURITY DEFINER` function named
   `api_<verb>_<resource>(p_user_id uuid, …)`. Revoke from
   `public, anon, authenticated`.
2. Add a `handle<Resource>(req, userId)` helper in
   `backend/supabase/functions/api/index.ts` that calls the RPC via
   `rpc()` and returns `ok(...)`.
3. Wire it in the `Deno.serve` switch.
4. Add a constant in
   `client/lib/core/supabase/supabase_constants.dart`.
5. Add a row to the table above.
6. Update `docs/specs/open/<id>.md` so the spec references both.
