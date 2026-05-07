# Client architecture (Flutter)

See [`../architecture/client.md`](../architecture/client.md) for the
overall layering. This file lists feature-level recipes.

## Adding a feature

```
client/lib/
  domain/<feature>/
    entity/<feature>_entity.dart        # @freezed value object
    repository/<feature>_repository.dart # abstract interface
    usecase/<verb>_<feature>_usecase.dart
  data/<feature>/
    dto/<feature>_dto.dart              # @JsonSerializable for wire format
    data_source/supabase_<feature>_data_source.dart
    repository/<feature>_repository_impl.dart
  presentation/<feature>/
    bloc/<feature>_cubit.dart
    bloc/<feature>_state.dart           # @freezed states
    page/<feature>_page.dart
    widget/<small_widget>.dart
```

## Conventions

- Entities are `@freezed` value objects, equality + copyWith free.
- Repository interfaces live in `domain/`; implementations in `data/`.
- Use `@injectable` / `@lazySingleton` / `@LazySingleton(as: I)` for
  DI registration. Run `dart run build_runner build` after.
- Cubit emits `freezed` states; never mutate state in place.
- Errors flow as `Result<T>` (`Success` / `Failure`). The `Failure`
  type carries an error `code` for the UI to switch on.

## Routing

- New route: add to `core/routing/app_routes.dart` AND register a
  builder in `core/routing/app_router.dart`.
- Cross-cutting nav rule (e.g. "unauthenticated user can't reach /home")
  belongs in a new `RouteGuard` in `core/routing/guards/`.
- Pages do not call `Navigator.push` directly — use
  `context.go(AppRoutes.x)`.

## Localization

- Add a key in **both** `lib/l10n/app_en.arb` and `lib/l10n/app_ru.arb`
  in the same commit. The build will fail otherwise.
- Use `AppLocalizations.of(context)!.<key>` in widgets.

## Build runner

After adding `@freezed`, `@JsonSerializable`, or `@injectable`:

```bash
cd client
dart run build_runner build --delete-conflicting-outputs
```

## Tests

Tests live under `client/test/` mirroring the `lib/` structure. The
template ships only a smoke test (`widget_test.dart`); add real tests
when a spec calls for them.
