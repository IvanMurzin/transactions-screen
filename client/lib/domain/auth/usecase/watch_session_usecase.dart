import 'package:injectable/injectable.dart';

import 'package:template_app/domain/auth/entity/auth_session_entity.dart';
import 'package:template_app/domain/auth/repository/i_auth_repository.dart';

@injectable
class WatchSessionUseCase {
  WatchSessionUseCase(this._repository);

  final IAuthRepository _repository;

  Stream<AuthSessionEntity?> call() => _repository.watchSession();
}
