-- Universal user profile, one row per `auth.users`.
--
-- Fields are intentionally minimal and product-agnostic. Add product-specific
-- columns in a separate migration alongside the feature that needs them.
--
-- `plan` is included even when subscriptions are not active in the product —
-- RLS policies and the api envelope already assume a `free` baseline.
create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text not null default '',
  display_name text null,
  avatar_url text null,
  locale text not null default 'en',
  plan text not null default 'free' check (plan in ('free', 'pro')),
  revenuecat_app_user_id text null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_profiles_revenuecat_app_user_id
  on public.profiles(revenuecat_app_user_id)
  where revenuecat_app_user_id is not null;
