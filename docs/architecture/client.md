# Client architecture

Three layers: `domain` ← `data` ← `presentation`. `core` and `core_ui`
are infrastructure used by all three.

## Layers

- **domain/** — entities and repository interfaces. Pure Dart, no
  Flutter, no Supabase.
- **data/** — DTOs, mappers, Supabase data sources, repository
  implementations. Depends on `domain`.
- **presentation/** — pages, widgets, Cubits / Blocs. Depends on
  `domain` and `data`.
- **core/** — DI, routing, config, logger, Supabase / Firebase /
  RevenueCat init, analytics façade.
- **core_ui/** — design system: theme tokens, components, preview route.

## Wiring

```
┌────────────────┐    request    ┌─────────────────┐
│  Cubit         │ ────────────► │ Repository      │
│  (presentation)│ ◄──────────── │ (data impl)     │
└────────────────┘    Result     └────────┬────────┘
                                          │
                              ┌───────────▼────────────┐
                              │ SupabaseEdgeFunctions  │
                              │ (core/supabase/...)    │
                              └────────────────────────┘
```

Cubits emit immutable `freezed` states. Repositories return
`Result<T>` (`Success(value)` / `Failure(failure)`); see
`core/types/`.

## Bootstrapping

`main.dart` order matters:

1. `WidgetsFlutterBinding.ensureInitialized()`.
2. `FlutterNativeSplash.preserve(...)`.
3. `AppConfig.init()` — reads `--dart-define-from-file=...`.
4. `FirebaseInitializer.init()` — no-op when `ENABLE_FIREBASE=false`.
5. `SupabaseInitializer.init()` — required.
6. `RevenueCatInitializer.init()` — no-op when `ENABLE_REVENUECAT=false`.
7. `configureDependencies()` — populates `getIt`.
8. `runApp(const App())`.

`runZonedGuarded` wraps the whole thing so unhandled errors land in
`FirebaseInitializer.recordZonedError`.

## Cross-feature concerns

- **Routing**: `core/routing/app_router.dart` builds a `GoRouter` from
  a list of `RouteGuard`s. Each guard owns one navigation concern (auth,
  onboarding, paywall, …). Order matters; first non-null redirect wins.
- **State observability**: `core/bloc/bloc_observer.dart` logs every
  Cubit transition.
- **Localization**: `core/localization/locale_cubit.dart` reads/writes
  the user-selected locale; `LocaleStorage` persists the choice.
- **Theme**: `core_ui/theme/theme_mode_cubit.dart` toggles light/dark.
