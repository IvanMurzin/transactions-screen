import 'package:template_app/data/profile/dto/profile_dto.dart';
import 'package:template_app/domain/profile/entity/profile_entity.dart';

abstract final class ProfileMapper {
  static ProfileEntity toEntity(ProfileDto dto) {
    return ProfileEntity(
      userId: dto.userId,
      email: dto.email,
      displayName: dto.displayName,
      avatarUrl: dto.avatarUrl,
      locale: dto.locale,
      plan: dto.plan,
      revenuecatAppUserId: dto.revenuecatAppUserId,
      createdAt: _parseDateOrNull(dto.createdAtIso),
      updatedAt: _parseDateOrNull(dto.updatedAtIso),
    );
  }

  static ProfileDto toDto(ProfileEntity entity) {
    return ProfileDto(
      userId: entity.userId,
      email: entity.email,
      displayName: entity.displayName,
      avatarUrl: entity.avatarUrl,
      locale: entity.locale,
      plan: entity.plan,
      revenuecatAppUserId: entity.revenuecatAppUserId,
      createdAtIso: entity.createdAt?.toIso8601String(),
      updatedAtIso: entity.updatedAt?.toIso8601String(),
    );
  }

  static DateTime? _parseDateOrNull(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
