import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:transaction_screen/core/di/get_it.dart';
import 'package:transaction_screen/core/localization/locale_cubit.dart';
import 'package:transaction_screen/core/localization/locale_state.dart';
import 'package:transaction_screen/core/routing/app_router.dart';
// AuthRouteGuard is wired only after the product registers /sign-in,
// /sign-up and /sign-up/otp pages — otherwise go_router would redirect
// unauthenticated users to a route it cannot resolve. See
// `docs/architecture/patterns/auth_route_guard.md`.
// import 'package:transaction_screen/core/routing/guards/auth_route_guard.dart';
import 'package:transaction_screen/core_ui/theme/app_theme.dart';
import 'package:transaction_screen/core_ui/theme/theme_mode_cubit.dart';
import 'package:transaction_screen/l10n/app_localizations.dart';
import 'package:transaction_screen/presentation/auth/bloc/auth_cubit.dart';
import 'package:transaction_screen/presentation/profile/bloc/profile_cubit.dart';
import 'package:transaction_screen/presentation/subscription/bloc/subscription_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthCubit _authCubit;
  late final ProfileCubit _profileCubit;
  late final SubscriptionCubit _subscriptionCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Singletons resolved from getIt; bootstrapped here so the session
    // stream and the route guard share the same instance.
    _authCubit = getIt<AuthCubit>()..bootstrap();
    _profileCubit = getIt<ProfileCubit>();
    _subscriptionCubit = getIt<SubscriptionCubit>()..bootstrap();
    // Wire AuthRouteGuard once auth pages exist:
    //   _router = buildAppRouter(guards: [AuthRouteGuard(_authCubit)]);
    _router = buildAppRouter();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeModeCubit>(create: (_) => getIt<ThemeModeCubit>()),
        BlocProvider<LocaleCubit>(create: (_) => getIt<LocaleCubit>()..load()),
        BlocProvider<AuthCubit>.value(value: _authCubit),
        BlocProvider<ProfileCubit>.value(value: _profileCubit),
        BlocProvider<SubscriptionCubit>.value(value: _subscriptionCubit),
      ],
      child: BlocBuilder<ThemeModeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              return MaterialApp.router(
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: themeMode,
                routerConfig: _router,
                locale: context.read<LocaleCubit>().locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    );
  }
}
