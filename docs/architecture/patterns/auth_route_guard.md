# Pattern: AuthRouteGuard

The template ships `AuthCubit`, `AuthRouteGuard`, and the route
constants `AppRoutes.signIn / signUp / otp` — but the guard is **not**
wired into the router by default. This page explains why and how to
turn it on.

## Why it's not wired by default

`AuthRouteGuard.redirect` returns `AppRoutes.signIn` for unauthenticated
users. With no `/sign-in` route registered in
`core/routing/app_router.dart`, go_router would land on its built-in
error page on first launch — a bad first impression for a fresh
template. The fix is one line; deferring it lets the template run
without auth UI for products that don't need one yet.

## Turning it on

1. Build the auth pages (sign-in, sign-up, optional OTP):

   ```text
   client/lib/presentation/auth/page/sign_in_page.dart
   client/lib/presentation/auth/page/sign_up_page.dart
   client/lib/presentation/auth/page/otp_page.dart   # optional
   ```

2. Register them in `core/routing/app_router.dart`:

   ```dart
   GoRoute(
     path: AppRoutes.signIn,
     pageBuilder: (c, s) => slideTransition(c, s, const SignInPage()),
   ),
   GoRoute(
     path: AppRoutes.signUp,
     pageBuilder: (c, s) => slideTransition(c, s, const SignUpPage()),
   ),
   // OTP route only if AppConfig.isOtpEnabled is true.
   ```

3. Add the guard in `app.dart`:

   ```dart
   _router = buildAppRouter(guards: [AuthRouteGuard(_authCubit)]);
   ```

That's it — the cubit is already bootstrapped, the
`UnauthorizedNotifier` already fires on backend 401, and the guard
already listens to the cubit's stream.

## Why not register stub pages in the template?

Stubs would muddy two contracts: the router would always know about
auth routes (forcing every product to keep them), and dead UI would
ship in `presentation/`. The template stays UI-free in `presentation/`
on purpose — products own their pages.

## Testing

Use `FakeAuthCubit` (a thin Cubit subclass that emits
`AuthState(status: …)` directly) and inject it where the production
code uses `getIt<AuthCubit>()`. The guard's `redirect` is a pure
function of `state.status`, so unit-testing it without go_router is
straightforward.
