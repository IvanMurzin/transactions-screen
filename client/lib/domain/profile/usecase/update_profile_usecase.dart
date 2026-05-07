import 'package:injectable/injectable.dart';

import 'package:template_app/core/types/result.dart';
import 'package:template_app/domain/profile/entity/profile_entity.dart';
import 'package:template_app/domain/profile/repository/i_profile_repository.dart';

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
