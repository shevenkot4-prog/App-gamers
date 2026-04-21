import 'package:supabase_flutter/supabase_flutter.dart';

import 'env_config.dart';

class SupabaseBootstrap {
  static Future<void> initialize() async {
    EnvConfig.validate();
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
  }
}
