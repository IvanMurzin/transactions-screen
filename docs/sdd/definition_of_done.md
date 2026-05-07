# Definition of done

A spec is **done** when every item below is true.

- [ ] All acceptance criteria pass on the implementation branch.
- [ ] `dart format .` and `flutter analyze` exit clean.
- [ ] No new strings outside `app_en.arb` / `app_ru.arb`; both ARB
      files are in sync.
- [ ] No edits to generated files (`*.freezed.dart`, `*.g.dart`,
      `injectable.config.dart`, generated l10n).
- [ ] No real secrets committed.
- [ ] If the spec touches the backend: migration ships, `api_*` RPCs
      exist, RLS posture documented, edge function route updated.
- [ ] If the spec touches the API contract: `docs/contracts/api-surface.md`
      reflects the change.
- [ ] If the spec adds a DS component: it shows up on the DS preview
      route and is documented in `docs/design_system/components.md`.
- [ ] Spec frontmatter `status` set to `review` (then `done` after
      human review).
- [ ] `docs/specs/INDEX.md` regenerated via `scripts/update-spec-index.sh`.
- [ ] Commit message: `spec(SPEC-####): <summary>`.

Tests are **not** required by default — add them when the spec calls
for them or when the change touches code that already has coverage.
