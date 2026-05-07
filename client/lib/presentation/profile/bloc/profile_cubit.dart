import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import 'package:template_app/core/logger/logger.dart';
import 'package:template_app/core/types/failure.dart';
import 'package:template_app/core/types/result.dart';
import 'package:template_app/domain/profile/entity/profile_entity.dart';
import 'package:template_app/domain/profile/usecase/get_profile_usecase.dart';
import 'package:template_app/domain/profile/usecase/update_profile_usecase.dart';

part 'profile_cubit.freezed.dart';
part 'profile_state.dart';

/// Loads and mutates the current user's profile.
///
/// Call [load] once after sign-in (typically from a session listener) and
/// again on pull-to-refresh. [updateProfile] performs partial updates —
/// pass only the fields the user changed.
@lazySingleton
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._getProfile, this._updateProfile) : super(const ProfileState());

  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(status: ProfileStatus.loading, failure: null));
    }
    final result = await _getProfile();
    if (isClosed) return;
    switch (result) {
      case Success<ProfileEntity>(value: final profile):
        emit(state.copyWith(status: ProfileStatus.loaded, profile: profile, failure: null));
      case FailureResult<ProfileEntity>(failure: final failure):
        logger.e('ProfileCubit.load failed: ${failure.code}');
        emit(state.copyWith(status: ProfileStatus.error, failure: failure));
    }
  }

  Future<void> updateProfile({String? displayName, String? avatarUrl, String? locale}) async {
    if (state.isUpdating) return;
    emit(state.copyWith(isUpdating: true, failure: null));
    final result = await _updateProfile(
      displayName: displayName,
      avatarUrl: avatarUrl,
      locale: locale,
    );
    if (isClosed) return;
    switch (result) {
      case Success<ProfileEntity>(value: final profile):
        emit(
          state.copyWith(
            status: ProfileStatus.loaded,
            profile: profile,
            isUpdating: false,
            failure: null,
          ),
        );
      case FailureResult<ProfileEntity>(failure: final failure):
        logger.e('ProfileCubit.updateProfile failed: ${failure.code}');
        emit(state.copyWith(isUpdating: false, failure: failure));
    }
  }

  /// Replace the in-memory profile, e.g. after another cubit (subscription
  /// sync) reloaded it. Use sparingly — prefer [load].
  void replace(ProfileEntity profile) {
    emit(state.copyWith(status: ProfileStatus.loaded, profile: profile, failure: null));
  }

  void clear() {
    emit(const ProfileState());
  }
}
