import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@module
abstract class SupabaseModule {
  SupabaseClient get supabaseClient => Supabase.instance.client;

  /// Maximum time `AuthRepository.signInWithOAuth` waits for a `signedIn`
  /// auth state event before failing with a timeout. Tunable per app.
  @Named('oauthSignInTimeout')
  Duration get oAuthSignInTimeout => const Duration(seconds: 90);
}
