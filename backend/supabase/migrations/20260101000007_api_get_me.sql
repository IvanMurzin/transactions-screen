-- Returns the caller's profile as JSON.
--
-- Returns the row from `public.profiles` keyed by `p_user_id`. The trigger
-- `handle_new_user` guarantees a row exists, so a missing profile is
-- surfaced as NOT_FOUND rather than auto-created here.
create or replace function public.api_get_me(
  p_user_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $func$
declare
  v_profile public.profiles;
begin
  if p_user_id is null then
    raise exception 'VALIDATION_ERROR: user id is required';
  end if;

  select *
  into v_profile
  from public.profiles
  where user_id = p_user_id;

  if not found then
    raise exception 'NOT_FOUND: profile not found';
  end if;

  return jsonb_build_object(
    'profile', to_jsonb(v_profile)
  );
end;
$func$;

revoke all on function public.api_get_me(uuid) from public, anon, authenticated;
