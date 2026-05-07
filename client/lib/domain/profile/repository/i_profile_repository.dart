import 'package:template_app/core/types/result.dart';
import 'package:template_app/domain/profile/entity/profile_entity.dart';

abstract interface class IProfileRepository {
  Future<Result<ProfileEntity>> getProfile();

  /// Partial update — pass only the fields the user changed; nulls leave
  /// the corresponding column untouched.
  Future<Result<ProfileEntity>> updateProfile({
    String? displayName,
    String? avatarUrl,
    String? locale,
  });
}
