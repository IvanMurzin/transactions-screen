# How to use spec-driven development in this template

Spec-driven development (SDD) is the only way changes get made in this
codebase. Every bug, improvement, or feature passes through a written
spec before any code is touched. The spec is the contract; the code is
its execution.

## The loop

```
            ┌─────────────────────────────────────────┐
            ▼                                         │
   create-spec / plan-feature ──► review ──► resolve-spec ──► closed/
                                  (manual)        │
                                                  ▼
                                             deploy + retro
```

1. **Capture intent.** Use the `create-spec` skill for a single
   change you already understand, or `plan-feature` to break a larger
   piece of product work into multiple specs.
2. **Review.** A human reads the spec, sharpens the acceptance
   criteria, and either marks it `Ready` or sends it back to `Draft`.
3. **Implement.** Run `resolve-spec SPEC-####`. The agent creates a
   branch, implements only what the spec promises, runs format +
   analyze, and produces a completion report.
4. **Close.** Move the spec from `open/` to `closed/`, update
   `INDEX.md`, commit with `spec(SPEC-####): <summary>`.

## Files

- `constitution.md` — non-negotiables for the codebase.
- `spec_lifecycle.md` — statuses and how to move between them.
- `spec_template.md`, `plan_template.md`, `tasks_template.md`,
  `acceptance_criteria_template.md` — the actual templates skills use.
- `definition_of_done.md` — the bar a spec must clear before it moves
  to `closed/`.

## Where specs live

```
docs/specs/
  open/
    features/     # SPEC-####  — new product capability
    bugs/         # BUG-####   — incorrect behavior in shipped code
    proposals/    # PROP-####  — improvement / RFC, may turn into a SPEC
  closed/
    features/
    bugs/
    proposals/
  archive/        # withdrawn or superseded specs
  INDEX.md        # generated table of every spec
  README.md       # workflow doc
```

## Hard rules

- Never start coding without a spec in `open/` whose status is `Ready`
  or `In Progress`.
- Never mutate a closed spec. If the change needs revisiting, open a
  new spec that supersedes it.
- The agent owns the implementation, but a human owns the **decision**
  to merge. `resolve-spec` leaves the working tree ready for review,
  not committed, unless you explicitly ask otherwise.
