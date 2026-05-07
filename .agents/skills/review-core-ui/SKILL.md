---
name: review-core-ui
description: Use to audit the design system in client/lib/core_ui/ for completeness, coherence, and adoption. Verifies tokens exist, theme works in light and dark modes, components are discoverable on the DS Preview route, and feature code uses DS components instead of ad-hoc styling. Produces a report and optionally fixes safe issues.
---

# review-core-ui

Audits `client/lib/core_ui/` and feature code that consumes it. Goal:
catch design-system drift before it becomes a refactor.

## When to use

- Before starting a UI-heavy feature.
- After landing several features that touched the design system.
- Quarterly DS health check.

## What it inspects

### Tokens

- All semantic colors used by features exist as `DSColors` fields
  (no raw `Color(0x…)` in `presentation/`).
- Spacing, radius, elevation, typography tokens cover what features
  actually need; flag missing ones rather than letting features
  hardcode.
- Light and dark mode both define every token in `app_theme.dart`.

### Theme

- `lightTheme` and `darkTheme` are wired through `MaterialApp.router`
  and switch via `ThemeModeCubit`.
- `ColorScheme` mappings make sense — e.g. `error` → `colors.danger`.

### Components

- Each file in `core_ui/components/` is exported and shows up on the
  `/design-system` preview route.
- No two components solve the same problem. Flag duplicates.
- Component APIs are domain-neutral (no `account`, `subaccount`,
  `crypto`, etc. in widget names).

### DS preview

- The route exists at `/design-system` in `core/routing/app_routes.dart`.
- It exercises every component in light and dark.
- A theme switcher is present.

### Feature adoption

- Grep `presentation/` for direct `Color(0x…)`, `Padding(EdgeInsets`
  with raw numbers, custom `TextStyle`. Each occurrence is a finding.
- Flag features importing Material directly when a DS component would
  do.

## What it produces

A report with three sections:

1. **Findings** — concrete violations with file paths and line ranges.
2. **Fixes the agent applied** — only safe, mechanical changes
   (renaming a hardcoded color to a token, replacing a Material
   widget with the DS equivalent that has the same API).
3. **Recommendations** — anything that needs a human decision (e.g.
   "we have three dialog variants, pick one").

## What it does NOT do

- Invent a brand or visual identity.
- Add new DS components without an explicit request.
- Touch product-specific design tokens (colors, copy).
