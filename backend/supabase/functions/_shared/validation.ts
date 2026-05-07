import { z } from 'https://esm.sh/zod@3.24.2';
import { ApiHttpError } from './responses.ts';

// Reusable schemas. Add product-specific schemas alongside their
// `handle<Resource>` helper, not here — keep this file generic.
export const uuidSchema = z.string().uuid();
export const isoDateSchema = z.string().datetime({ offset: true });

// Profile update — partial PATCH semantics. All fields optional.
export const profileUpdateSchema = z
  .object({
    displayName: z.string().trim().min(1).max(120).optional(),
    avatarUrl: z.string().trim().url().max(2048).optional(),
    locale: z.string().trim().min(2).max(16).optional(),
  })
  .refine(
    (value) => value.displayName !== undefined
      || value.avatarUrl !== undefined
      || value.locale !== undefined,
    { message: 'At least one field must be provided' },
  );

// Account deletion confirmation envelope.
export const deleteMyAccountSchema = z.object({
  confirm: z.literal(true),
});

export async function parseJsonBody<T>(req: Request, schema: z.ZodSchema<T>): Promise<T> {
  const rawBody = await req.json().catch(() => {
    throw new ApiHttpError(400, 'VALIDATION_ERROR', 'Invalid JSON body');
  });
  const parsed = schema.safeParse(rawBody);
  if (!parsed.success) {
    throw new ApiHttpError(400, 'VALIDATION_ERROR', 'Validation failed', parsed.error.flatten());
  }
  return parsed.data;
}

export function parsePositiveInt(
  value: string | null,
  fallback: number,
  maxValue: number,
): number {
  if (!value) return fallback;
  const parsed = Number(value);
  if (!Number.isFinite(parsed) || parsed <= 0) return fallback;
  return Math.min(maxValue, Math.floor(parsed));
}

export function parseBoolean(value: string | null, fallback: boolean): boolean {
  if (value == null) return fallback;
  if (value === 'true' || value === '1') return true;
  if (value === 'false' || value === '0') return false;
  return fallback;
}
