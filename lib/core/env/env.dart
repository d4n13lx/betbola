import 'dart:io';
import 'package:dotenv/dotenv.dart';

class Env {
  // Opcional: Você pode chamar Env.load() no seu main.dart
  // ou chamar dotenv.load diretamente lá.
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
    print('✅ .env carregado com sucesso via flutter_dotenv');
  }

  static String get footballApiUrl =>
      dotenv.env['FOOTBALL_API_URL'] ?? 'https://api.api-futebol.com.br/v1';
  static String get footballApiToken => dotenv.env['FOOTBALL_API_TOKEN'] ?? '';
}
