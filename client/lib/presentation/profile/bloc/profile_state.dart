part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, loaded, error }

@freezed
abstract class ProfileState with _$ProfileState {
  const ProfileState._();

  const factory ProfileState({
    @Default(ProfileStatus.initial) ProfileStatus status,
    ProfileEntity? profile,
    @Default(false) bool isUpdating,
    Failure? failure,
  }) = _ProfileState;

  bool get hasProfile => profile != null;
}
