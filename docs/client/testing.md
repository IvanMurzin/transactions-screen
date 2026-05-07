# Testing (client)

The template ships only a smoke test (`client/test/widget_test.dart`).
Tests are **optional by default** — add them when a spec calls for
them or when the change touches code that already has coverage.

## Where tests live

```
client/test/
  core/<area>/<thing>_test.dart
  data/<feature>/<thing>_test.dart
  presentation/<feature>/<thing>_test.dart
```

Mirror the `lib/` structure.

## Conventions

- Each test file targets a single class or page.
- Cubit tests use `bloc_test`.
- Widget tests use `flutter_test` + `MaterialApp` wrapper providing
  `AppLocalizations.delegate` (see the smoke test for the boilerplate).
- Don't mock the database in integration tests when a real local
  Supabase is available.

## Running

```bash
cd client
flutter test
flutter test test/path/to/specific_test.dart
flutter test --coverage
```

CI does not enforce a coverage threshold; review enforces test
adequacy per spec.
