---
name: mvp-orchestrator
description: Run a guarded MVP delivery loop from product/design docs to spec-authoring, implementation, review, checks, and local commits using this repository's SDD workflow.
allowed-tools: Read, Write, Edit, MultiEdit, Bash, Glob, Grep, Task
---

# mvp-orchestrator

Run an end-to-end MVP workflow as an orchestrator, not as a single
large coding pass.

## When to use

- Product docs are ready (`docs/product/` filled).
- Design system is ready (`docs/design_system/system.md` exists).
- Specs exist in `docs/specs/open/` at `open` or `planned` status.
- The user asks to move from docs to incremental MVP delivery.

## Pre-flight checks

1. `docs/design_system/system.md` exists and is not a placeholder.
   If missing → stop, tell user to run `/setup-design-system` first.
2. At least one spec exists in `docs/specs/open/`.
   If none → tell user to run `/create-all-specs` first.
3. Check state file `.agent/state/mvp-orchestrator.json`:
   - If `design_system_ready` is false → run `/setup-design-system`.
   - If `current_spec` is set (in-progress session) → resume that spec.

## Orchestrator role

- Coordinate spec selection, implementation, review, and checks.
- Keep only one active implementation spec at a time.
- Persist progress in `.agent/state/mvp-orchestrator.json`.
- Track per-step retry counts to detect loops.

## Hard constraints

1. Never implement without a spec.
2. Never implement a UI spec without `design_doc` set in frontmatter
   and the design doc file existing.
3. Never run more than one implementation spec concurrently.
4. Never push automatically.
5. Never use destructive git or filesystem commands.
6. Keep each spec small enough for one local commit.
7. **Loop detection:** if the same error recurs in the same step twice,
   mark spec `blocked`, record it in `blocked_specs`, move to next spec.
   Do NOT read tool source code or add experimental flags.

## State file schema

```json
{
  "mode": "mvp-orchestrator",
  "product_docs_ready": true,
  "design_system_ready": true,
  "current_phase": "idle",
  "current_spec": null,
  "current_branch": null,
  "batch_limit": 1,
  "completed_specs": [],
  "blocked_specs": [],
  "retry_counts": {},
  "last_commit": null,
  "last_checks": [],
  "notes": []
}
```

`retry_counts` tracks `"<SPEC-ID>:<step>": <count>`. When count reaches
2 for any key → trigger the loop-detection hard stop.

## Phase flow

1. **Orientation:**
   Read project docs, specs, state file, and existing agents.
   Verify pre-flight checks.

2. **Spec selection:**
   Pick the highest-priority unblocked spec from `docs/specs/open/`.
   Priority order: P0 → P1 → P2 → P3.
   Respect `depends_on` — only pick specs whose dependencies are `done`.
   For UI specs: confirm `design_doc` exists.

3. **Pre-implementation review:**
   Delegate to `sdd-spec-reviewer` subagent.
   Validate scope, ACs, DS component references, test requirements.
   If spec is `draft` → refuse, ask user to finalize.

4. **Implementation:**
   Delegate to `sdd-spec-implementer` subagent.
   Implementer must: stay in spec scope, write required tests,
   run `dart format` + `flutter analyze` + `flutter test`.

5. **Review:**
   Delegate to `sdd-implementation-reviewer` subagent.
   Classify findings: blocker / should-fix / nice-to-have.
   Blockers → fix immediately; nice-to-haves → log and continue.

6. **Verification (run from `client/`):**
   a. `dart format .` — must pass
   b. `flutter analyze` — must pass
   c. `flutter test` — must pass
   If any fails: increment `retry_counts["<ID>:verify"]`. On second
   failure → mark spec `blocked`, stop, report to user.

7. **Commit:**
   Local commit only: `spec(<ID>): <summary>`.
   Update `current_spec` → null, append to `completed_specs`,
   reset retry_counts for this spec.

## Subagent usage

- `sdd-backlog-planner` — for MVP slicing if specs need refinement.
- `sdd-spec-reviewer` — before implementation.
- `sdd-spec-implementer` — scoped code changes.
- `sdd-implementation-reviewer` — after implementation.
- `flutter-architect`, `supabase-architect`, `core-ui-reviewer` — domain review.

## Required report shape

- Current phase and active spec.
- What was completed.
- Checks that ran and outcomes (format / analyze / test: pass/fail).
- Commit hash (if committed).
- Blocked specs and reasons.
- Next spec to implement.
