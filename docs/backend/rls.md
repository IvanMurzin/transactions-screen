# RLS and the api_* RPC pattern

The contract: **clients never query product tables directly.** RLS
denies them. Everything goes through Edge Function → `api_*` RPC.

## Locking down a table

```sql
alter table public.<table> enable row level security;

revoke all on table public.<table> from anon, authenticated;
grant  all on table public.<table> to service_role;
```

That's it. No `policy ... for select using ...` for `anon` /
`authenticated` — they're never supposed to read this table directly.

## The api_* RPC pattern

```sql
create or replace function public.api_<verb>_<resource>(
  p_user_id uuid,
  -- … other params
)
returns <type>
language plpgsql
security definer
set search_path = public
as $$
declare
  v_x ...;
begin
  -- 1. ownership check
  if not exists (
    select 1 from public.<table>
    where id = p_id and user_id = p_user_id
  ) then
    raise exception 'NOT_FOUND: <table> % not visible to user', p_id;
  end if;

  -- 2. business rules
  -- …

  -- 3. mutation / select
  -- …

  -- 4. on failure: raise '<CODE>: <message>' — handler maps to envelope
  return ...;
end;
$$;

grant execute on function public.api_<verb>_<resource>(uuid, …) to service_role;
revoke execute on function public.api_<verb>_<resource>(uuid, …) from anon, authenticated, public;
```

## Error mapping

The Edge Function reads exception messages of the form `CODE: text`
and translates them into the envelope's `error.code`. Use these
codes (extend in `_shared/responses.ts`):

- `UNAUTHORIZED` — auth missing / invalid (rare; usually thrown earlier).
- `FORBIDDEN` — auth ok but action not permitted.
- `NOT_FOUND` — resource missing or invisible to the caller.
- `VALIDATION_ERROR` — bad input.
- `CONFLICT` — concurrent edit / unique constraint / state violation.
- `RATE_LIMITED` — abuse / quota.
- `EXTERNAL_API_ERROR` — third-party call failed.
- `INTERNAL_ERROR` — fallback for unexpected exceptions.
