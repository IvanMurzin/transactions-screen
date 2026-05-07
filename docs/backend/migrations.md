# Migrations

All schema changes ship as SQL migrations under
`backend/supabase/migrations/`. Studio edits are not durable — recreate
them as a migration before merging.

## Filename

```
YYYYMMDDHHMMSS_<topic>.sql
```

- Timestamp = creation moment in UTC, monotonically increasing.
- Topic = lowercase, snake_case, descriptive (`users_table`,
  `accounts_rls`, `api_create_account_function`).
- One topic per file. Splitting a logically-coupled change across two
  files is fine if it makes review easier.

## Forward-only

No `DOWN` migrations. To revert: ship a follow-up migration that
undoes the change.

## Idempotency

Make new migrations safe to re-run on a partial environment when
practical:

```sql
create table if not exists ...
create index if not exists ...
create or replace function ...
```

## Apply locally

```bash
supabase --workdir backend db reset           # drops + reapplies + seeds
supabase --workdir backend migration up       # applies pending
```

## Apply remotely

```bash
./backend/scripts/deploy_supabase.sh
```

The script runs `supabase db push` against the linked project.

## Reviewing a migration

- Does it leave RLS in the right state for new tables?
- Does it `GRANT EXECUTE` on new `api_*` functions to
  `service_role`?
- Does it add necessary indexes for new query patterns?
