/// Centralized list of route paths used by [buildAppRouter].
///
/// Add new routes here so go_router and feature pages share a single
/// source of truth. Keep paths string-typed; type-safe extras live in
/// [route_extra_args.dart].
abstract final class AppRoutes {
  static const String home = '/';
  static const String designSystem = '/design-system';

  // Auth — pages live in product code; constants ship in the template so
  // guards and routers can reference them before the UI is built.
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String otp = '/sign-up/otp';
}
