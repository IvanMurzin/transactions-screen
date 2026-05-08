---
id: SPEC-XXXX
title: <imperative-mood title under 70 chars>
type: feature  # feature | bug | proposal
status: draft  # draft | open | planned | in_progress | blocked | review | done | closed | rejected
priority: P2   # P0 (critical) | P1 (important) | P2 (normal) | P3 (optional)
owner: <github-handle or "agent">
created: YYYY-MM-DD
updated: YYYY-MM-DD
depends_on: []   # ["SPEC-0003", "BUG-0007"]
blocks: []
related_specs: []
product_docs: []  # ["docs/product/mvp_scope.md#section"]
allowed_change_areas: []  # ["client/lib/features/auth/**", "test/features/auth/**"]
forbidden_change_areas: []  # ["backend/supabase/migrations/**", ".env*"]
---

# <Same as frontmatter title>

## Problem
What is broken, missing, or under-specified today? One paragraph, plain
language. Link to product docs that motivate the work.

## Goal
What changes after this spec ships, in one sentence. Frame the goal
from the user's perspective.

## Non-goals
What this spec explicitly does **not** do. Use this section to fence
scope creep early.

## Allowed change areas
Optional but recommended for orchestrated implementation. Keep explicit
path globs. Hook guards can enforce this.

- `client/lib/...`

## Forbidden change areas
Optional deny-list for risky zones that must stay untouched.

- `backend/supabase/migrations/...`

## User stories
- As a <role>, I can <capability>, so that <outcome>.

## Functional requirements
Bulleted list of behaviours the implementation must satisfy. Be
unambiguous; avoid the words "should" or "may" unless intentional.

## UX / UI requirements
- Routes touched.
- DS components used (or new ones to add).
- Localization keys (and that they exist in both `app_en.arb` and
  `app_ru.arb`).

## Backend requirements
- New / modified migrations.
- New / modified `api_*` RPC functions.
- New / modified edge function routes (with envelope shape).
- RLS implications.

## Frontend requirements
- New / modified features under `client/lib/{presentation,domain,data}`.
- New / modified DI registrations.

## Analytics requirements
Events to log, parameters, when they fire.

## Security / privacy / RLS requirements
- New PII handled?
- RLS posture changes?
- Secrets touched?

## Migration / data requirements
- Backfill needed?
- Idempotency story?

## Acceptance criteria
Use the AC template (see `acceptance_criteria_template.md`). Each AC
is testable and binary: it either passes or fails.

- [ ] AC-1: <observable outcome>
- [ ] AC-2: …

## Implementation plan
High-level approach in 5–10 bullets. Pull from `plan_template.md` if
the spec is large enough to warrant a separate plan file.

## Tasks
Optional, only if the implementation has more than ~5 atomic steps.
Use `tasks_template.md`.

## Verification
How a reviewer (or `resolve-spec`) confirms the change works:
- Manual checks.
- Commands to run (`flutter analyze`, etc.).
- Database queries.
- Smoke flows.

## Rollout notes
Feature flags, ordering with backend deploy, communication.

## Open questions
List with proposed defaults. The spec cannot move past `open` while
this section has unresolved entries.
