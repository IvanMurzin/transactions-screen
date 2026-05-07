# DS Preview route

`/design-system` renders every reusable component in light + dark.
It exists for three reasons:

1. **Discoverability for agents and devs.** When a spec needs UI, the
   first stop is the preview route — does the component already
   exist?
2. **Visual regression catch.** A change to a token cascades; the
   preview shows the impact in one place.
3. **Onboarding.** New developers get a one-screen tour of the DS.

## Maintaining it

Every new component added to `core_ui/components/` must show up on
the preview page. This is enforced by the `core-ui-reviewer`
subagent and (less strictly) the `check-ai-consistency` script.

## Structure

The page is a `SingleChildScrollView` of `_Section` widgets. Each
section has a title and a `child` showing the component(s) in
relevant states. Keep content domain-neutral — use lorem-ipsum-style
placeholder text, never real product copy.

## Theme switcher

Top-right of the preview app bar is a switch that flips the theme via
`ThemeModeCubit`. Reviewers use it to check dark mode.
