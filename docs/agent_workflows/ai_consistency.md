# AI consistency

Two pieces:

1. **Deterministic check** — `scripts/check-ai-consistency.sh`. Pure
   shell, runs in CI, exits non-zero on failure. Covers things a
   regex can verify.
2. **Semantic review** — the `check-ai-consistency` skill. Wraps the
   script and adds higher-level review (contradictions, stale refs,
   ambiguous rules). Run it manually when you suspect drift.

## What the script enforces

(See the script header for the authoritative list. Summary:)

- `CLAUDE.md` and `AGENTS.md` exist and mention the same skills.
- Every skill exists in both `.claude/skills/` and `.agents/skills/`
  with the same H2 sections and a non-empty description.
- Required docs / scripts exist; scripts are executable.
- `.gitignore` covers secrets and generated files.
- Spec filenames follow the convention; spec frontmatter is complete.
- `INDEX.md` matches actual specs.
- No obvious real secrets are committed.

## What the skill adds on top

- Reads files in pairs (`CLAUDE.md` ↔ `AGENTS.md`, paired skills) and
  spots wording that contradicts the constitution or each other.
- Flags stale references to removed skills, scripts, or files.
- Suggests safe, mechanical fixes; escalates judgment calls.

## When to run

- Before merging a PR that touches `CLAUDE.md`, `AGENTS.md`,
  `.claude/`, `.agents/`, or any skill / subagent file.
- Periodically (weekly) as hygiene.
- When a user reports that a skill behaves differently in Claude vs
  Codex.

## Failure mode

If the script exits non-zero, fix the deterministic issues first
before doing semantic review. Don't run the skill on top of broken
basics — you'll just get noise.
