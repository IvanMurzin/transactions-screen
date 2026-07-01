import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:transaction_screen/core/config/app_config.dart';

abstract final class SupabaseInitializer {
  static Future<void> init() {
    final config = AppConfig.instance;
    final debug = config.env.toLowerCase() == 'dev';
    return Supabase.initialize(
      url: config.supabaseUrl,
      anonKey: config.supabaseAnonKey,
      debug: debug,
    );
  }
}
