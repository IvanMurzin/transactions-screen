# sdd_template

Reusable starter for Flutter + Supabase apps with **spec-driven
development** baked in. Optimised for both Claude Code and Codex.

## What you get

### Architecture

- Flutter client with iOS + Android flavors (`dev` / `prod`),
  `flutter_bloc` + `go_router` + `get_it` / `injectable`, neutral
  design-system scaffold, EN + RU localization.
- Supabase backend with **RLS-by-default** + edge functions,
  generic helpers (`_shared/{auth, cors, db, env, responses,
  validation}`), single authenticated `api/` function with the
  envelope `{ ok, data | error }`.
- Firebase Analytics + Crashlytics and RevenueCat — prepared but
  disabled by default; opt in via `.config.<flavor>.json`.

### Universal modules (no UI — only domain + data + state)

These ship working out of the box; you write the UI:

- **Auth** — email + password, optional OTP (`IS_OTP_ENABLED`),
  Google / Apple OAuth (gated on `OAUTH_REDIRECT_URI`). 10 use
  cases, repository, data source, AuthCubit, AuthRouteGuard.
- **Profile** — universal fields (`userId, email, displayName,
  avatarUrl, locale, plan, revenuecatAppUserId, createdAt,
  updatedAt`), get / partial-update use cases, ProfileCubit.
- **Sessions** — `UnauthorizedNotifier` + `AuthCubit.forceLocalSignOut()`
  drop the local session on backend 401 without thrashing Supabase.
- **Subscriptions** — RevenueCat-bound. Source of truth is
  `profiles.plan`, refreshed via the webhook and
  `/api/revenuecat/refresh`. SubscriptionCubit binds the RC
  identity on every authenticated session automatically.

Backend ships the matching migrations: `profiles`, `webhook_events`,
`handle_new_user` trigger, RLS lock-down, `api_get_me`,
`api_profile_update`, `api_apply_revenuecat_event`, plus the
`revenuecat_webhook` edge function.

See [`docs/client/auth_profile_subscriptions.md`](docs/client/auth_profile_subscriptions.md)
for the practical guide and a sequenced list of suggested first specs.

### Spec-driven development

- Constitution, spec lifecycle (`draft → open → planned →
  in_progress → review → done`), spec / plan / tasks templates,
  Definition of Done, auto-generated `INDEX.md`.
- Skills shared between Claude (`.claude/skills/*`) and Codex
  (`.agents/skills/*`): `bootstrap`, `create-product`,
  `review-core-ui`, `plan-feature`, `create-spec`, `resolve-spec`,
  `check-ai-consistency`.
- Subagents in `.claude/agents/` and `.agents/agents/` for review
  / research workflows: `sdd-spec-reviewer`, `flutter-architect`,
  `supabase-architect`, `core-ui-reviewer`.

### Tooling

- `bootstrap.sh` — renames the package, scaffolds flavors, runs
  `flutter pub get` + `build_runner`, format + analyze, and creates a
  clean git repo/first commit (`--reinit-git` for cloned templates).
- `check.sh`, `format.sh`, `analyze.sh`, `check-ai-consistency.sh`,
  `update-spec-index.sh`, `supabase-reset.sh`, `supabase-typegen.sh`.
- `.claude/settings.json` Stop hook runs `check.sh` after every
  Claude session.
- Tracked DX defaults: `.vscode/launch.json` and `client/pubspec.lock`.

### Flutter toolchain pin

- Project Flutter pin: `3.38.7` in [`.fvmrc`](.fvmrc).
- `client/pubspec.yaml` constrains SDK to Dart `^3.10.0` and
  Flutter `>=3.38.7 <4.0.0`.
- Optional (recommended): use FVM so this repo does not affect other
  projects:
  - `dart pub global activate fvm`
  - `fvm install 3.38.7`
  - run Flutter/Dart commands via `fvm flutter ...` / `fvm dart ...`.

## Use it

```bash
# 1. Clone the template into a new project dir (do NOT work inside sdd_template)
git clone <YOUR_TEMPLATE_REPO_URL> ~/projects/myapp
cd ~/projects/myapp

# 2. Bootstrap. Renames package, runs build_runner so generated files exist,
#    runs format + analyze, removes template .git, then creates a clean repo
#    with the first commit.
./scripts/bootstrap.sh --app-name "My App" --app-id com.acme.myapp --reinit-git

# 3. Fill secrets (see docs/configuration/env_and_configs.md):
#      .config.dev.json, .config.prod.json   — client config
#      .env                                  — backend deploy + RevenueCat secrets
#
# 4. Push backend (optional until you start writing features):
./backend/scripts/deploy_supabase.sh

# 5. From here, drive everything through skills:
#      /create-product           — fill docs/product/*
#      /plan-feature             — break a feature area into specs
#      /create-spec              — capture one focused change
#      /resolve-spec SPEC-####   — implement an existing spec
```

## Suggested first specs

The template intentionally ships no auth UI — products own
presentation. The fastest path to a working app:

1. **SPEC-0001 — Sign-in page** wired to `SignInWithPasswordUseCase`.
2. **SPEC-0002 — Sign-up page**, branching on `AppConfig.isOtpEnabled`.
3. **SPEC-0003 — Wire `AuthRouteGuard`** (one-line change in `app.dart`).
4. **SPEC-0004 — Profile screen** reading from `ProfileCubit`.
5. **SPEC-0005 — Edit profile** form bound to `ProfileCubit.updateProfile`.
6. **SPEC-0006 — Paywall + subscription gate** branching on
   `SubscriptionState.isPro`.

Each spec is small, observable on its own, and exercises code that
already ships. Details and patterns:
[`docs/client/auth_profile_subscriptions.md`](docs/client/auth_profile_subscriptions.md).

## Manual setup after bootstrap

The bootstrap output prints a checklist; the highlights:

- `google-services.json` (Android) and `GoogleService-Info.plist`
  (iOS), then `ENABLE_FIREBASE=true` in `.config.<flavor>.json`.
- Real RevenueCat **public SDK** key, then `ENABLE_REVENUECAT=true`.
  Plus the **server** key + `REVENUECAT_WEBHOOK_SECRET` in `.env`
  if subscriptions are live.
- `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `.config.<flavor>.json`.
- Configure Supabase Auth providers (email + Google / Apple) in
  the Supabase dashboard if OAuth is enabled.
- App icons, native splash, signing.

## Where to look next

| Doc | Why |
| --- | --- |
| [`CLAUDE.md`](CLAUDE.md) / [`AGENTS.md`](AGENTS.md) | Full project guide for the AI tools (kept in sync). |
| [`docs/README.md`](docs/README.md) | Map of all documentation sections. |
| [`docs/architecture/overview.md`](docs/architecture/overview.md) | The three-tier model and the API envelope. |
| [`docs/contracts/api-surface.md`](docs/contracts/api-surface.md) | Every edge-function route the template ships. |
| [`docs/configuration/env_and_configs.md`](docs/configuration/env_and_configs.md) | Every config and env key. |
| [`docs/sdd/how_to_use_sdd.md`](docs/sdd/how_to_use_sdd.md) | The spec workflow end to end. |
| [`docs/troubleshooting.md`](docs/troubleshooting.md) | Common failures during bootstrap, build, deploy. |
| [`docs/template_migration_report.md`](docs/template_migration_report.md) | What was extracted from the source project, what was rewritten, what was intentionally left out. |
