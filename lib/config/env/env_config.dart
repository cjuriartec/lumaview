abstract class EnvConfig {
  String get supabaseUrl;
  String get supabaseAnonKey;
  String get androidClientId;
  String get serverClientId;
}

class DefaultEnvConfig implements EnvConfig {
  const DefaultEnvConfig();

  @override
  String get supabaseUrl => const String.fromEnvironment('SUPABASE_URL');

  @override
  String get supabaseAnonKey =>
      const String.fromEnvironment('SUPABASE_ANON_KEY');

  @override
  String get androidClientId =>
      const String.fromEnvironment('LUMAVIEW_ANDROID_CLIENT_ID');

  @override
  String get serverClientId =>
      const String.fromEnvironment('LUMAVIEW_ANDROID_SERVER_CLIENT_ID');
}

class Env {
  static const EnvConfig config = DefaultEnvConfig();
}
