# Dependency injection

`get_it` + `injectable` with code generation.

## Annotations

| Annotation | Use for |
| ---------- | ------- |
| `@injectable` | Default. New instance per resolution. |
| `@lazySingleton` | One instance, created on first `getIt<X>()`. |
| `@singleton` | One instance, created at boot. |
| `@LazySingleton(as: IFoo)` | Bind concrete `Foo` to interface `IFoo`. |
| `@module` | Provide values that don't have a constructor (e.g. external SDK clients). |

## Modules

`core/di/supabase_module.dart` exposes the Supabase client. Add
similar modules for any other SDK that you don't construct yourself.

## Codegen

```bash
cd client
dart run build_runner build --delete-conflicting-outputs
```

This rewrites `core/di/injectable.config.dart`. Never edit that file
by hand. CI should fail if it's stale.
