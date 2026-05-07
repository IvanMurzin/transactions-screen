# Documentation index

Source of truth lives in code. These docs make the conventions
discoverable; treat them as authoritative when they match the code,
and update them when they don't.

## What goes where

| Section | Purpose |
| ------- | ------- |
| [`product/`](product/README.md) | Why the product exists and for whom. |
| [`architecture/`](architecture/overview.md) | How client + backend + integrations fit together. Includes [`patterns/`](architecture/patterns/README.md) for opt-in design patterns (auth guard, RevenueCat). |
| [`client/`](client/architecture.md) | Flutter conventions, recipes, and gotchas. See [`auth_profile_subscriptions.md`](client/auth_profile_subscriptions.md) for the universal modules shipped with the template. |
| [`backend/`](backend/overview.md) | Supabase conventions, migrations, RLS, edge functions. |
| [`contracts/`](contracts/api-surface.md) | Live API surface — every shipped edge-function route. |
| [`design_system/`](design_system/overview.md) | DS contracts, tokens, components, preview route. |
| [`configuration/`](configuration/flavors.md) | Flavors, env vars, integration setup. |
| [`agent_workflows/`](agent_workflows/using_skills.md) | Skills, hooks, Claude/Codex parity. |
| [`sdd/`](sdd/how_to_use_sdd.md) | Spec-driven development: constitution, lifecycle, templates, DoD. |
| [`specs/`](specs/README.md) | Open / closed / archived spec files + auto-generated INDEX. |
| [`troubleshooting.md`](troubleshooting.md) | Common bootstrap, build, and deploy failures. |

## Where to start

- New to the repo? Read `architecture/overview.md`, then
  `client/architecture.md` and `backend/overview.md`.
- New to SDD? Read `sdd/how_to_use_sdd.md` and skim
  `sdd/spec_template.md`.
- Setting up a fresh project? Run `./scripts/bootstrap.sh`, then read
  `configuration/env_and_configs.md` for the keys to fill, then
  `client/auth_profile_subscriptions.md` for what already works
  out of the box.
- Stuck on a build / deploy step? Check `troubleshooting.md` before
  grepping through the source.
