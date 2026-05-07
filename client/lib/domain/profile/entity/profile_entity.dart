import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_entity.freezed.dart';

/// Universal user profile, one row per `auth.users`.
///
/// Fields are intentionally minimal and product-agnostic. Add product-
/// specific columns in a separate spec; do not extend this entity unless
/// the addition is also universal (e.g. timezone, theme preference).
///
/// `plan` is included so subscription-aware UI can branch without a
/// separate fetch; defaults to `free` until a RevenueCat sync flips it.
@freezed
abstract class ProfileEntity with _$ProfileEntity {
  const ProfileEntity._();

  const factory ProfileEntity({
    required String userId,
    required String email,
    String? displayName,
    String? avatarUrl,
    @Default('en') String locale,
    @Default('free') String plan,
    String? revenuecatAppUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProfileEntity;

  bool get isPro => plan == 'pro';
}
