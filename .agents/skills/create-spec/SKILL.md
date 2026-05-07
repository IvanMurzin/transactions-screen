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
`create-product`.

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
4. **Draft.** Fill `docs/sdd/spec_template.md` with everything you
   know. Mark unknowns as `[OPEN]` rather than guessing.
5. **Confirm.** Show the user the rendered spec; iterate until they
   accept it.
6. **Write.** Save to
   `docs/specs/open/<type>/<ID>-<kebab-title>.md`.
   Run `scripts/update-spec-index.sh`.

## Things you must NOT do

- Touch any source code.
- Combine two requests into one spec.
- Skip ACs because "it's obvious".

## Output

- One new file under `docs/specs/open/<type>/`.
- Updated `docs/specs/INDEX.md`.
- A short summary with the new spec id, status, and next step
  (usually: "review, then `/resolve-spec <ID>`").

## Done when

- Frontmatter has every required field (id, title, type, status,
  priority, owner, created, updated).
- ACs are binary and observable.
- `Open questions` section contains only items the user agreed to
  defer; otherwise the status is `draft`, not `open`.
