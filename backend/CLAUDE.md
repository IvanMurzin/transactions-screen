# Supabase backend (Claude Code)

Same content lives in `backend/AGENTS.md`. Keep both in sync.

Conventions for migrations, RLS, and edge functions. Repo-level rules
live in [`../CLAUDE.md`](../CLAUDE.md); this file is the backend-only
addendum.

## Layout

```
supabase/
  config.toml          # project_id, function flags, db.seed config.
  migrations/          # Timestamp-prefixed SQL migrations — source of truth.
  seed.sql             # Idempotent local seed (run by `supabase db reset`).
  functions/
    api/index.ts       # Single authenticated edge function. Routes to RPCs.
    _shared/           # Generic helpers: auth, db, env, validation, responses, cors.
scripts/deploy_supabase.sh  # Push migrations + deploy functions.
```

## Commands

```bash
supabase --workdir backend start
supabase --workdir backend db reset                         # apply migrations + seed
supabase --workdir backend functions serve api
supabase --workdir backend gen types typescript --local     # see scripts/supabase-typegen.sh
./backend/scripts/deploy_supabase.sh                        # push + deploy
```

## Hard rules

- **RLS is on for every product table.** `anon` and `authenticated`
  roles are denied. The edge function uses the service role and calls
  `SECURITY DEFINER` `api_*` RPCs that own access checks.
- All migrations are forward-only and timestamp-prefixed:
  `YYYYMMDDHHMMSS_<topic>.sql`.
- Studio edits that bypass migrations are not durable — re-create them
  as a migration before merging.
- Edge function responses use the envelope (see
  `_shared/responses.ts`): `{ ok: true, data, meta? }` or
  `{ ok: false, error: { code, message, details? } }`.
- `api_*` RPCs accept `p_user_id uuid` as the first parameter and
  verify ownership before doing work.

## Adding an endpoint

1. Migration: create `api_<verb>_<resource>(p_user_id uuid, …)`.
   Wrap business logic, raise `<CODE>: <message>` on failure (the
   handler maps that into the envelope).
2. Schema: add a Zod schema in `_shared/validation.ts` if the route
   accepts a JSON body.
3. Route: add a `handle<Resource>(req, userId)` helper in
   `functions/api/index.ts` and route it in the `Deno.serve` switch.
4. Document in `docs/contracts/api-surface.md`.
5. Local check: `supabase db reset` then call the route via curl.
