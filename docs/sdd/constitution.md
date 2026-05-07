# Constitution

Non-negotiable principles for this codebase. Changes that violate any
of these need an accepted `proposal/` spec before implementation.

## State management

- **Bloc / Cubit is the default state-management approach.** Cubit-first;
  use Bloc only when an event-driven model genuinely fits the domain.
  Do not introduce another state-management framework (Riverpod,
  Provider-only, MobX, …) without an accepted proposal spec.

## Backend access

- All product tables have **RLS enabled** with `anon` and `authenticated`
  denied. Direct PostgREST access from the client is forbidden.
- The client talks to the backend exclusively through Edge Functions.
- Edge Functions delegate every product action to a `SECURITY DEFINER`
  Postgres function named `api_<verb>_<resource>(p_user_id, …)`.
- Schema changes ship as migrations. Studio edits that bypass migrations
  are not durable.

## API envelope

- All edge function responses use the same JSON envelope:
  - success: `{ "ok": true, "data": …, "meta"?: … }`
  - failure: `{ "ok": false, "error": { "code": "<MACRO_CASE>", "message": …, "details"?: … } }`
- Clients switch on `error.code`, never on `error.message`.

## Localization

- All user-visible strings live in `client/lib/l10n/app_en.arb` and
  `app_ru.arb`. The two locales must stay in sync — every key in one
  exists in the other.
- Never hardcode strings into widgets.

## Generated files

- `*.freezed.dart`, `*.g.dart`, `client/lib/core/di/injectable.config.dart`,
  and generated localization files are never edited by hand.

## Specs

- Every feature, bug fix, or improvement passes through a spec.
- A spec is the contract; the implementation must satisfy its
  acceptance criteria exactly. New scope means a new spec.

## Secrets

- Never commit real `.env`, `.config.dev.json`, `.config.prod.json`,
  Firebase config files, RevenueCat keys, or Supabase service role keys.
  `.example` files only.
