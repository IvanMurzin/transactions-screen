# Tokens

All tokens are `ThemeExtension`s registered in `app_theme.dart` and
read via `context.<dsX>`.

## DSColors

Semantic colors (not raw palette swatches). Categories:

- **primary / onPrimary / primaryHover** — brand accent.
- **background / surface / surfaceAlt** — page and card backgrounds.
- **textPrimary / textSecondary / textTertiary / textOnPrimary** —
  type colors.
- **border** — divider / outline color.
- **success / warning / danger / info** — status accents.
- **neutral0…neutral950** — the underlying greyscale ramp. Use these
  sparingly; prefer the semantic names above.

## DSSpacing

Steps: `s4, s8, s12, s16, s24, s32`. No raw `EdgeInsets` numbers in
features.

## DSRadius

Steps: `r8, r12, r16`. Stick to these; if a feature needs a
different radius it's a sign the DS is missing a token.

## DSElevation

Levels: `e0` (flat), `e1` (cards), `e2` (dialogs / modals). Each is a
`List<BoxShadow>`.

## DSTypography

Slots: `h1, h2, h3, body, caption, button, label, totalNumeric`.
`totalNumeric` uses tabular figures for aligned numbers.

## Adding a token

A new token belongs in `DSColors` / `DSSpacing` / `DSTypography` if
multiple components or features will use it. If only one component
needs it, hardcode it in that component instead — promote later when
a second use case appears.
