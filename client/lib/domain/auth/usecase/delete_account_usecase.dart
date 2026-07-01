import 'package:injectable/injectable.dart';

import 'package:transaction_screen/core/types/result.dart';
import 'package:transaction_screen/domain/auth/repository/i_auth_repository.dart';

@injectable
class DeleteAccountUseCase {
  DeleteAccountUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Result<void>> call() => _repository.deleteAccount();
}
