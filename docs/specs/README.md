# Specs

This directory holds every change request that flows through the
codebase. See [../sdd/how_to_use_sdd.md](../sdd/how_to_use_sdd.md) for
the workflow and [../sdd/spec_lifecycle.md](../sdd/spec_lifecycle.md)
for the status model.

## Layout

```
docs/specs/
  open/
    features/     # SPEC-####
    bugs/         # BUG-####
    proposals/    # PROP-####
  closed/
    features/
    bugs/
    proposals/
  archive/        # rejected / superseded specs
  INDEX.md        # table of every spec — regenerate via scripts/update-spec-index.sh
```

## Creating a spec

```bash
# Claude / Codex
/create-spec       # quick: one focused change you already understand
/plan-feature      # broad: a feature area broken into multiple specs
```

Both skills:

1. Pick the next spec id by scanning existing files.
2. Drop a new file into `docs/specs/open/<type>/`.
3. Fill the frontmatter and body using `docs/sdd/spec_template.md`.
4. Append a row to `docs/specs/INDEX.md`.

## Resolving a spec

```bash
/resolve-spec SPEC-0001
```

The skill creates a branch, implements only the spec, runs format +
analyze, and leaves the working tree in `review` state.

## Closing a spec

After human review and merge:

```bash
git mv docs/specs/open/features/SPEC-0001-foo.md docs/specs/closed/features/
# update frontmatter status to `done`, set `updated:` to today
./scripts/update-spec-index.sh
git commit -m "spec(SPEC-0001): close foo"
```
