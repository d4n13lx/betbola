import 'dart:io';

import 'package:dotenv/dotenv.dart';

class Env {
  static final DotEnv _env = DotEnv(includePlatformEnvironment: true);
  static bool _loaded = false;

  static void load() {
    if (_loaded) return;

    // Procura o .env em todos os lugares possíveis
    final possiblePaths = ['.env', 'backend/.env', '../.env'];

    for (var path in possiblePaths) {
      if (File(path).existsSync()) {
        _env.load([path]);
        _loaded = true;
        print('✅ .env carregado de: $path');
        print('   SUPABASE_URL: [${_env['SUPABASE_URL']}]');
        return;
      }
    }
    print('❌ ERRO FATAL: Arquivo .env não encontrado!');
  }

  static String get supabaseUrl => _env['SUPABASE_URL'] ?? '';
  static String get supabaseKey => _env['SUPABASE_ANON_KEY'] ?? '';
  static String get footballApiUrl =>
      _env['FOOTBALL_API_URL'] ?? 'https://api.api-futebol.com.br/v1';
  static String get footballApiToken => _env['FOOTBALL_API_TOKEN'] ?? '';
}
