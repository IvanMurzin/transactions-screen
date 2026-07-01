import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'package:transaction_screen/core/config/app_config.dart';
import 'package:transaction_screen/core/logger/logger.dart';

abstract final class FirebaseInitializer {
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> init() async {
    if (!AppConfig.instance.enableFirebase) {
      logger.i('Firebase disabled via config — skipping init');
      return;
    }
    try {
      await Firebase.initializeApp();
      _initialized = true;
      if (kReleaseMode) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      }
    } catch (error, stack) {
      logger.w('Firebase init failed', error: error, stackTrace: stack);
    }
  }

  static void recordZonedError(Object error, StackTrace stack) {
    if (!_initialized || !kReleaseMode) return;
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
  }
}
