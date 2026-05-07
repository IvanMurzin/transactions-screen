import 'package:template_app/core/types/result.dart';
import 'package:template_app/domain/auth/entity/auth_provider.dart';
import 'package:template_app/domain/auth/entity/auth_session_entity.dart';
import 'package:template_app/domain/auth/entity/otp_verification_entity.dart';

/// Contract for the auth subsystem.
///
/// Returns [Result]s for one-shot operations and a stream of session
/// snapshots for the listening UI. OTP-related members are no-ops in
/// products that disable email confirmation (`AppConfig.isOtpEnabled`).
abstract interface class IAuthRepository {
  Stream<AuthSessionEntity?> watchSession();
  Future<AuthSessionEntity?> getCachedSession();

  Future<Result<void>> signInWithPassword(String email, String password);
  Future<Result<OtpVerificationEntity>> signUpWithPassword(String email, String password);

  Future<Result<AuthSessionEntity>> verifySignUpOtp(String email, String code);
  Future<Result<void>> resendSignUpOtp(String email);

  Future<Result<AuthSessionEntity>> signInWithOAuth(AuthProvider provider);
  Future<List<AuthProvider>> getAvailableProviders();

  Future<Result<void>> signOut();
  Future<Result<void>> deleteAccount();
}
