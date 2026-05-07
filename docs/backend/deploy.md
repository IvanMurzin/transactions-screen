# Deploy

```bash
./backend/scripts/deploy_supabase.sh
```

What the script does:

1. Reads `SUPABASE_PROJECT_REF` from `.env`.
2. `supabase link --project-ref ...`.
3. `supabase db push` — applies pending migrations.
4. `supabase functions deploy api`.

## Secrets

Edge functions read environment via
`Deno.env.get('FOO')`. Set them with:

```bash
supabase --workdir backend secrets set \
  SOME_KEY=value \
  ANOTHER_KEY=value
```

Use this for any third-party API key the backend needs (RevenueCat
server key, scheduler shared secret, …). Do **not** commit the
values; document them in this file with a placeholder.

## Required secrets

The template ships with no required secrets beyond Supabase's own.
Add a row here when you wire up an integration that needs one.

| Secret | Used by | Notes |
| ------ | ------- | ----- |
| `SUPABASE_SERVICE_ROLE_KEY` | `_shared/db.ts` | Provided by Supabase automatically. |
