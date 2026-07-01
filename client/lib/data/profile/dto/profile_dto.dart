import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:transaction_screen/core/types/json_name.dart';

part 'profile_dto.freezed.dart';
part 'profile_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class ProfileDto with _$ProfileDto {
  const factory ProfileDto({
    @JsonName('user_id') required String userId,
    required String email,
    @JsonName('display_name') String? displayName,
    @JsonName('avatar_url') String? avatarUrl,
    @Default('en') String locale,
    @Default('free') String plan,
    @JsonName('revenuecat_app_user_id') String? revenuecatAppUserId,
    @JsonName('created_at') String? createdAtIso,
    @JsonName('updated_at') String? updatedAtIso,
  }) = _ProfileDto;

  factory ProfileDto.fromJson(Map<String, dynamic> json) => _$ProfileDtoFromJson(json);

  /// Adapter for the `/api/me` envelope: `{ profile: {...} }`.
  factory ProfileDto.fromMeJson(Map<String, dynamic> json) {
    final profile = (json['profile'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    return ProfileDto.fromJson(profile);
  }
}
