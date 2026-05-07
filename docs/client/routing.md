# Routing

`go_router` configured via `core/routing/app_router.dart`.

## Adding a route

1. Constant: `static const String foo = '/foo';` in
   `core/routing/app_routes.dart`.
2. Builder: register a `GoRoute(path: AppRoutes.foo, …)` in
   `buildAppRouter`.
3. Use `slideTransition(context, state, FooPage())` from
   `core/routing/app_page_transitions.dart` for the standard
   transition.

## Guards

A guard is one slice of navigation logic — auth, onboarding, paywall.

```dart
class MyGuard implements RouteGuard {
  @override
  String? redirect(String location) {
    if (someCondition) return AppRoutes.signIn;
    return null;
  }

  @override
  Listenable? get listenable => myCubit; // re-runs guards on emit
}
```

Order in `buildAppRouter(guards: […])` matters: first non-null wins.

## Typed extras

Use a class from `core/routing/route_extra_args.dart` instead of
`Map<String, dynamic>` for `state.extra` payloads.
