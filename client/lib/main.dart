import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:transaction_screen/app.dart';
import 'package:transaction_screen/core/bloc/bloc_observer.dart';
import 'package:transaction_screen/core/config/app_config.dart';
import 'package:transaction_screen/core/di/di.dart';
import 'package:transaction_screen/core/logger/logger.dart';
import 'package:transaction_screen/core/revenuecat/revenuecat_initializer.dart';
import 'package:transaction_screen/core/supabase/supabase_initializer.dart';

Future<void> main() async {
  Bloc.observer = AppBlocObserver();
  runZonedGuarded(
    () async {
      final binding = WidgetsFlutterBinding.ensureInitialized();
      FlutterNativeSplash.preserve(widgetsBinding: binding);
      AppConfig.init();
      await SupabaseInitializer.init();
      await RevenueCatInitializer.init();
      await configureDependencies();

      logger.i('app_started flavor=${AppConfig.instance.flavor.name}');
      runApp(const App());
    },
    (error, stackTrace) {
      logger.e('Unhandled exception:', error: error, stackTrace: stackTrace);
    },
  );
}
