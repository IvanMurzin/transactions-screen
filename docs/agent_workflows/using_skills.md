# Using skills

Skills are slash-style helpers that encapsulate a workflow. The same
skills exist for both Claude Code (`.claude/skills/`) and Codex
(`.agents/skills/`); their content is kept in sync by the
`check-ai-consistency` skill + script.

## Available skills

| Skill | When to use |
| ----- | ----------- |
| `bootstrap` | Right after copying the template into a new dir. |
| `create-product` | Filling `docs/product/*` from a rough vision. |
| `review-core-ui` | Auditing the design system for gaps and violations. |
| `plan-feature` | Breaking a product area into multiple specs. |
| `create-spec` | Writing one focused, decision-complete spec. |
| `resolve-spec` | Implementing an existing spec end-to-end. |
| `check-ai-consistency` | Verifying the AI workflow files agree. |

## Invoking

In Claude Code: `/<skill-name>` (or just describe the task and let the
matcher pick the skill).

In Codex: invoke as a skill via the same name; behavior is described
in the skill's `SKILL.md`.

## Authoring a new skill

1. Add `.claude/skills/<name>/SKILL.md` with frontmatter (`name`,
   `description`).
2. Mirror it to `.agents/skills/<name>/SKILL.md`.
3. Update both `CLAUDE.md` and `AGENTS.md` to mention the new skill.
4. Run `./scripts/check-ai-consistency.sh` — it should pass.

The body of the skill should be self-contained: a future agent will
read it cold without any other context.
