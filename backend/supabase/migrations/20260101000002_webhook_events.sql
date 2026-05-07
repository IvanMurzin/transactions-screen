-- Idempotency log for inbound webhooks (RevenueCat, payment providers, …).
--
-- Insert (source, external_id, payload) on every webhook receipt; rely on the
-- unique index to short-circuit duplicate deliveries. Functions that mutate
-- state from a webhook should consult this table before applying changes.
create table if not exists public.webhook_events (
  id uuid primary key default gen_random_uuid(),
  source text not null,
  external_id text not null,
  received_at timestamptz not null default now(),
  payload jsonb not null,
  unique (source, external_id)
);
