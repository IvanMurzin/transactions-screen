import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:template_app/core/supabase/supabase_constants.dart';
import 'package:template_app/core/supabase/supabase_edge_functions.dart';
import 'package:template_app/data/profile/dto/profile_dto.dart';

@lazySingleton
class SupabaseProfileDataSource {
  SupabaseProfileDataSource(this._edgeFunctions);

  final SupabaseEdgeFunctions _edgeFunctions;

  Future<ProfileDto> fetchProfile() async {
    final payload = await _edgeFunctions.invokeDataObject(
      SupabaseApiRoutes.me,
      method: HttpMethod.get,
    );
    return ProfileDto.fromMeJson(payload);
  }

  Future<ProfileDto> updateProfile({String? displayName, String? avatarUrl, String? locale}) async {
    final body = <String, dynamic>{};
    if (displayName != null) body['displayName'] = displayName;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;
    if (locale != null) body['locale'] = locale;

    final payload = await _edgeFunctions.invokeDataObject(
      SupabaseApiRoutes.profileUpdate,
      body: body,
    );
    return ProfileDto.fromMeJson(payload);
  }
}
