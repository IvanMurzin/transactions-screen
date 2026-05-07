# Components

Located in `client/lib/core_ui/components/`. Each component:

- Reads tokens via `context.dsColors / dsSpacing / dsTypography / …`.
- Has a domain-neutral name (no product nouns).
- Is exercised on `/design-system`.
- Has minimal API — surface only what's needed.

## When to add a new component

Add when:
- Two or more features need the same UI block.
- A feature needs a UI block that doesn't compose cleanly from the
  existing primitives.
- The DS reviewer (`core-ui-reviewer` subagent) flags an absence.

Don't add when:
- A single feature needs a one-off layout — keep it inside the feature.
- The variation is purely semantic (colors / labels) — parameterize
  an existing component.

## When to refactor a component

A component drifts when features start passing in raw `Color`s or
custom `TextStyle`s. That's the signal to add a variant or a token.

## Prop conventions

- Use `enum`s for variants (`DSButtonVariant.primary` etc.), not
  booleans.
- `bool isLoading`, `bool fullWidth`, `bool isDestructive` are common
  flags — keep names consistent across components.
- Callbacks: `onPressed`, `onChanged`, `onTap`. Nullable means
  disabled.
