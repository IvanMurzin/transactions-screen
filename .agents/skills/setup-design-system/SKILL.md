---
name: setup-design-system
description: Use immediately after bootstrap + create-product to create the project's design system from scratch. Invokes ui-ux-pro-max with full product context to design a beautiful, brand-appropriate palette, typography, spacing, and component set. Writes all tokens and components into core_ui/. Run this before create-all-specs — specs require a DS to reference.
---

# setup-design-system

Creates the project's design system from scratch using `ui-ux-pro-max`.
The result is a complete, production-ready DS tailored to the product
— not a generic placeholder.

## When to run

After `bootstrap` (package renamed) **and** `create-product`
(product docs filled). Must run before any UI spec is implemented.

## Pre-flight checks

1. `docs/product/product_brief.md` exists and is filled (not template
   placeholder text).
2. `docs/product/audience_and_jtbd.md` exists and is filled.
3. `docs/product/mvp_scope.md` exists and is filled.
4. `client/lib/core_ui/theme/app_theme.dart` exists (template baseline).

If product docs are not filled, stop and tell the user to run
`/create-product` first.

## What it does

### Phase 1 — Product context extraction
Read and summarize:
- `docs/product/product_brief.md` — vision, tone, category
- `docs/product/audience_and_jtbd.md` — target user, emotional context
- `docs/product/mvp_scope.md` — what screens and flows exist

### Phase 2 — Design system design (ui-ux-pro-max)
Invoke `ui-ux-pro-max` with the product context summary and this
design brief:

> Design a complete, beautiful design system for this product. The DS
> must feel intentional — not generic Material defaults. Produce:
>
> **Tokens:**
> - Color palette: primary (with hover/pressed), secondary, neutrals
>   (50–950), semantic (success, warning, danger, info), background,
>   surface, surface-alt, text-primary/secondary/tertiary, on-primary, border
> - Dark mode counterparts for all above
> - Typography scale: display (56/64), h1 (40/48), h2 (32/40),
>   h3 (24/32), h4 (20/28), title (18/24), body (16/24), bodySmall
>   (14/20), label (12/16), caption (11/16) — font family, weight, LS
> - Spacing scale: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64
> - Border radius: small (4), medium (8), large (12), xl (16), full (9999)
> - Elevation: 0 (none), 1 (subtle card), 2 (modal/sheet), 3 (toast)
>
> **Components (Flutter/Material 3):**
> - DSButton: primary, secondary, ghost, danger, loading state, disabled
> - DSTextField: default, focused, error, disabled states
> - DSCard: default, pressable, outlined variants
> - DSAppBar: standard, with back button, transparent variant
> - DSBottomNavBar: tab items, active/inactive states
> - DSDialog: confirmation, info, destructive action variants
> - DSLoader: full-screen, inline, button-embedded
> - DSSnackBar: success, warning, error, info variants
> - DSAvatar: initials, image, sizes S/M/L
> - DSChip: filter, status, input variants
> - DSListTile: with/without leading/trailing widgets
> - DSEmptyState: illustration placeholder + CTA variant
>
> Provide: hex color values, font spec, component code in Dart/Flutter.
> The aesthetic must match the product's emotional tone. Make it look
> like a premium app, not a student project.

### Phase 3 — Write DS files
Based on ui-ux-pro-max output:

1. Write `client/lib/core_ui/theme/ds_theme.dart` — all `ThemeExtension`
   token classes (DSColors, DSSpacing, DSRadius, DSElevation, DSTypography).
2. Write `client/lib/core_ui/theme/app_theme.dart` — `lightTheme` and
   `darkTheme` wired from tokens.
3. Write `client/lib/core_ui/components/ds_button.dart`
4. Write `client/lib/core_ui/components/ds_text_field.dart`
5. Write `client/lib/core_ui/components/ds_card.dart`
6. Write `client/lib/core_ui/components/ds_app_bar.dart`
7. Write `client/lib/core_ui/components/ds_bottom_nav_bar.dart`
8. Write `client/lib/core_ui/components/ds_dialog.dart`
9. Write `client/lib/core_ui/components/ds_loader.dart`
10. Write `client/lib/core_ui/components/ds_snackbar.dart`
11. Write `client/lib/core_ui/components/ds_avatar.dart`
12. Write `client/lib/core_ui/components/ds_chip.dart`
13. Write `client/lib/core_ui/components/ds_list_tile.dart`
14. Write `client/lib/core_ui/components/ds_empty_state.dart`
15. Write `client/lib/core_ui/preview/ds_preview_page.dart` — shows
    every component in all variants (light + dark side-by-side).
16. Re-add `/design-system` route to `app_router.dart` and
    `AppRoutes.designSystem` constant to `app_routes.dart`.

### Phase 4 — Verify
1. `dart run build_runner build --delete-conflicting-outputs` (if needed)
2. `dart format .` from `client/` — must pass
3. `flutter analyze` — must pass

### Phase 5 — Document
Write `docs/design_system/system.md`:
- Color palette swatch table (name → light hex → dark hex)
- Typography scale table
- Spacing + radius + elevation tables
- Component inventory with usage notes

Update `docs/design_system/overview.md` to reference `system.md`.

## Output

```
✅ Design system created
   Tokens: client/lib/core_ui/theme/ds_theme.dart
   Theme:  client/lib/core_ui/theme/app_theme.dart
   Components (14): ds_button, ds_text_field, ds_card, ds_app_bar,
     ds_bottom_nav_bar, ds_dialog, ds_loader, ds_snackbar, ds_avatar,
     ds_chip, ds_list_tile, ds_empty_state
   Preview: /design-system route
   Docs:   docs/design_system/system.md

Next step: /create-all-specs
```

## What it does NOT do

- Implement screens or features — that's the job of individual specs.
- Change backend code.
- Commit — user must commit manually or via orchestrator.
