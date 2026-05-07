# Hooks

The template ships exactly **one** hook: a `Stop` hook in
`.claude/settings.json` that runs `scripts/check.sh` (format +
analyze + AI consistency).

## Why so few?

Hooks that run after every edit are slow and noisy. They also tend
to mutate files unexpectedly. The template's stance:

- Format and analyze near the end of work, not every edit.
- Tests don't run automatically — they run on demand via
  `flutter test`.
- Prefer skills + scripts you can run manually over hooks that fire
  silently.

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

- The hook must be fast (< 2s) or you'll regret it.
- The hook must not mutate many files.
- The hook must work without secrets.
- Document any new hook here.

## Codex side

Codex has no hook system equivalent. The same effect is achieved by
the `AGENTS.md` workflow rule: "run `scripts/check.sh` at the end of
work." If you find yourself adding a hook, ask whether the same
discipline can live in `AGENTS.md` instead.
