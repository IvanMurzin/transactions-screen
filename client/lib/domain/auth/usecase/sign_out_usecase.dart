import 'package:injectable/injectable.dart';

import 'package:template_app/core/types/result.dart';
import 'package:template_app/domain/auth/repository/i_auth_repository.dart';

@injectable
class SignOutUseCase {
  SignOutUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Result<void>> call() => _repository.signOut();
}
