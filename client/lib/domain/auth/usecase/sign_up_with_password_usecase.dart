import 'package:injectable/injectable.dart';

import 'package:template_app/core/types/result.dart';
import 'package:template_app/domain/auth/entity/otp_verification_entity.dart';
import 'package:template_app/domain/auth/repository/i_auth_repository.dart';

@injectable
class SignUpWithPasswordUseCase {
  SignUpWithPasswordUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Result<OtpVerificationEntity>> call(String email, String password) {
    return _repository.signUpWithPassword(email, password);
  }
}
