import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  int _pontos = 100;
  String? _bloqueadoAte;
  bool _isLoading = false;
  String? _erro;

  int get pontos => _pontos;
  String? get bloqueadoAte => _bloqueadoAte;
  bool get isLoading => _isLoading;
  String? get erro => _erro;
  bool get estaBloqueado =>
      _bloqueadoAte != null &&
      DateTime.parse(_bloqueadoAte!).isAfter(DateTime.now());

  String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  Future<void> fetchUserStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      final userId = await UserService.getUserId();
      final response = await http.get(
        Uri.parse('$baseUrl/api/usuarios/status'),
        headers: {'X-User-Id': userId},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _pontos = data['pontos'] ?? 100;
        _bloqueadoAte = data['bloqueado_ate'];
        _erro = null;
      }
    } catch (e) {
      _erro = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
