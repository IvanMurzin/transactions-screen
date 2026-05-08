---
name: mvp-orchestrator
description: Run a guarded MVP delivery loop from product/design docs to spec-authoring, implementation, review, checks, and local commits using this repository's SDD workflow.
allowed-tools: Read, Write, Edit, MultiEdit, Bash, Glob, Grep, Task
---

# mvp-orchestrator

Run an end-to-end MVP workflow as an orchestrator, not as a single
large coding pass.

## When to use

- Product docs are ready.
- Design system docs are ready.
- The user asks to move from docs to incremental MVP delivery.

## Orchestrator role

- Coordinate backlog slicing, spec authoring, implementation, review,
  and checks.
- Keep only one active implementation spec at a time.
- Persist progress in `.agent/state/mvp-orchestrator.json`.

## Hard constraints

1. Never implement without a spec.
2. Never run more than one implementation spec concurrently.
3. Never push automatically.
4. Never use destructive git or filesystem commands.
5. Keep each spec small enough for one local commit.
6. Stop on blockers or failed checks after two focused fix attempts.

## Phase flow

1. Orientation:
   read project docs, specs, scripts, and existing agents.
2. Backlog synthesis:
   produce small, dependency-ordered MVP specs.
3. Spec selection:
   pick one unblocked spec and move it to active state.
4. Pre-implementation review:
   validate scope, ACs, boundaries, and testability.
5. Implementation:
   delegate to a focused implementer role.
6. Review:
   classify findings as blocker / should-fix / nice-to-have.
7. Verification:
   run format, analyze, consistency, then relevant tests.
8. Commit:
   local commit only; update state and spec status.

## Subagent usage

- `sdd-backlog-planner` for MVP slicing and spec queue quality.
- `sdd-spec-reviewer` before implementation.
- `sdd-spec-implementer` for scoped code changes.
- `sdd-implementation-reviewer` after implementation.
- Domain specialists as needed:
  `flutter-architect`, `supabase-architect`, `core-ui-reviewer`.

## Required report shape

- Current phase and active spec.
- What was completed.
- Checks that ran and outcomes.
- Commit hash (if committed).
- Remaining risks and next spec.

