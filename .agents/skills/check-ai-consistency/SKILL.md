---
name: check-ai-consistency
description: Use to verify that CLAUDE.md and AGENTS.md agree, that every Claude skill has a Codex twin (and vice versa), and that hooks/settings/agent docs do not contradict each other. Runs scripts/check-ai-consistency.sh for deterministic checks first, then performs higher-level semantic review on top.
---

# check-ai-consistency

Keeps Claude Code and Codex aligned. Without this, the two ecosystems
drift apart and skills start producing different output for the same
prompt.

## When to use

- Before merging a PR that touches `CLAUDE.md`, `AGENTS.md`,
  `.claude/`, `.agents/`, or any skill / subagent file.
- Periodically (weekly is fine) as a hygiene check.
- When a user reports that a skill behaves differently in Claude vs
  Codex.

## How it behaves

### Step 1 — deterministic checks

Run `scripts/check-ai-consistency.sh`. This script — not the agent —
verifies:

1. `CLAUDE.md` and `AGENTS.md` both exist.
2. Both files mention the same set of skill names.
3. Every skill exists in **both** `.claude/skills/<name>/SKILL.md`
   and `.agents/skills/<name>/SKILL.md`.
4. Paired SKILL.md files have the same set of H2 sections.
5. Each skill has a non-empty, reasonably short `description` in its
   frontmatter.
6. Required docs exist: `docs/README.md`, `docs/sdd/*`,
   `docs/specs/README.md`, `docs/specs/INDEX.md`.
7. Required scripts exist and are executable: `scripts/{check,format,
   analyze,bootstrap,supabase-reset,supabase-typegen,
   update-spec-index,check-ai-consistency}.sh`.
8. `.gitignore` excludes secrets and generated files (`.env`,
   `.config.*.json`, `*.freezed.dart`, `*.g.dart`,
   `injectable.config.dart`, Firebase configs).
9. Spec filenames match `^(SPEC|BUG|PROP)-\d{4}-.+\.md$`.
10. Every spec frontmatter has the required fields.
11. `INDEX.md` matches the actual list of specs.
12. No obvious real secrets snuck in (regex for `sk_[A-Za-z0-9]{20,}`
    and JWT-like tokens outside `.example` files).

If the script exits non-zero, treat that output as ground truth. Fix
the deterministic problems before doing semantic review.

### Step 2 — semantic review (only after step 1 is clean)

Do a careful read of:

- `CLAUDE.md` vs `AGENTS.md` — same statements, same wording where it
  matters, no contradictions.
- Each pair of SKILL.md files — same behavior, just adjusted for the
  ecosystem.
- Subagent prompts in `.claude/agents/` and `.agents/agents/` — same
  role definition.
- `.claude/settings.json` hooks vs analogous Codex guidance in
  `AGENTS.md` — they should imply the same workflow.

Flag (don't auto-fix):
- Stale references to removed skills, scripts, or files.
- One ecosystem mentions a workflow the other doesn't.
- Skills that contradict the constitution.
- Ambiguous rules.

### Step 3 — apply safe fixes

For purely mechanical issues (a missing blank line, wrong header
case, etc.) edit in place. For anything that requires a judgment call,
report and ask.

## Output

- Status: `pass` / `pass-with-warnings` / `fail`.
- Categorized findings: deterministic failures, parity gaps, semantic
  contradictions, stale references.
- For each finding: file path(s), short description, suggested fix.
- Diff summary if the skill applied any safe fixes.

## What it does NOT do

- Rewrite skills wholesale.
- Decide which version of a contradiction is correct — escalate.
