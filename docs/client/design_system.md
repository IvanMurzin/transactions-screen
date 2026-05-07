# Design system (client view)

For DS architecture, tokens, and component contracts see
[`../design_system/overview.md`](../design_system/overview.md).

## Quick rules for feature work

- Read tokens via `context.dsColors`, `dsSpacing`, `dsRadius`,
  `dsTypography`, `dsElevation`. Never hardcode `Color(0x…)` or
  `EdgeInsets.all(16)`.
- Use `core_ui/components/*` widgets. If the component you need
  doesn't exist, propose one via PROP- spec rather than building it
  ad-hoc inside a feature.
- Add new components to `core_ui/preview/ds_preview_page.dart` so
  agents and reviewers can find them.
- Light + dark must both look right. Dark is not "invert the colors";
  it's a separate palette in `app_theme.dart`.
