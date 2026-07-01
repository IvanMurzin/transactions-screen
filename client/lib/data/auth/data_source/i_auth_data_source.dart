import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:transaction_screen/data/auth/dto/auth_session_dto.dart';
import 'package:transaction_screen/domain/auth/entity/auth_provider.dart';

abstract interface class IAuthDataSource {
  AuthSessionDto? currentSession();
  Stream<AuthState> onAuthStateChange();

  Future<void> signInWithPassword(String email, String password);
  Future<void> signUpWithPassword(String email, String password);
  Future<AuthSessionDto?> verifySignUpOtp({required String email, required String token});
  Future<void> resendSignUpOtp(String email);

  Future<void> signInWithOAuth(AuthProvider provider);

  Future<void> signOut();
  Future<void> deleteMyAccount();
}
