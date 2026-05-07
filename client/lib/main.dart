import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:template_app/app.dart';
import 'package:template_app/core/bloc/bloc_observer.dart';
import 'package:template_app/core/config/app_config.dart';
import 'package:template_app/core/di/di.dart';
import 'package:template_app/core/firebase/firebase_initializer.dart';
import 'package:template_app/core/logger/logger.dart';
import 'package:template_app/core/revenuecat/revenuecat_initializer.dart';
import 'package:template_app/core/supabase/supabase_initializer.dart';

Future<void> main() async {
  Bloc.observer = AppBlocObserver();
  runZonedGuarded(
    () async {
      final binding = WidgetsFlutterBinding.ensureInitialized();
      FlutterNativeSplash.preserve(widgetsBinding: binding);
      AppConfig.init();
      await FirebaseInitializer.init();
      await SupabaseInitializer.init();
      await RevenueCatInitializer.init();
      await configureDependencies();

      logger.i('app_started flavor=${AppConfig.instance.flavor.name}');
      runApp(const App());
    },
    (error, stackTrace) {
      logger.e('Unhandled exception:', error: error, stackTrace: stackTrace);
      FirebaseInitializer.recordZonedError(error, stackTrace);
    },
  );
}
