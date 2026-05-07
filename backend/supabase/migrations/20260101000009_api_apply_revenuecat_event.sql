-- Applies a RevenueCat webhook payload to public.profiles.
--
-- Idempotent via webhook_events(source, external_id). Resolves the target
-- profile by `revenuecat_app_user_id` first, falls back to interpreting
-- `app_user_id` as the supabase user_id (common when the client has not yet
-- run RevenueCat.logIn(userId)). Updates `plan` and links the RC user id.
--
-- Payload shape and `is_pro` derivation live in the edge function — this RPC
-- only writes to the database.
create or replace function public.api_apply_revenuecat_event(
  p_source text,
  p_external_id text,
  p_app_user_id text,
  p_payload jsonb,
  p_is_pro boolean
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $func$
declare
  v_inserted_id uuid;
  v_user_id uuid;
  v_user_id_by_app uuid;
  v_target_user_id uuid;
  v_plan text;
begin
  if p_source is null or length(trim(p_source)) = 0 then
    raise exception 'VALIDATION_ERROR: source is required';
  end if;
  if p_external_id is null or length(trim(p_external_id)) = 0 then
    raise exception 'VALIDATION_ERROR: external_id is required';
  end if;
  if p_app_user_id is null or length(trim(p_app_user_id)) = 0 then
    raise exception 'VALIDATION_ERROR: app_user_id is required';
  end if;

  insert into public.webhook_events(source, external_id, payload)
  values (trim(p_source), trim(p_external_id), coalesce(p_payload, '{}'::jsonb))
  on conflict (source, external_id) do nothing
  returning id into v_inserted_id;

  if v_inserted_id is null then
    return jsonb_build_object('processed', false, 'reason', 'duplicate');
  end if;

  select p.user_id
  into v_user_id_by_app
  from public.profiles p
  where p.revenuecat_app_user_id = p_app_user_id
  limit 1;

  begin
    v_user_id := p_app_user_id::uuid;
  exception
    when invalid_text_representation then
      v_user_id := null;
  end;

  if v_user_id_by_app is not null then
    v_target_user_id := v_user_id_by_app;
  elsif v_user_id is not null
        and exists(select 1 from public.profiles where user_id = v_user_id) then
    v_target_user_id := v_user_id;
  else
    return jsonb_build_object(
      'processed', true,
      'updated', false,
      'reason', 'profile_not_found'
    );
  end if;

  v_plan := case when p_is_pro then 'pro' else 'free' end;

  update public.profiles p
  set
    plan = v_plan,
    revenuecat_app_user_id = p_app_user_id,
    updated_at = now()
  where p.user_id = v_target_user_id;

  return jsonb_build_object(
    'processed', true,
    'updated', true,
    'user_id', v_target_user_id,
    'plan', v_plan
  );
end;
$func$;

revoke all on function public.api_apply_revenuecat_event(text, text, text, jsonb, boolean)
  from public, anon, authenticated;
