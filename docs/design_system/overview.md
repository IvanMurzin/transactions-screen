# Design system

The template ships a **scaffold**, not a brand. It gives you:

- Token contracts (`DSColors`, `DSSpacing`, `DSRadius`, `DSElevation`,
  `DSTypography`) implemented as `ThemeExtension`s.
- A neutral light + dark palette so the app boots and looks decent.
- A small set of generic components (`DSButton`, `DSText`, `DSCard`,
  `DSAppBar`, `DSDialog`, `DSLoader`).
- A storybook-style preview page at `/design-system`.
- A `ThemeModeCubit` to toggle light/dark at runtime.

Replace the neutral palette with your own brand by editing
`_lightColors` and `_darkColors` in
`client/lib/core_ui/theme/app_theme.dart`. Add components by:

1. Drop a file under `client/lib/core_ui/components/`.
2. Read tokens via `context.dsColors / dsSpacing / …`.
3. Show it in `client/lib/core_ui/preview/ds_preview_page.dart`.

## Sub-pages

- [`tokens.md`](tokens.md) — what each token category means.
- [`components.md`](components.md) — when to add a new DS component vs
  reuse an existing one.
- [`theming.md`](theming.md) — how `ThemeData` is built from DS tokens.
- [`preview_route.md`](preview_route.md) — the role of
  `/design-system` in the workflow.
