# Hooks

The template now ships two guard rails in `.claude/settings.json`:

- `PreToolUse` on `Edit|Write|MultiEdit`:
  - `scripts/hooks/require-active-spec.sh`
  - `scripts/hooks/guard-spec-scope.sh`
- `Stop` hook running `scripts/check-ai-consistency.sh`.

These hooks are intentionally narrow: they block code edits without an
active spec state and reduce accidental scope creep.

## Adding a hook

If you need one, edit `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'about to edit'"
          }
        ]
      }
    ]
  }
}
```

Rules of thumb:

- The hook must be fast (< 2s) unless it is a final `Stop` check.
- The hook must not mutate many files.
- The hook must work without secrets.
- Document any new hook here.

## Codex side

Codex has no hook system equivalent. The same effect is achieved by
the `AGENTS.md` workflow rule: "run `scripts/check.sh` at the end of
work." If you find yourself adding a hook, ask whether the same
discipline can live in `AGENTS.md` instead.
