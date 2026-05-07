import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import 'package:template_app/core/config/app_config.dart';
import 'package:template_app/core/firebase/firebase_initializer.dart';
import 'package:template_app/core/logger/logger.dart';

/// Generic analytics façade.
///
/// All product event names live in your feature code (or a per-feature
/// constants file) — not here. This file only knows how to ship a
/// `name + Map<String, Object>` to Firebase Analytics, and falls back to
/// log lines when Firebase is disabled or not in a release build.
@lazySingleton
class AppAnalytics {
  bool get _active {
    try {
      return AppConfig.instance.analyticsActive;
    } on StateError {
      return false;
    }
  }

  Future<void> logEvent(String name, {Map<String, Object?> parameters = const {}}) async {
    final safe = <String, Object>{
      for (final entry in parameters.entries)
        if (entry.value != null) entry.key: entry.value!,
    };
    if (!_active) {
      logger.i('analytics_event $name $safe');
      return;
    }
    try {
      await FirebaseAnalytics.instance.logEvent(name: name, parameters: safe.isEmpty ? null : safe);
    } catch (error, stack) {
      logger.w('Analytics logEvent failed for $name', error: error, stackTrace: stack);
    }
  }

  Future<void> setUserId(String? userId) async {
    if (!FirebaseInitializer.isInitialized) return;
    try {
      if (_active) {
        await FirebaseAnalytics.instance.setUserId(id: userId);
      }
      if (kReleaseMode) {
        await FirebaseCrashlytics.instance.setUserIdentifier(userId ?? '');
      }
    } catch (error, stack) {
      logger.w('Analytics setUserId failed', error: error, stackTrace: stack);
    }
  }

  Future<void> setUserProperty(String name, String? value) async {
    if (!_active) {
      logger.i('analytics_user_property $name=$value');
      return;
    }
    try {
      await FirebaseAnalytics.instance.setUserProperty(name: name, value: value);
    } catch (error, stack) {
      logger.w('Analytics setUserProperty failed for $name', error: error, stackTrace: stack);
    }
  }

  Future<void> logScreenView(String screenName) async {
    if (!_active) {
      logger.i('analytics_screen_view $screenName');
      return;
    }
    try {
      await FirebaseAnalytics.instance.logScreenView(screenName: screenName);
    } catch (error, stack) {
      logger.w('Analytics logScreenView failed for $screenName', error: error, stackTrace: stack);
    }
  }
}

class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver(this._analytics);

  final AppAnalytics _analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _track(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _track(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _track(previousRoute);
  }

  void _track(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty) return;
    unawaited(_analytics.logScreenView(name));
  }
}
