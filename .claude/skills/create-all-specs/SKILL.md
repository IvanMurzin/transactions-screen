---
name: create-all-specs
description: Use to break an entire product into a complete set of decision-ready specs. Reads all docs/product/* files, proposes feature areas interactively (section by section), invokes ui-ux-pro-max for design docs, and creates all specs sequenced with proper dependencies. Run after create-product + setup-design-system. After this skill, every spec is at status "open" and ready for resolve-spec or mvp-orchestrator.
---

# create-all-specs

Transforms filled product docs into a complete, sequenced spec backlog.
Interactive: proposes feature areas one by one, asks for confirmation
or adjustments, then generates specs with full technical + design depth.

## When to run

After both:
1. `/create-product` — product docs filled
2. `/setup-design-system` — DS created (so specs can reference DS components)

## Pre-flight checks

1. All `docs/product/*.md` files are filled (not placeholder text).
2. `docs/design_system/system.md` exists (DS created).
3. No existing specs in `docs/specs/open/` that conflict (warn if any).

## Phase 1 — Product synthesis

Read ALL `docs/product/` files:
- `product_brief.md`, `audience_and_jtbd.md`, `problem_solution.md`
- `mvp_scope.md`, `business_model.md`, `metrics.md`, `roadmap.md`
- `retention.md`, `acquisition_and_growth.md`, `risks.md`

Produce a 5-sentence product summary the user can verify.

## Phase 2 — Feature area decomposition

Propose 5–10 feature areas based on the product. Common areas for
mobile apps (adjust to product):

1. **Foundation** — app shell, navigation structure, auth gate
2. **Auth** — sign-in, sign-up, password reset, OTP
3. **Onboarding** — first-run flow, permissions, profile setup
4. **Core feature A** — [derive from mvp_scope.md]
5. **Core feature B** — [derive from mvp_scope.md]
6. **Profile / Settings** — account management, preferences
7. **Subscription / Paywall** — RevenueCat flow, upgrade prompt
8. **Notifications** — push opt-in, notification center
9. **Analytics / Telemetry** — event instrumentation

For each proposed area, ask the user:
> Area N: **[Name]** — [1-sentence description].
> Sub-features: [list].
> Include as-is / adjust / split / skip?

Wait for confirmation before moving to the next area.

## Phase 3 — Design doc generation (per area, interactively)

For each confirmed area that has UI screens:

1. Invoke `ui-ux-pro-max` with:
   - Product context summary (from Phase 1)
   - Area name and sub-features
   - Available DS components (from `docs/design_system/system.md`)
   - Request: detailed screen wireframe descriptions, component usage,
     state variants, transitions, navigation flows

2. Save output to `docs/design_system/screens/<area-kebab>.md`.

3. Show the user a summary of screens + flows. Ask: "Looks good? Any
   changes before I write the specs?"

## Phase 4 — Spec creation (per area)

For each area, break into 1–3 SPEC files (one PR per spec):
- Foundation area → SPEC-0001 (if no existing specs)
- Auth area → SPEC-0002, SPEC-0003 (sign-in/up, password reset if complex)
- etc.

For each spec, fill the full `spec_template.md`:
- All frontmatter fields including `design_doc` pointing to the area doc
- `User scenarios` (Given/When/Then, min 2 per spec)
- `Functional requirements` (FR-001…, min 3)
- `Design requirements` — screens, DS components, state variants, l10n keys
- `Data model` — entities if applicable
- `Backend requirements` — if backend changes needed
- `Test requirements` — required unit + widget tests
- `Acceptance criteria` (min 3, including test AC)
- `Success criteria` (SC-001…)
- `depends_on` — set correctly (Foundation before Auth, Auth before everything user-gated)
- `status: open`

## Phase 5 — Sequencing review

After all specs are drafted, display a sequencing table:
```
ID        Title                    Priority  Depends on
SPEC-0001 Foundation shell         P0        —
SPEC-0002 Auth sign-in/sign-up     P0        SPEC-0001
SPEC-0003 Onboarding flow          P1        SPEC-0002
...
```

Ask: "Does this sequence look right? Any changes?"

Apply confirmed changes.

## Phase 6 — Write and index

1. Write all spec files to `docs/specs/open/feature/`.
2. Run `./scripts/update-spec-index.sh`.
3. Print final summary:

```
✅ Specs created: N total
   P0 (critical): N specs
   P1 (important): N specs
   P2 (normal): N specs

Next step: /mvp-orchestrator (implements P0 specs first)
       or: /resolve-spec SPEC-0001 (implement a specific spec)
```

## Spec file location convention (github/spec-kit style)

For simple specs: `docs/specs/open/feature/SPEC-XXXX-<kebab-title>.md`

For complex specs with data model or detailed design:
```
docs/specs/open/feature/SPEC-XXXX-<kebab-title>/
  spec.md
  data-model.md   (if entity-heavy)
  design.md       (copy of or link to area design doc)
```

Use folders when the spec has 2+ companion files.

## What it does NOT do

- Implement any code.
- Create BUG-#### or PROP-#### specs (those are created with `/create-spec`).
- Commit — all spec files are written but not committed.
