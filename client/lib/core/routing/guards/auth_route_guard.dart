import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:transaction_screen/core/routing/app_routes.dart';
import 'package:transaction_screen/core/routing/guards/route_guard.dart';
import 'package:transaction_screen/presentation/auth/bloc/auth_cubit.dart';

/// Sends unauthenticated users to [AppRoutes.signIn] and bounces signed-in
/// users away from auth pages. The `initial` status is treated as "still
/// loading" — no redirect — so the splash stays visible until the session
/// stream emits.
class AuthRouteGuard implements RouteGuard {
  AuthRouteGuard(this._cubit) : _listenable = _AuthGuardListenable(_cubit);

  final AuthCubit _cubit;
  final _AuthGuardListenable _listenable;

  static const _authPaths = <String>{AppRoutes.signIn, AppRoutes.signUp, AppRoutes.otp};

  @override
  Listenable? get listenable => _listenable;

  @override
  String? redirect(String location) {
    final state = _cubit.state;
    if (!state.isResolved) return null; // wait for first emit
    final atAuthRoute = _authPaths.contains(location);
    if (state.isAuthenticated) {
      return atAuthRoute ? AppRoutes.home : null;
    }
    return atAuthRoute ? null : AppRoutes.signIn;
  }
}

class _AuthGuardListenable extends ChangeNotifier {
  _AuthGuardListenable(this._cubit) {
    _subscription = _cubit.stream.listen((_) => notifyListeners());
  }

  final AuthCubit _cubit;
  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
