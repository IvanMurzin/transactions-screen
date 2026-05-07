# Backend (Supabase)

Authoritative storage and API layer for the app. Three principles drive
the design:

1. **No direct table access from clients.** RLS denies `anon` /
   `authenticated` on every product table. The Flutter client talks
   only to Edge Functions; the function calls SECURITY DEFINER `api_*`
   RPCs that own the business rules.
2. **Migrations are the source of truth.** Schema, indexes, triggers,
   RLS policies, and `api_*` functions all live in
   [`supabase/migrations/`](supabase/migrations) — never edited via the
   Studio after the fact.
3. **A single backend per project.** No separate dev/prod Supabase
   projects. Use one project with a `dev`/`prod` distinction enforced
   on the client side.

## Layout

| Path                              | Purpose                                                                |
| --------------------------------- | ---------------------------------------------------------------------- |
| `supabase/config.toml`            | Project id, function flags, db.seed config.                            |
| `supabase/migrations/`            | Timestamp-prefixed SQL migrations (see [migrations.md](../docs/backend/migrations.md)). |
| `supabase/seed.sql`               | Idempotent local seed (run by `supabase db reset`).                    |
| `supabase/functions/api/`         | Authenticated edge function — single entrypoint, dispatches to RPCs.   |
| `supabase/functions/_shared/`     | Generic helpers: auth, db, env, validation, responses, cors.           |
| `scripts/deploy_supabase.sh`      | Push migrations + deploy functions to the linked project.              |

## Quickstart

```bash
# one-time
supabase login
cp ../.env.example ../.env  # fill SUPABASE_PROJECT_REF and any secrets

# local dev
supabase --workdir backend start
supabase --workdir backend db reset       # apply migrations + seed
supabase --workdir backend functions serve api

# deploy
./backend/scripts/deploy_supabase.sh
```

## Adding a new endpoint

1. Write a SQL migration that creates `api_<verb_resource>(p_user_id uuid, …)`.
   Wrap business rules in `SECURITY DEFINER` and check the user owns the row.
2. Add a `handle<Resource>(req, userId)` helper in
   [`supabase/functions/api/index.ts`](supabase/functions/api/index.ts)
   that calls the RPC via `db.rpc(...)`.
3. Route it from the `Deno.serve` switch.
4. Document the endpoint in `docs/contracts/api-surface.md`.
