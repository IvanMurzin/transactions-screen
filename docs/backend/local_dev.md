# Local development

Standard loop:

```bash
supabase --workdir backend start                 # boot Postgres + studio + storage
supabase --workdir backend db reset              # apply migrations + seed
supabase --workdir backend functions serve api   # serve edge function
```

## Quick checks

```bash
# Hit the health endpoint (replace JWT with one from the local studio)
curl -s -H "Authorization: Bearer $JWT" \
  http://localhost:54321/functions/v1/api/health | jq
```

## Resetting

```bash
./scripts/supabase-reset.sh   # asks for confirmation, then `db reset`
```

## Generating types

```bash
./scripts/supabase-typegen.sh
# writes backend/supabase/functions/_shared/database.types.ts
```

## When something is wrong

1. `supabase --workdir backend status` — are services running?
2. `supabase --workdir backend db logs` — tail Postgres logs.
3. Stop and start the stack: `supabase --workdir backend stop` then
   `start`.
