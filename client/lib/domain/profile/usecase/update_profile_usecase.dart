import 'package:injectable/injectable.dart';

import 'package:transaction_screen/core/types/result.dart';
import 'package:transaction_screen/domain/profile/entity/profile_entity.dart';
import 'package:transaction_screen/domain/profile/repository/i_profile_repository.dart';

@injectable
class UpdateProfileUseCase {
  UpdateProfileUseCase(this._repository);

  final IProfileRepository _repository;

  Future<Result<ProfileEntity>> call({String? displayName, String? avatarUrl, String? locale}) {
    return _repository.updateProfile(
      displayName: displayName,
      avatarUrl: avatarUrl,
      locale: locale,
    );
  }
}
