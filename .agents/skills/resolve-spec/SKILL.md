---
name: resolve-spec
description: Use to implement one existing spec end-to-end. Takes a spec id (SPEC-####, BUG-####, PROP-####), reads the spec and its product/architecture references, verifies it is ready, creates a branch, implements only what the spec promises, runs format and analyze, regenerates the spec index, and produces a completion report. Does not commit or merge unless the user explicitly asks.
---

# resolve-spec

Implements one existing spec on a branch and leaves the working tree
ready for human review.

## Inputs

- Spec id (e.g. `SPEC-0007`, `BUG-0042`, `PROP-0019`).

## Pre-flight checks

1. Spec file exists in `docs/specs/open/<type>/`.
2. Spec status is `Ready` or `Planned` (or `In Progress` if resuming).
   If `Draft`, refuse and ask the user to finalize the spec first.
3. All `depends_on` specs are `done` or `closed`. Refuse otherwise.
4. Working tree is clean. Refuse otherwise.

## What it does

1. **Read.** Spec body + every linked product doc + relevant
   architecture docs (`docs/architecture/`, `docs/client/`,
   `docs/backend/`).
2. **Branch.** `git checkout -b spec/<ID>-<kebab-title>`.
3. **Update spec.** Set frontmatter `status: in_progress` and
   `updated:` to today.
4. **Implement.** Stay inside the spec's scope. Touch only the files
   the spec implies. Cubit-first; ARB-only strings; DS components for
   UI; `api_*` RPC for new endpoints; migrations for schema.
5. **Regenerate.** If `@injectable` annotations changed, run
   `dart run build_runner build --delete-conflicting-outputs`.
6. **Verify.** Run `dart format .` and `flutter analyze` from
   `client/`. Both must exit clean.
7. **Spec index.** Set spec status to `review`, run
   `scripts/update-spec-index.sh`.
8. **Report.** Print a completion report:
   - Branch name.
   - Files added / modified.
   - Acceptance criteria with check/cross marks.
   - Manual verification steps still needed.
   - Whether `INDEX.md` was regenerated.

## What it does NOT do

- Run the full test suite (unless the spec explicitly requires it).
- Commit. Only if the user says "commit", create a commit with
  message `spec(<ID>): <imperative summary>`.
- Merge. Only if the user says "merge", merge into `main`.
- Push. Only if the user says "push".
- Refactor adjacent code that the spec did not request.

## Things you must push back on

- "Also fix this other thing while you're in there" → that's a new
  spec. Note it; resume the original work.
- An AC that turns out to be impossible → stop, set spec status to
  `blocked`, write a clear blocker explanation, ask the user.

## Done when

- Every AC is satisfied (or accurately marked unsatisfied with a
  reason).
- Format + analyze clean.
- Spec status is `review`.
- `INDEX.md` regenerated.
- Working tree contains all changes, uncommitted by default.
