import 'package:injectable/injectable.dart';

import 'package:template_app/domain/auth/entity/auth_provider.dart';
import 'package:template_app/domain/auth/repository/i_auth_repository.dart';

@injectable
class GetAuthProvidersUseCase {
  GetAuthProvidersUseCase(this._repository);

  final IAuthRepository _repository;

  Future<List<AuthProvider>> call() => _repository.getAvailableProviders();
}
