import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_verification_entity.freezed.dart';

/// Lightweight handle returned by sign-up when OTP verification is on.
/// Carries the email the OTP was sent to so the OTP page can resend or
/// re-render the destination address.
@freezed
abstract class OtpVerificationEntity with _$OtpVerificationEntity {
  const factory OtpVerificationEntity({required String email}) = _OtpVerificationEntity;
}
