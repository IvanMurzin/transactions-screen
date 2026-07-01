import 'package:flutter/foundation.dart';

enum AppFlavor {
  dev,
  prod;

  static AppFlavor fromString(String value) {
    final normalized = value.trim().toLowerCase();
    return AppFlavor.values.firstWhere(
      (flavor) => flavor.name == normalized,
      orElse: () => throw StateError('Unknown FLAVOR value "$value". Expected "dev" or "prod".'),
    );
  }
}

/// Single source of truth for runtime configuration.
///
/// Values come from `--dart-define-from-file=../.config.<flavor>.json`.
/// Required keys are validated at startup; optional integrations are
/// disabled by default so a fresh template can run without external
/// services.
final class AppConfig {
  AppConfig._({
    required this.env,
    required this.flavor,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.oauthRedirectUri,
    required this.isOtpEnabled,
    required this.enableRevenueCat,
    required this.revenueCatApiKey,
    required this.logApiResponses,
  });

  static AppConfig? _instance;

  static const _requiredKeys = <String>['ENV', 'FLAVOR', 'SUPABASE_URL', 'SUPABASE_ANON_KEY'];

  static AppConfig get instance {
    final config = _instance;
    if (config == null) {
      throw StateError('AppConfig not initialized. Call AppConfig.init() in main() before use.');
    }
    return config;
  }

  final String env;
  final AppFlavor flavor;
  final String supabaseUrl;
  final String supabaseAnonKey;

  /// Deep-link URL Supabase Auth redirects to after OAuth / magic-link.
  /// Empty string means OAuth is not configured — only email/password sign-in
  /// is exposed to the user. Format: `myapp://login-callback/`.
  final String oauthRedirectUri;

  /// When true, sign-up requires email OTP verification before the session
  /// becomes usable. When false, the user is signed in immediately after
  /// sign-up. Default: false.
  final bool isOtpEnabled;

  final bool enableRevenueCat;
  final String revenueCatApiKey;
  final bool logApiResponses;

  bool get isProdRelease => flavor == AppFlavor.prod && kReleaseMode;

  /// True when at least one OAuth provider can be attempted. Drives whether
  /// the auth UI shows social sign-in buttons.
  bool get isOAuthConfigured => oauthRedirectUri.trim().isNotEmpty;

  static void init() {
    _instance = _fromEnvironment();
  }

  @visibleForTesting
  static void overrideForTesting(AppConfig config) {
    _instance = config;
  }

  static AppConfig _fromEnvironment() {
    final values = <String, String>{
      'ENV': const String.fromEnvironment('ENV'),
      'FLAVOR': const String.fromEnvironment('FLAVOR'),
      'SUPABASE_URL': const String.fromEnvironment('SUPABASE_URL'),
      'SUPABASE_ANON_KEY': const String.fromEnvironment('SUPABASE_ANON_KEY'),
    };
    final missing = _requiredKeys
        .where((k) => (values[k] ?? '').trim().isEmpty)
        .toList(growable: false);
    if (missing.isNotEmpty) {
      throw StateError(
        'Missing app config keys: ${missing.join(', ')}. '
        'Provide them via --dart-define-from-file=../.config.<flavor>.json.',
      );
    }
    return AppConfig._(
      env: values['ENV']!,
      flavor: AppFlavor.fromString(values['FLAVOR']!),
      supabaseUrl: values['SUPABASE_URL']!,
      supabaseAnonKey: values['SUPABASE_ANON_KEY']!,
      oauthRedirectUri: const String.fromEnvironment('OAUTH_REDIRECT_URI'),
      isOtpEnabled: const bool.fromEnvironment('IS_OTP_ENABLED'),
      enableRevenueCat: const bool.fromEnvironment('ENABLE_REVENUECAT'),
      revenueCatApiKey: const String.fromEnvironment('REVENUECAT_API_KEY'),
      logApiResponses: const bool.fromEnvironment('LOG_API_RESPONSES'),
    );
  }
}
