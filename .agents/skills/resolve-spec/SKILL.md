---
name: resolve-spec
description: Use to implement one existing spec end-to-end. Takes a spec id (SPEC-####, BUG-####, PROP-####), reads the spec and its product/architecture references, verifies it is ready, creates a branch, implements only what the spec promises, runs format, analyze, and tests, regenerates the spec index, and produces a completion report. Does not commit or merge unless the user explicitly asks.
---

# resolve-spec

Implements one existing spec on a branch and leaves the working tree
ready for human review.

## Inputs

- Spec id (e.g. `SPEC-0007`, `BUG-0042`, `PROP-0019`).

## Pre-flight checks

1. Spec file exists in `docs/specs/open/<type>/`.
2. Spec status is `Ready`, `Planned`, or `Open` (or `In Progress` if resuming).
   If `Draft`, refuse and ask the user to finalize the spec first.
3. All `depends_on` specs are `done` or `closed`. Refuse otherwise.
4. Working tree is clean. Refuse otherwise.
5. If the spec has a `design_doc` field, verify the file exists. If it
   doesn't, run `/setup-design-system` or ask the user to create it first.

## What it does

1. **Read.** Spec body + every linked product doc + relevant
   architecture docs (`docs/architecture/`, `docs/client/`,
   `docs/backend/`). If `design_doc` is set, read it fully before
   writing any UI code.
2. **Branch.** `git checkout -b spec/<ID>-<kebab-title>`.
3. **Update spec.** Set frontmatter `status: in_progress` and
   `updated:` to today.
4. **Implement.** Stay inside the spec's scope. Touch only the files
   the spec implies. Cubit-first; ARB-only strings; DS components for
   UI; `api_*` RPC for new endpoints; migrations for schema.
5. **Write tests.** For every new Cubit, write unit tests in
   `client/test/presentation/<feature>/`. For every new Page, write
   a widget smoke test. See `Test requirements` section in spec.
6. **Regenerate.** If `@injectable` annotations changed, run
   `dart run build_runner build --delete-conflicting-outputs`.
7. **Verify.** Run in order from `client/`:
   a. `dart format .` — must exit clean.
   b. `flutter analyze` — must exit clean.
   c. `flutter test` — must exit clean (zero failures).
   If any step fails, fix the error and retry **once**. On second
   failure of the same error, STOP: mark spec `blocked`, explain the
   error to the user, and do NOT attempt workarounds.
8. **Spec index.** Set spec status to `review`, run
   `scripts/update-spec-index.sh`.
9. **Report.** Print a completion report:
   - Branch name.
   - Files added / modified.
   - Acceptance criteria with check/cross marks.
   - Test files written.
   - Manual verification steps still needed.
   - Whether `INDEX.md` was regenerated.

## Max-retry rule

If the same error (same file + same error message) occurs **twice** in a row:
- STOP immediately.
- Do **NOT** read tool source code, add experimental flags, or try
  alternative commands.
- Mark spec `blocked`.
- Report the exact error to the user and wait for instructions.

## What it does NOT do

- Commit. Only if the user says "commit", create a commit with
  message `spec(<ID>): <imperative summary>`.
- Merge. Only if the user says "merge", merge into `main`.
- Push. Only if the user says "push".
- Refactor adjacent code that the spec did not request.
- Read `build_runner` source, add `--experimental` flags, or attempt
  workarounds when a tool fails twice.

## Things you must push back on

- "Also fix this other thing while you're in there" → that's a new
  spec. Note it; resume the original work.
- An AC that turns out to be impossible → stop, set spec status to
  `blocked`, write a clear blocker explanation, ask the user.

## Done when

- Every AC is satisfied (or accurately marked unsatisfied with a reason).
- `dart format .` + `flutter analyze` + `flutter test` all clean.
- Test files written per `Test requirements` section of spec.
- Spec status is `review`.
- `INDEX.md` regenerated.
- Working tree contains all changes, uncommitted by default.
