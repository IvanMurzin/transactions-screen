import 'package:injectable/injectable.dart';

import 'package:template_app/core/types/result.dart';
import 'package:template_app/domain/auth/repository/i_auth_repository.dart';

@injectable
class SignInWithPasswordUseCase {
  SignInWithPasswordUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Result<void>> call(String email, String password) {
    return _repository.signInWithPassword(email, password);
  }
}
