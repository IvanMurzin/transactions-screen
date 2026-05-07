-- RLS for profiles.
--
-- Pattern: the table is fully locked for `anon` / `authenticated`. All reads
-- and writes go through SECURITY DEFINER `api_*` functions so business rules
-- (validation, plan limits, audit) live in one place. Service-role keys used
-- by edge functions bypass RLS by design.
alter table public.profiles enable row level security;
alter table public.profiles force row level security;

-- No policies are added on purpose: every access path goes via api_* RPCs
-- that this template ships under SECURITY DEFINER.

revoke all on table public.profiles from public, anon, authenticated;
revoke all on table public.webhook_events from public, anon, authenticated;
