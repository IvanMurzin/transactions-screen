# sdd_template: 0 → MVP Guide

Flutter + Supabase starter with strict Spec-Driven Development (SDD).
This README is a practical runbook: from empty clone to working MVP.

## Project description

`sdd_template` is a production-oriented template for mobile products on
Flutter + Supabase. It is designed for teams that want predictable MVP
delivery through small specs, strict architecture boundaries, and
repeatable verification.

The template gives you:
- a ready client/backend foundation
- built-in SDD process and documentation contracts
- AI-assisted workflows (Claude/Codex) with guard rails
- a safe path from product docs to incremental local commits

Result: you build MVP as a sequence of small, reviewable vertical
slices instead of one large rewrite.

## 1) What this template gives you

- Flutter client (iOS/Android), `flutter_bloc`, `go_router`,
  `get_it`/`injectable`, design-system scaffold, EN/RU localization.
- Supabase backend with RLS-first model + Edge Functions + RPC pattern.
- Prepared integrations (Firebase/RevenueCat), disabled by default.
- SDD workflow with specs, lifecycle, templates, and index tooling.
- AI workflows for Claude (`.claude/*`) and Codex (`.agents/*`) with
  parity checks.

## 2) Prerequisites

- Flutter SDK pinned in [`.fvmrc`](.fvmrc) (`3.38.7`).
- Dart/Flutter compatible with `client/pubspec.yaml`.
- Supabase CLI (for local/db workflows).
- Optional but recommended: FVM.

```bash
dart pub global activate fvm
fvm install 3.38.7
```

## 3) Bootstrap a new app (day 0)

Do not develop inside this template repo. Clone into a new project dir.

```bash
git clone <YOUR_TEMPLATE_REPO_URL> ~/projects/myapp
cd ~/projects/myapp
./scripts/bootstrap.sh --app-name "My App" --app-id com.acme.myapp --reinit-git
```

What bootstrap does:
- renames package/bundle ids
- scaffolds flavor configs
- runs `flutter pub get` + codegen
- runs format/analyze
- reinitializes git and creates first commit

## 4) Configure secrets and env

Fill local untracked files from examples:

- `.config.dev.json`
- `.config.prod.json`
- `.env`

Reference: [docs/configuration/env_and_configs.md](docs/configuration/env_and_configs.md)

Hard rules:
- never commit real keys/secrets
- keep only placeholders in tracked files

## 5) Initialize product and design docs (before feature coding)

You need product truth first, then specs.

Recommended sequence:
1. `create-product` skill → fill `docs/product/*`
2. verify/adjust `docs/design_system/*` and architecture docs
3. only then start implementation specs

Useful docs:
- [docs/README.md](docs/README.md)
- [docs/architecture/overview.md](docs/architecture/overview.md)
- [docs/sdd/how_to_use_sdd.md](docs/sdd/how_to_use_sdd.md)

## 6) Spec workflow (core rule: no implementation without spec)

Spec directories:
- `docs/specs/open/*`
- `docs/specs/closed/*`
- `docs/specs/archive/*`
- `docs/specs/INDEX.md`

Lifecycle:
`draft → open → planned → in_progress → review → done`

References:
- [docs/specs/README.md](docs/specs/README.md)
- [docs/sdd/spec_lifecycle.md](docs/sdd/spec_lifecycle.md)
- [docs/sdd/spec_template.md](docs/sdd/spec_template.md)

## 7) MVP orchestration mode

This repo includes `mvp-orchestrator` skill and dedicated subagents:

- `sdd-backlog-planner`
- `sdd-spec-implementer`
- `sdd-implementation-reviewer`
- plus architecture/design reviewers

State file:
- `.agent/state/mvp-orchestrator.json`

### Start command (single-spec batch)

Use this instruction in Claude/Codex:

```text
/mvp-orchestrator

Product docs and design system docs are already prepared.

Run the MVP SDD workflow.
- create missing MVP specs if needed
- review specs before implementation
- implement max 1 spec in this run
- run checks
- make one local commit
- do not push
- stop on blocker
```

### Continue command (multi-spec batch)

```text
/mvp-orchestrator

Continue from .agent/state/mvp-orchestrator.json.
Implement max 3 specs.
One spec = one branch = one local commit.
Stop on first blocker.
Do not push.
```

## 8) Guard rails (hooks + permissions)

Configured in `.claude/settings.json`:

- `PreToolUse` guards:
  - require active spec for code edits (`client/lib`, `backend`)
  - enforce spec scope via `allowed_change_areas`
- `Stop` hook:
  - runs `scripts/check-ai-consistency.sh`

Hook scripts:
- `scripts/hooks/require-active-spec.sh`
- `scripts/hooks/guard-spec-scope.sh`

## 9) How to write specs so guards work well

In spec frontmatter, fill:

```yaml
allowed_change_areas:
  - client/lib/features/auth/**
  - test/features/auth/**
forbidden_change_areas:
  - backend/supabase/migrations/**
  - .env*
```

This gives deterministic scope enforcement during implementation.

## 10) UI quality mode

Added skill: `ui-ux-pro-max` (synced for Claude + Codex).

Use it when task changes UI behavior/structure/quality:
- new screens
- component refactors
- usability/a11y cleanup
- design-system consistency review

Source: [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)

## 11) Verification commands

From repo root:

```bash
./scripts/format.sh
./scripts/analyze.sh
./scripts/check-ai-consistency.sh
./scripts/check.sh
./scripts/update-spec-index.sh
```

From `client/`:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run --flavor dev --dart-define-from-file=../.config.dev.json
```

## 12) Git policy

- one spec = one branch = one PR
- branch naming: `spec/SPEC-0001-short-title`
- commit format: `spec(SPEC-####): <imperative summary>`
- never auto-push to `main`
- no force push

## 13) Suggested path to first working MVP

1. Setup + bootstrap + env config
2. Product docs completed
3. Design system docs confirmed
4. Build MVP backlog (`plan-feature` / orchestrator backlog phase)
5. Implement first vertical slice (1 spec)
6. Run checks, commit locally
7. Repeat spec-by-spec until MVP scope is complete

Keep batches small. Stable cadence beats big rewrites.

## 14) Quick links

- [AGENTS.md](AGENTS.md)
- [CLAUDE.md](CLAUDE.md)
- [docs/README.md](docs/README.md)
- [docs/troubleshooting.md](docs/troubleshooting.md)
- [docs/contracts/api-surface.md](docs/contracts/api-surface.md)
