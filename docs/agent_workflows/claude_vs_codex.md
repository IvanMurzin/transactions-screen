# Claude vs Codex parity

Both ecosystems are first-class. The repo ships matching files for
each:

| Concept | Claude | Codex |
| ------- | ------ | ----- |
| Project guide | `CLAUDE.md` | `AGENTS.md` |
| Per-layer guide | `client/CLAUDE.md`, `backend/CLAUDE.md` | `client/AGENTS.md`, `backend/AGENTS.md` |
| Skills | `.claude/skills/<name>/SKILL.md` | `.agents/skills/<name>/SKILL.md` |
| Subagents | `.claude/agents/<name>.md` | `.agents/agents/<name>.md` |
| Hooks / settings | `.claude/settings.json` | (no native equivalent — guidance lives in `AGENTS.md`) |

## Why parallel files instead of cross-references?

Agent context is unreliable. A skill or instruction file that says
"see the other ecosystem's file" frequently fails — the other file
isn't loaded. Duplication is the lesser evil. The
`check-ai-consistency` skill keeps the duplicates aligned.

## Differences worth knowing

- Claude has native subagents (`.claude/agents/*`). Codex doesn't —
  the matching `.agents/agents/*` files are prompt snippets the agent
  loads when adopting that role for a focused task.
- Claude hooks (`.claude/settings.json`) run scripts deterministically
  on events like `Stop`. Codex has no equivalent; the same effect is
  achieved by asking the agent to run `scripts/check.sh` at end of
  work.

## When parity drifts

`check-ai-consistency` (skill + script) is the reconciliation tool.
Run it before merging anything that touches the AI workflow files.
