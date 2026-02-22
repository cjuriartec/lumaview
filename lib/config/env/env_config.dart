abstract class EnvConfig {
  String get supabaseUrl;
  String get supabaseAnonKey;
}

class DefaultEnvConfig implements EnvConfig {
  const DefaultEnvConfig();

  @override
  String get supabaseUrl => const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://YOUR-PROJECT.supabase.co',
      );

  @override
  String get supabaseAnonKey => const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: 'YOUR_SUPABASE_ANON_KEY',
      );
}

class Env {
  static const EnvConfig config = DefaultEnvConfig();
}

