---
name: plan-feature
description: Use to break a product area into a sequenced set of decision-complete specs. Reads docs/product/* as source of truth, conducts a clarifying interview, distinguishes features/bugs/proposals, defines dependencies and priorities, fills frontend/backend/design/analytics/testing/release sections, and creates SPEC-####/BUG-####/PROP-#### files in docs/specs/open/. Does not write code.
---

# plan-feature

Turns a product area or epic into a sequence of small, implementable
specs. Plans, never codes.

## When to use

- Starting a multi-week feature area.
- Translating a roadmap bet from `docs/product/roadmap.md` into
  concrete work.
- Re-planning when product direction shifts.

## How it behaves

1. **Anchor.** Read `docs/product/{product_brief, mvp_scope, metrics,
   roadmap}.md`. Restate the area in 2-3 sentences and confirm with
   the user before continuing.
2. **Decompose.** Break the area into 3-10 atomic units. Each unit
   should be implementable in a single PR.
3. **Classify.** Each unit becomes a feature (`SPEC-`), bug (`BUG-`),
   or proposal (`PROP-`). Improvements that touch architecture get
   `PROP-` so they pass through review first.
4. **Sequence.** For each unit, define `depends_on`, `blocks`,
   priority. Catch circular deps.
5. **Fill the spec.** For each unit, populate the full
   `docs/sdd/spec_template.md` — including backend, frontend, design,
   analytics, security, migration, AC, plan, verification, rollout.
6. **Confirm.** Show the user the list of new specs and any open
   questions before writing files.
7. **Write.** Create files under `docs/specs/open/<type>/`. Run
   `scripts/update-spec-index.sh`.

## Things you must push back on

- "Just do all of it" → cap unit size at one PR.
- Specs without acceptance criteria.
- Specs that change architecture without a PROP- review.

## Things you must NOT do

- Touch any source code.
- Mix two distinct features into one spec.
- Use vague AC ("works well", "is fast").

## Output

- N new files in `docs/specs/open/<type>/`.
- Updated `docs/specs/INDEX.md`.
- A summary message listing the specs in suggested execution order
  with their dependencies.

## Done when

- Each new spec passes the spec-reviewer checklist (frontmatter
  complete, ACs binary, dependencies correct).
- `INDEX.md` reflects the new specs.
- The user confirms the sequence before any spec leaves `draft`.
