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

For breaking the **entire product** into all specs, use `create-all-specs`.

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
5. **Design docs** — for each unit that touches UI screens:
   - Check if `docs/design_system/system.md` exists (DS created).
   - If DS not created: tell user to run `/setup-design-system` first.
   - Invoke `ui-ux-pro-max` with product context + unit description
     to generate screen wireframe descriptions, component list,
     state variants, and transition specs.
   - Save output to `docs/design_system/screens/<area>.md`.
   - Set `design_doc:` in each affected spec's frontmatter.
6. **Fill the spec.** For each unit, populate the full
   `docs/sdd/spec_template.md`:
   - All frontmatter fields including `design_doc`
   - User scenarios (Given/When/Then, min 2 per spec)
   - Functional requirements (FR-001…, min 3)
   - Design requirements section (filled from ui-ux-pro-max output)
   - Test requirements section (required unit + widget test files)
   - Acceptance criteria (min 3, includes test + analyze ACs)
   - Success criteria (SC-001…)
   - Backend, analytics, security, migration sections
7. **Confirm.** Show the user the list of new specs and any open
   questions before writing files.
8. **Write.** Create files under `docs/specs/open/<type>/`. Run
   `scripts/update-spec-index.sh`.

## Things you must push back on

- "Just do all of it" → cap unit size at one PR.
- Specs without acceptance criteria.
- Specs that change architecture without a PROP- review.
- UI-touching specs without a design doc (run `ui-ux-pro-max` first).

## Things you must NOT do

- Touch any source code.
- Mix two distinct features into one spec.
- Use vague AC ("works well", "is fast").
- Skip the design doc step for UI-touching specs.

## Output

- N new files in `docs/specs/open/<type>/`.
- Updated `docs/specs/INDEX.md`.
- A summary message listing the specs in suggested execution order
  with their dependencies.

## Done when

- Each new spec passes the spec-reviewer checklist (frontmatter
  complete, ACs binary, dependencies correct, design_doc set for UI specs).
- `INDEX.md` reflects the new specs.
- The user confirms the sequence before any spec leaves `draft`.
