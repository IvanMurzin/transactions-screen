import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:transaction_screen/core/di/get_it.dart';
import 'package:transaction_screen/core/routing/app_page_transitions.dart';
import 'package:transaction_screen/core/routing/app_routes.dart';
import 'package:transaction_screen/core/routing/guards/route_guard.dart';
import 'package:transaction_screen/presentation/transactions/bloc/transactions_cubit.dart';
import 'package:transaction_screen/presentation/transactions/pages/transactions_page.dart';

/// Builds a [GoRouter] from a list of atomic [RouteGuard]-s.
///
/// Each guard is an independent slice of navigation logic (auth,
/// onboarding, paywall, …). Guards are evaluated in order; the first
/// non-null path wins. go_router re-runs the chain after every redirect,
/// so guards compose without knowing about each other.
GoRouter buildAppRouter({
  String initialLocation = AppRoutes.home,
  List<RouteGuard> guards = const [],
  List<NavigatorObserver>? observers,
}) {
  final listenables = guards
      .map((g) => g.listenable)
      .whereType<Listenable>()
      .toList(growable: false);

  return GoRouter(
    initialLocation: initialLocation,
    observers: observers,
    refreshListenable: listenables.isEmpty ? null : Listenable.merge(listenables),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      for (final guard in guards) {
        final next = guard.redirect(loc);
        if (next != null && next != loc) {
          return next;
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => slideTransition(
          context,
          state,
          BlocProvider<TransactionsCubit>(
            create: (_) => getIt<TransactionsCubit>()..load(),
            child: const TransactionsPage(),
          ),
        ),
      ),
    ],
  );
}
