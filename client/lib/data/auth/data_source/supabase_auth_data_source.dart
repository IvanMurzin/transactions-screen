import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:transaction_screen/core/config/app_config.dart';
import 'package:transaction_screen/core/supabase/supabase_constants.dart';
import 'package:transaction_screen/core/supabase/supabase_edge_functions.dart';
import 'package:transaction_screen/data/auth/data_source/i_auth_data_source.dart';
import 'package:transaction_screen/data/auth/dto/auth_session_dto.dart';
import 'package:transaction_screen/domain/auth/entity/auth_provider.dart';

@LazySingleton(as: IAuthDataSource)
class SupabaseAuthDataSource implements IAuthDataSource {
  SupabaseAuthDataSource(this._client, this._edgeFunctions);

  final SupabaseClient _client;
  final SupabaseEdgeFunctions _edgeFunctions;

  @override
  AuthSessionDto? currentSession() {
    final user = _client.auth.currentSession?.user;
    if (user == null) return null;
    return AuthSessionDto(userId: user.id, email: user.email ?? '');
  }

  @override
  Stream<AuthState> onAuthStateChange() => _client.auth.onAuthStateChange;

  @override
  Future<void> signInWithPassword(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUpWithPassword(String email, String password) {
    return _client.auth.signUp(email: email, password: password);
  }

  @override
  Future<AuthSessionDto?> verifySignUpOtp({required String email, required String token}) async {
    final response = await _client.auth.verifyOTP(email: email, token: token, type: OtpType.signup);
    final user = response.session?.user;
    if (user == null) return null;
    return AuthSessionDto(userId: user.id, email: user.email ?? '');
  }

  @override
  Future<void> resendSignUpOtp(String email) {
    return _client.auth.resend(
      email: email,
      type: OtpType.signup,
      emailRedirectTo: _redirectOrNull(),
    );
  }

  @override
  Future<void> signInWithOAuth(AuthProvider provider) {
    return _client.auth.signInWithOAuth(
      mapOAuthProvider(provider),
      redirectTo: _redirectOrNull(),
      queryParams: oauthQueryParams(provider),
    );
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<void> deleteMyAccount() async {
    await _edgeFunctions.invokeVoid(
      SupabaseApiRoutes.deleteMyAccount,
      body: const {'confirm': true},
    );
  }

  String? _redirectOrNull() {
    final uri = AppConfig.instance.oauthRedirectUri.trim();
    return uri.isEmpty ? null : uri;
  }

  @visibleForTesting
  static OAuthProvider mapOAuthProvider(AuthProvider provider) {
    return switch (provider) {
      AuthProvider.google => OAuthProvider.google,
      AuthProvider.apple => OAuthProvider.apple,
      AuthProvider.email => throw StateError('OAuth is not supported for $provider'),
    };
  }

  @visibleForTesting
  static Map<String, String>? oauthQueryParams(AuthProvider provider) {
    return switch (provider) {
      AuthProvider.google => const {'prompt': 'select_account'},
      AuthProvider.apple => null,
      AuthProvider.email => null,
    };
  }
}
