-- Auto-create a profile row whenever Supabase Auth provisions a new user.
--
-- Reads display_name / avatar_url / locale from `raw_user_meta_data` populated
-- by social login providers (Google, Apple, GitHub, …); falls back to safe
-- defaults so the row is always usable. Idempotent via ON CONFLICT.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $func$
begin
  insert into public.profiles(user_id, email, display_name, avatar_url, locale)
  values (
    new.id,
    coalesce(new.email, ''),
    nullif(new.raw_user_meta_data->>'full_name', ''),
    nullif(new.raw_user_meta_data->>'avatar_url', ''),
    coalesce(nullif(new.raw_user_meta_data->>'locale', ''), 'en')
  )
  on conflict (user_id) do nothing;
  return new;
end;
$func$;
