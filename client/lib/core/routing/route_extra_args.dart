/// Typed payloads passed via [GoRouterState.extra].
///
/// Define one immutable value type per route that needs to pass extra
/// data — never plain maps. Keeps router and pages decoupled.
sealed class RouteExtraArgs {
  const RouteExtraArgs();
}
