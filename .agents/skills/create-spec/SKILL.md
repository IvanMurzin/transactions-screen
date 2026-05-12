---
name: create-spec
description: Use to write one focused, decision-complete spec for a single feature, bug, or proposal you already understand. Asks only the necessary clarifying questions, classifies as SPEC-/BUG-/PROP-, assigns the next id, fills docs/sdd/spec_template.md (dependencies, AC, implementation notes, verification), and updates docs/specs/INDEX.md. Does not write code.
---

# create-spec

Drops a single decision-complete spec into `docs/specs/open/`. Use
when you already know what you want to change.

## When to use

- A bug you can describe in one paragraph.
- A small feature where the trade-offs are clear.
- A proposal / RFC for an architectural change.

For larger areas use `plan-feature`. For full product discovery use
`create-product`. For breaking an entire product into specs use
`create-all-specs`.

## How it behaves

1. **Classify.** Ask the user: feature, bug, or proposal? Validate
   that the answer matches the description.
2. **Pick id.** Scan `docs/specs/open/` and `docs/specs/closed/` for
   the highest existing number across all three prefixes; use
   `next + 1` with the appropriate prefix (`SPEC-`, `BUG-`, `PROP-`).
   Pad to 4 digits.
3. **Clarify.** Ask only what is genuinely unclear from the user's
   description — don't ritual-quiz them. Common gaps:
   - What's the smallest possible scope?
   - What's the observable outcome (for AC)?
   - Any backend / migration touch?
   - Any analytics impact?
   - Any product doc that motivates this?
4. **Design doc** — if the spec touches any UI screen:
   - Check if `docs/design_system/system.md` exists (DS created).
   - If DS not created: tell user to run `/setup-design-system` first.
   - Invoke `ui-ux-pro-max` with product context + spec description
     to produce screen wireframe descriptions, component list, state
     variants, and transition specs.
   - Save output to `docs/design_system/screens/<area>.md` (or
     `docs/specs/open/feature/<ID>-<title>/design.md` for spec-local docs).
   - Set `design_doc:` frontmatter to the saved path.
5. **Draft.** Fill `docs/sdd/spec_template.md` fully:
   - All frontmatter fields
   - User scenarios (Given/When/Then, min 2)
   - Functional requirements (FR-001…, min 3)
   - Design requirements section (filled from ui-ux-pro-max output)
   - Test requirements section (required test files)
   - Acceptance criteria (min 3, always include test + analyze ACs)
   - Success criteria (SC-001…)
   Mark unknowns as `[OPEN]` rather than guessing.
6. **Confirm.** Show the user the rendered spec; iterate until they
   accept it.
7. **Write.** Save to
   `docs/specs/open/<type>/<ID>-<kebab-title>.md`.
   Run `scripts/update-spec-index.sh`.

## Things you must NOT do

- Touch any source code.
- Combine two requests into one spec.
- Skip ACs because "it's obvious".
- Skip the design doc step for UI-touching specs.

## Output

- One new file under `docs/specs/open/<type>/`.
- Updated `docs/specs/INDEX.md`.
- A short summary with the new spec id, status, and next step
  (usually: "review, then `/resolve-spec <ID>`").

## Done when

- Frontmatter has every required field including `design_doc` if UI.
- User scenarios with Given/When/Then present.
- Functional requirements numbered FR-001…
- ACs are binary and observable (min 3, includes test + analyze ACs).
- Success criteria SC-001… present.
- `Open questions` section contains only items the user agreed to
  defer; otherwise the status is `draft`, not `open`.
