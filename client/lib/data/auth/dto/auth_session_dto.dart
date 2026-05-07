import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:template_app/core/types/json_name.dart';

part 'auth_session_dto.freezed.dart';
part 'auth_session_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class AuthSessionDto with _$AuthSessionDto {
  const factory AuthSessionDto({
    @JsonName('user_id') required String userId,
    required String email,
  }) = _AuthSessionDto;

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) => _$AuthSessionDtoFromJson(json);
}
