# Flutter client (Codex)

Same content lives in `client/CLAUDE.md`. Keep both in sync.

Conventions, structure, and verification commands. Repo-level rules
live in [`../AGENTS.md`](../AGENTS.md); this file is the Flutter-only
addendum.

## Layout

```
lib/
  core/                # Infra: di, config, logger, routing, supabase, firebase, revenuecat, …
  core_ui/             # Design system: theme, components, preview route.
  domain/              # Pure entities, repository interfaces, use cases.
  data/                # DTOs, mappers, data sources, repository impls.
  presentation/        # Pages, widgets, Cubits, states.
  l10n/                # ARB files + generated AppLocalizations (regen via flutter pub get).
  app.dart, main.dart  # Bootstrapping.
```

## Commands (run from `client/`)

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format .
flutter analyze
flutter test
flutter run --flavor dev --dart-define-from-file=../.config.dev.json
flutter run --flavor prod --dart-define-from-file=../.config.prod.json
```

## Hard rules (Flutter-specific)

- Cubit-first via `flutter_bloc`. New state framework needs an
  accepted proposal spec.
- Routes: register in `core/routing/app_routes.dart` + `app_router.dart`.
  Cross-cutting nav logic = one `RouteGuard` per concern.
- DI: `@injectable` / `@lazySingleton` / `@module`. After changing
  annotations, regenerate with `dart run build_runner build`.
- All UI uses `core_ui/components/*` and `context.dsColors` /
  `dsSpacing` / `dsTypography`. No raw `Color(0x…)` in feature code.
- Strings only via ARB (`app_en.arb` + `app_ru.arb`, kept in sync).
- No `print()`. Use `logger` from `core/logger/logger.dart`.
- Don't edit generated files: `*.freezed.dart`, `*.g.dart`,
  `core/di/injectable.config.dart`, `l10n/app_localizations*.dart`.

## Adding a feature

1. Read the spec in `docs/specs/open/...`.
2. Add `domain/<feature>/` (entities, repository interface, use cases).
3. Add `data/<feature>/` (DTO, data source, repository impl).
4. Add `presentation/<feature>/` (Cubit, state, page, widgets).
5. Wire via `@injectable`; regenerate DI.
6. Add localization keys to both ARB files.
7. Run `dart format .` + `flutter analyze`.
