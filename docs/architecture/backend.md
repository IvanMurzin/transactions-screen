# Backend architecture

Three building blocks: migrations, Edge Functions, RPC.

## Migrations

- All schema lives in `backend/supabase/migrations/`.
- Filename: `YYYYMMDDHHMMSS_<topic>.sql`. Forward-only; no down
  migrations.
- A migration may create tables, indexes, triggers, RLS policies,
  grants, and `api_*` functions. One topic per file.

## RLS

- Every product table has `ALTER TABLE ... ENABLE ROW LEVEL SECURITY`.
- `anon` and `authenticated` are explicitly denied via `REVOKE`.
- The Edge Function uses the **service role** key (`SUPABASE_SERVICE_ROLE_KEY`)
  to call `api_*` RPCs. The RPC is `SECURITY DEFINER` and verifies
  ownership.

## RPCs

```sql
create or replace function public.api_<verb>_<resource>(
  p_user_id uuid,
  -- … other params
) returns <type>
language plpgsql
security definer
set search_path = public
as $$
begin
  -- 1. ownership / auth checks
  -- 2. business rules
  -- 3. mutation / select
  -- 4. raise '<CODE>: <message>' on failure (mapped to envelope by handler)
end;
$$;
```

## Edge Function

- One function: `api`. Authenticated (`verify_jwt = true`).
- `Deno.serve` switch dispatches `<METHOD> /<route>` to a tiny
  `handle<Resource>(req, userId)` helper.
- Each handler:
  1. Parses + validates request body via Zod (`_shared/validation.ts`).
  2. Calls `db.rpc('api_<verb>_<resource>', { p_user_id, … })`.
  3. Wraps the result in the envelope (`_shared/responses.ts`).

## Add an endpoint

1. Migration: write the `api_<verb>_<resource>` function.
2. Validation: add a Zod schema for the body (if any) in
   `_shared/validation.ts`.
3. Handler: add `handle<Resource>(req, userId)` in
   `functions/api/index.ts` and route it.
4. Document: append a row to `docs/contracts/api-surface.md`.
5. Local check: `supabase db reset && supabase functions serve api`,
   then call via curl.
