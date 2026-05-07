# Project guide for Claude Code

> A copy of this guide for Codex lives in `AGENTS.md`. Both files must
> stay in sync — see the `check-ai-consistency` skill.

This is a Flutter + Supabase application built from `sdd_template`. The
template is opinionated: every change goes through a written spec, the
client uses Bloc / go_router / get_it, and the backend exposes only
Edge Functions over RLS-locked tables.

## Repository layout

```
.
├── client/             # Flutter app (iOS + Android only)
├── backend/            # Supabase migrations, edge functions, deploy scripts
├── docs/
│   ├── product/        # Why the product exists. Filled by `create-product`.
│   ├── architecture/   # How things fit together at the project level.
│   ├── client/         # Flutter-side conventions and recipes.
│   ├── backend/        # Supabase conventions, migration & RLS rules.
│   ├── design_system/  # DS contracts, tokens, preview route.
│   ├── configuration/  # Flavors, env vars, Firebase, RevenueCat, Supabase keys.
│   ├── agent_workflows/# Skills, Claude vs Codex parity, hooks.
│   ├── sdd/            # Constitution, spec lifecycle, templates, DoD.
│   └── specs/          # open/, closed/, archive/, INDEX.md.
├── .claude/
│   ├── skills/         # Slash-style skills used by Claude Code.
│   ├── agents/         # Subagent prompts (review/research roles).
│   └── settings.json   # Permissions + Stop-hook running scripts/check.sh.
├── .agents/            # Codex equivalents (skills + agents).
├── scripts/            # bootstrap.sh, check.sh, format.sh, …
└── tools/              # Ad-hoc tooling (empty by default).
```

## Source of truth, in order

1. **The current code.** If docs disagree with what's running, update
   docs unless the user says the code is wrong.
2. **`docs/product/*`** for "why".
3. **`docs/architecture/`, `docs/client/`, `docs/backend/`** for "how".
4. **`docs/contracts/api-surface.md`** for the API shape clients
   depend on; **`docs/troubleshooting.md`** for known failure modes.
5. **`docs/sdd/constitution.md`** for non-negotiables.
6. **`docs/specs/open/<id>.md`** for the change you're working on.

## Workflow: explore → plan → implement → verify

1. **Explore.** Read the relevant spec, the product docs it links, and
   the code paths it touches. Use parallel `Explore` agents when scope
   is uncertain.
2. **Plan.** State your approach in 1-2 sentences before editing.
   For non-trivial work, write the plan into the spec body.
3. **Implement.** Stay scoped to the spec. Don't refactor adjacent
   code unless the spec says so.
4. **Verify.** Run `scripts/check.sh` (format + analyze + AI
   consistency). For UI changes, exercise the feature in the simulator.

## Hard rules

- Feature work lives under `client/lib/` unless the spec explicitly
  changes backend, docs, or tooling.
- Generated files are **never** edited by hand: `*.freezed.dart`,
  `*.g.dart`, `client/lib/core/di/injectable.config.dart`, generated
  l10n files.
- All user-visible strings go through `client/lib/l10n/app_en.arb` and
  `client/lib/l10n/app_ru.arb`. Both stay in sync.
- Dart line length is 100.
- Don't add dependencies unless an accepted spec requires them.
- Don't bypass RLS — the client never queries product tables directly.
- Don't commit secrets, real Firebase configs, or real RevenueCat keys.
- Don't push to `main` automatically; never force-push.

## Architecture conventions

### Flutter client

- **State management:** `flutter_bloc` with Cubit-first. Use Bloc with
  events only when the domain is genuinely event-driven. Never
  introduce a different state framework without an accepted proposal.
- **Routing:** `go_router`. Routes in `core/routing/app_routes.dart`,
  the router built in `core/routing/app_router.dart`. Cross-cutting
  navigation logic lives in `core/routing/guards/` as `RouteGuard`s.
- **DI:** `get_it` + `injectable` with code generation. Run
  `dart run build_runner build --delete-conflicting-outputs` after
  changing `@injectable` annotations.
- **Logging:** the singleton in `core/logger/logger.dart`. Never use
  `print()`.
- **Config:** `AppConfig` reads `--dart-define-from-file=../.config.<flavor>.json`.
  Flags: `ENABLE_FIREBASE`, `ENABLE_REVENUECAT`, both default false.
- **Design system:** all UI uses `core_ui/components/` and
  `context.dsColors` / `dsSpacing` / etc. The `/design-system` route
  shows every component for review.

### Supabase backend

- One backend per project (no separate dev/prod backends).
- Schema changes ship as SQL migrations under
  `backend/supabase/migrations/`. Studio edits that bypass migrations
  are not durable.
- RLS is **on** for every product table; `anon`/`authenticated` are
  denied. The edge function uses the service role to call SECURITY
  DEFINER `api_<verb>_<resource>` RPCs.
- API responses use the envelope: `{ ok: true, data, meta? }` or
  `{ ok: false, error: { code, message, details? } }`. Clients switch
  on `code`, never on `message`.

### Integrations

