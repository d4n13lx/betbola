import 'package:dotenv/dotenv.dart';

class Env {
  static final _env = DotEnv(includePlatformEnvironment: true)..load();

  static String get supabaseUrl => _env['SUPABASE_URL'] ?? '';
  static String get supabaseKey => _env['SUPABASE_ANON_KEY'] ?? '';
  static String get footballApiUrl =>
      _env['FOOTBALL_API_URL'] ?? 'https://api.api-futebol.com.br/v1';
  static String get footballApiToken => _env['FOOTBALL_API_TOKEN'] ?? '';
}
