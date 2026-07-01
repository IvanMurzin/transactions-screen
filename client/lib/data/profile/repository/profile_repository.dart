import 'package:injectable/injectable.dart';

import 'package:transaction_screen/core/logger/logger.dart';
import 'package:transaction_screen/core/supabase/supabase_failure_mapper.dart';
import 'package:transaction_screen/core/types/result.dart';
import 'package:transaction_screen/data/profile/data_source/supabase_profile_data_source.dart';
import 'package:transaction_screen/data/profile/mapper/profile_mapper.dart';
import 'package:transaction_screen/domain/profile/entity/profile_entity.dart';
import 'package:transaction_screen/domain/profile/repository/i_profile_repository.dart';

@LazySingleton(as: IProfileRepository)
class ProfileRepository implements IProfileRepository {
  ProfileRepository(this._dataSource);

  final SupabaseProfileDataSource _dataSource;

  @override
  Future<Result<ProfileEntity>> getProfile() async {
    try {
      final dto = await _dataSource.fetchProfile();
      logger.i('ProfileRepository.getProfile success');
      return Success(ProfileMapper.toEntity(dto));
    } catch (error) {
      logger.e('ProfileRepository.getProfile failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to load profile'),
      );
    }
  }

  @override
  Future<Result<ProfileEntity>> updateProfile({
    String? displayName,
    String? avatarUrl,
    String? locale,
  }) async {
    try {
      final dto = await _dataSource.updateProfile(
        displayName: displayName,
        avatarUrl: avatarUrl,
        locale: locale,
      );
      logger.i('ProfileRepository.updateProfile success');
      return Success(ProfileMapper.toEntity(dto));
    } catch (error) {
      logger.e('ProfileRepository.updateProfile failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to update profile'),
      );
    }
  }
}