- **Firebase Analytics + Crashlytics:** prepared but disabled by
  default. After adding `google-services.json` /
  `GoogleService-Info.plist`, set `ENABLE_FIREBASE=true` in
  `.config.<flavor>.json`.
- **RevenueCat:** prepared with a no-op service when disabled. After
  adding real keys, set `ENABLE_REVENUECAT=true`. The subscription
  flow is RevenueCat-bound; see
  `docs/architecture/patterns/subscriptions_revenuecat.md`.

### Universal modules shipped with the template

Domain + data + cubit code (no UI) for auth, profile, sessions, and
subscriptions ships in the template. Wire the auth UI yourself; the
rest works out of the box.

- **Auth:** `domain/auth/`, `data/auth/`, `presentation/auth/bloc/`.
  Email password + optional OTP (`IS_OTP_ENABLED` flag, default
  off) + Google / Apple OAuth (gated on `OAUTH_REDIRECT_URI`).
- **Profile:** `domain/profile/`, `data/profile/`,
  `presentation/profile/bloc/`. Minimal fields: `userId, email,
  displayName, avatarUrl, locale, plan, revenuecatAppUserId,
  createdAt, updatedAt`.
- **Sessions:** `core/session/unauthorized_notifier.dart` +
  `AuthCubit.forceLocalSignOut()` handle backend 401 → drop local
  session without calling Supabase signOut.
- **Subscriptions:** `domain/subscription/`, `data/subscription/`,
  `presentation/subscription/bloc/`. RevenueCat-bound; the source
  of truth is `profiles.plan`, refreshed via the webhook and
  `/api/revenuecat/refresh`.

The matching backend ships as migrations and edge functions:
`profiles`, `webhook_events`, `handle_new_user` trigger, RLS
policies, `api_get_me`, `api_profile_update`,
`api_apply_revenuecat_event`, plus the `revenuecat_webhook`
function.

## Spec-driven development

- Every change is captured as a spec in `docs/specs/open/<type>/`.
- See `docs/sdd/spec_lifecycle.md` for statuses, `docs/sdd/spec_template.md`
  for the schema, `docs/sdd/definition_of_done.md` for the merge bar.
- Use the skills:
  - `/create-spec` — one focused change you understand.
  - `/plan-feature` — break a feature area into multiple specs.
  - `/resolve-spec SPEC-####` — implement an existing spec.
- Spec id formats: `SPEC-####` (feature), `BUG-####` (bug),
  `PROP-####` (proposal). Number monotonically across types.

## Skills

Located in `.claude/skills/<name>/SKILL.md`. Listed by trigger:

| Skill | When to use |
| ----- | ----------- |
| `bootstrap` | Right after cloning the template into a new project dir. |
| `create-product` | Filling `docs/product/*` from a rough vision. |
| `review-core-ui` | Auditing the design system for gaps and violations. |
| `plan-feature` | Turning a product area into a sequenced set of specs. |
| `create-spec` | Writing one focused, decision-complete spec. |
| `resolve-spec` | Implementing an existing spec end-to-end. |
| `check-ai-consistency` | Verifying CLAUDE.md ↔ AGENTS.md and skill parity. |

## Subagents

Located in `.claude/agents/`:

- `sdd-spec-reviewer.md` — sharpens specs before they leave `draft`.
- `flutter-architect.md` — reviews client architecture decisions.
- `supabase-architect.md` — reviews backend / RLS / RPC decisions.
- `core-ui-reviewer.md` — reviews DS coherence.

Use them for review and research tasks where their isolated context
saves your main context window.

## Verification commands

From `client/`:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format .
flutter analyze
flutter test
flutter run --flavor dev --dart-define-from-file=../.config.dev.json
```

From repo root:

```bash
./scripts/check.sh                # format + analyze + ai-consistency
./scripts/format.sh               # dart format + deno fmt
./scripts/analyze.sh              # flutter analyze
./scripts/check-ai-consistency.sh # CLAUDE.md ↔ AGENTS.md, skill parity
./scripts/update-spec-index.sh    # regenerate docs/specs/INDEX.md
```

## Branch and commit policy

- One spec → one branch → one PR. Branch naming:
  `spec/SPEC-0001-short-title`.
- Commit message for spec work: `spec(SPEC-####): <imperative summary>`.
- `resolve-spec` does not commit unless you explicitly say "commit"
  and does not merge unless you say "merge".
- Never push to `main` automatically.

## Config and secrets policy

- Real `.env`, `.config.dev.json`, `.config.prod.json`, Firebase
  config files, RevenueCat keys, and Supabase service role keys are
  **never** committed.
- `.example` files are committed and contain obvious placeholder
  values (`YOUR_*`, `rcat_placeholder_*`).
- Local secrets live outside the repo or in untracked `.env` /
  `.config.*.json`.

## What "done" means

A spec is done when every checkbox in `docs/sdd/definition_of_done.md`
is satisfied: ACs pass, format + analyze clean, l10n synchronized, no
generated files edited, INDEX.md regenerated, commit message format
correct.
