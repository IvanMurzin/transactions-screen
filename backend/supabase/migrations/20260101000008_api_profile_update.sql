-- Updates mutable profile fields (display_name, avatar_url, locale).
--
-- Each parameter is nullable; only non-null values are applied so the same
-- function can do partial updates ("PATCH"). Empty strings are normalized to
-- null. The `updated_at` trigger refreshes the timestamp automatically.
create or replace function public.api_profile_update(
  p_user_id uuid,
  p_display_name text default null,
  p_avatar_url text default null,
  p_locale text default null
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

  update public.profiles
  set
    display_name = case
      when p_display_name is null then display_name
      else nullif(trim(p_display_name), '')
    end,
    avatar_url = case
      when p_avatar_url is null then avatar_url
      else nullif(trim(p_avatar_url), '')
    end,
    locale = case
      when p_locale is null then locale
      when length(trim(p_locale)) = 0 then locale
      else trim(p_locale)
    end
  where user_id = p_user_id
  returning * into v_profile;

  if not found then
    raise exception 'NOT_FOUND: profile not found';
  end if;

  return jsonb_build_object(
    'profile', to_jsonb(v_profile)
  );
end;
$func$;

revoke all on function public.api_profile_update(uuid, text, text, text)
  from public, anon, authenticated;
