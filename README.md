# Transactions — Mobile Lead screening task

A single-screen Flutter app.
It renders a paginated transactions list on
top of a mock API, on top of the `sdd_template` starter.

Task screen entry point:
[`transactions_page.dart`](client/lib/presentation/transactions/pages/transactions_page.dart)

---

## 1. Demo

<video src="demo.mp4" controls width="360"></video>

▶ [Watch the demo (demo.mp4)](demo.mp4)

---

## 2. The base template (`sdd_template`)

`sdd_template` is an opinionated, in-house Flutter + Supabase starter.
Its goal is predictable delivery: every change goes through a written
spec, the client keeps strict layer boundaries, and both Claude and
Codex share the same skills and guard rails. This task reuses its
foundation but not its full process.

**Stack used by this project**

| Concern | Choice |
| --- | --- |
| UI | Flutter (iOS/Android), Material 3 |
| State | `flutter_bloc`, Cubit-first |
| Navigation | `go_router` |
| DI | `get_it` + `injectable` (build_runner codegen) |
| Models | `freezed` + `json_serializable` |
| Networking | `dio`; Supabase Edge Functions for template modules |
| Localization | Flutter `gen-l10n`, ARB `en` + `ru` |
| Design system | Material 3 theme + `StatusColors` theme extension |
| Persistence | `shared_preferences` |
| Logging | `logger` |
| Backend (template) | Supabase: RLS-first tables, Edge Functions, `SECURITY DEFINER` RPCs |
| Integrations | Firebase, RevenueCat — scaffolded, off by default |

**Architecture.** Three layers per feature:
`domain` (entities, repository interfaces, use cases) →
`data` (DTOs, mappers, data sources, repository impls) →
`presentation` (Cubit + state, pages, widgets). Results flow back through
a `Result<T>` / `Failure` type instead of thrown exceptions.

**Skills** (`.claude/skills`, mirrored for Codex in `.agents`):

| Skill | Purpose |
| --- | --- |
| `bootstrap` | Rename package/bundle ids, scaffold configs, first build + commit |
| `create-product` | Turn a product vision into `docs/product/*` |
| `setup-design-system` | Generate the project design system (tokens + components) |
| `create-all-specs` | Break a product into a full spec backlog |
| `plan-feature` | Break one product area into sequenced specs |
| `create-spec` | Write one decision-complete spec |
| `resolve-spec` | Implement one spec end-to-end (format + analyze + test) |
| `mvp-orchestrator` | Run the delivery loop, one spec at a time |
| `ui-ux-pro-max` | UI/UX design intelligence used by the skills above |
| `review-core-ui` | Audit the design system for gaps/violations |
| `check-ai-consistency` | Keep `CLAUDE.md` ↔ `AGENTS.md` and skills in parity |

**Strengths**

- Enforced layering + codegen → consistent, reviewable structure.
- Batteries included: auth/profile/subscription modules, RLS backend,
  i18n, theming, DI already wired.
- Dual AI toolchains kept in sync with parity checks.

**Weaknesses**

- Heavy for a small task — most of the scaffolding is dead weight here.
- No design system ships by default; it must be generated before UI work.
- Coupled to Supabase conventions; a non-Supabase backend needs rework.
- The SDD process and docs contracts add a learning curve.

---

## 3. The task

**Requirements** (from the task file) and where each is handled:

| Requirement | Status | Location |
| --- | --- | --- |
| Transactions screen over the mock API | done | `presentation/transactions`, `data/transaction` |
| Grouped by day, newest first | done | `groupTransactionsByDay` in `transaction_day_group.dart` |
| Row: merchant, time, amount | done | `transaction_row.dart` |
| States: loading / empty / error | done | `transactions_page.dart` |
| Pull-to-refresh | done | `RefreshIndicator.adaptive` |
| Infinite scroll pagination | done | scroll listener + `TransactionsCubit.loadMore` |
| Status → emphasis mapping | done | `transaction_status_style.dart`, `status_colors.dart` |
| Hundreds of transactions | done | lazy slivers + 50-per-page paging |

Backend status mapping: `AUTHORIZED → Pending (muted)`,
`SETTLED → Settled (success)`, `DECLINED → Declined (error)`,
`REVERSED → Reversed (muted)`.

**Data flow**

```
TransactionsPage
  → TransactionsCubit (load / refresh / loadMore)
    → GetTransactionsUseCase
      → ITransactionRepository → TransactionRemoteDataSource (dio)
        → DTO → TransactionMapper → TransactionEntity
```

Pagination reads the API `next` cursor; `hasMore` goes false on the last
page (240 items = 5 pages of 50). The scroll listener triggers
`loadMore` before the bottom, and an in-flight guard prevents duplicate
page requests.

Beyond the task, the screen also has a **theme switch** (system/light/dark)
and a **language switch** (English/Русский) in the app bar, both wired to
the template's existing `ThemeModeCubit` / `LocaleCubit`.

**Tests** (`flutter test`, 20 total): cubit load/refresh/loadMore and
day grouping, mapper parsing/status/edge cases, page loading/empty/error
states, theme + language switching, and scroll-driven pagination through
real gestures.

**Run it**

```bash
cd client
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter run --flavor dev --dart-define-from-file=../.config.dev.json
```

The app opens straight on the Transactions screen. Supabase is
initialized on startup but unused by this screen, so the placeholder
config is fine.

**Potential improvements**

- Move base URL + endpoints into `AppConfig`; add `dio` interceptors
  (logging, retry, auth).
- Cache the last page and support offline
- Sticky day headers (`SliverPersistentHeader`), skeleton loaders,
  per-locale currency formatting, per-day totals.
- Replace spacing literals with design-system tokens once
  `setup-design-system` has run, introduce gesign system in general

**How it scales**

- Localization (en/ru) and theming (light/dark) are already in place and
  user-switchable.
- The layered architecture + DI mean a real backend is a data-source
  swap: replace `TransactionRemoteDataSource` with a Supabase Edge
  Function call and keep the repository, use case, cubit, and UI intact.
- The Supabase foundation (RLS, RPC, Edge Functions) is ready when the
  data needs to move server-side.

---

## 4. Untouched template surface

The following ship with the template and are **not used** by this task.
For a task review they are noise; for a real product they are the point.
If this repo stays scoped to the task, trim them:

- `backend/` — Supabase migrations, Edge Functions, deploy scripts.
- Universal modules — `domain`/`data`/`presentation` for `auth`,
  `profile`, `subscription` (logic only, no UI wired).
- Integrations — Firebase and RevenueCat scaffolding.
- SDD machinery — `docs/sdd`, `docs/specs`, most skills and subagents,
  orchestrator state in `.agent/`, spec-guard hooks in
  `.claude/settings.json`.
- Codex mirror — `.agents/`, `AGENTS.md`.

---

## 5. Process (human vs AI)

- **Human** — picked this pre-configured template as the base, ran the
  initial project setup, defined the task, directed the code review, and
  curated this README.
- **AI (Claude Code)** — ran bootstrap initialization, implemented the
  transactions feature and the theme/language switchers, wrote the tests,
  did a self-review pass, and drafted this README.
