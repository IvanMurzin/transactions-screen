import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:transaction_screen/core/di/get_it.dart';
import 'package:transaction_screen/core/session/unauthorized_notifier.dart';
import 'package:transaction_screen/core/supabase/supabase_edge_functions.dart';
import 'package:transaction_screen/core/types/failure.dart';

/// Normalizes any Supabase / Edge Function error into a stable [Failure]
/// the rest of the app can switch on. Codes are lower-snake-case strings
/// (`unauthorized`, `network`, `validation`, …); messages stay raw so
/// translators can decide between the code and the server-provided text.
///
/// Side effect: every `unauthorized` failure also fires
/// [UnauthorizedNotifier], so any session-watching cubit can drop the
/// session locally without coupling the data layer to presentation.
abstract final class SupabaseFailureMapper {
  static Failure toFailure(Object error, {String? fallbackMessage}) {
    if (error is SocketException) {
      return _build('network', fallbackMessage ?? 'Network error');
    }

    if (error is EdgeFunctionException) {
      return _build(_normalizeCode(error.code), error.message);
    }

    if (error is AuthException) {
      final message = error.message;
      final code = error.code;
      if (code != null && code.isNotEmpty) {
        return _build(code, message);
      }
      final normalized = message.toLowerCase();
      if (normalized.contains('invalid login') ||
          (normalized.contains('invalid') && normalized.contains('credentials'))) {
        return _build('unauthorized', message);
      }
      if (normalized.contains('rate limit') || normalized.contains('too many')) {
        return _build('rate_limited', message);
      }
      if (normalized.contains('already') && normalized.contains('registered')) {
        return _build('conflict', message);
      }
      return _build('unknown', message);
    }

    if (error is PostgrestException) {
      return _build(_mapPostgresCode(error.code), error.message);
    }

    if (error is FunctionException) {
      final details = error.details;
      if (details is Map<String, dynamic>) {
        final edgeError = details['error'];
        if (edgeError is Map<String, dynamic>) {
          final code = (edgeError['code'] as String?) ?? _mapHttpStatus(error.status);
          final message =
              (edgeError['message'] as String?) ?? (fallbackMessage ?? 'Request failed');
          return _build(_normalizeCode(code), message);
        }
      }
      return _build(
        _normalizeCode(_mapHttpStatus(error.status)),
        fallbackMessage ?? 'Request failed',
      );
    }

    if (error is StorageException) {
      return _build('unknown', error.message);
    }

    return _build('unknown', fallbackMessage ?? 'Unknown error');
  }

  static Failure _build(String code, String message) {
    if (code == 'unauthorized') {
      _notifyUnauthorized();
    }
    return Failure(code: code, message: message);
  }

  /// Signals the global channel that the current token is no longer valid.
  /// The [getIt] lookup is guarded by `isRegistered` so tests that set up
  /// DI partially (or not at all) keep working.
  static void _notifyUnauthorized() {
    if (!getIt.isRegistered<UnauthorizedNotifier>()) return;
    getIt<UnauthorizedNotifier>().notifyUnauthorized();
  }

  static String _mapPostgresCode(String? postgresCode) {
    return switch (postgresCode) {
      '23505' => 'conflict',
      '23503' => 'validation',
      '22P02' => 'validation',
      '42501' => 'forbidden',
      _ => 'unknown',
    };
  }

  static String _normalizeCode(String code) {
    final normalized = code.trim().toUpperCase();
    return switch (normalized) {
      'UNAUTHORIZED' => 'unauthorized',
      'FORBIDDEN' => 'forbidden',
      'NOT_FOUND' => 'not_found',
      'VALIDATION_ERROR' => 'validation',
      'CONFLICT' => 'conflict',
      'RATE_LIMITED' => 'rate_limited',
      'EXTERNAL_API_ERROR' => 'external_api_error',
      'INTERNAL_ERROR' => 'internal_server_error',
      _ => code,
    };
  }

  static String _mapHttpStatus(int status) {
    return switch (status) {
      401 => 'unauthorized',
      403 => 'forbidden',
      404 => 'not_found',
      409 => 'conflict',
      422 => 'validation',
      429 => 'rate_limited',
      _ => 'unknown',
    };
  }
}
