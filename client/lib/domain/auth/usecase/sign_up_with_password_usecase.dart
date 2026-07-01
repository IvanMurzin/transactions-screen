import 'package:injectable/injectable.dart';

import 'package:transaction_screen/core/types/result.dart';
import 'package:transaction_screen/domain/auth/entity/otp_verification_entity.dart';
import 'package:transaction_screen/domain/auth/repository/i_auth_repository.dart';

@injectable
class SignUpWithPasswordUseCase {
  SignUpWithPasswordUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Result<OtpVerificationEntity>> call(String email, String password) {
    return _repository.signUpWithPassword(email, password);
  }
}
