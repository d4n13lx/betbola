import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiToken => dotenv.get('API_TOKEN');
  static String get apiUrl => dotenv.get('API_URL');
}
