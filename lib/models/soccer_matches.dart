import 'dart:convert';
import 'package:betbola/models/partida.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import adicionado
import '../core/services/user_service.dart';

class SoccerMatches extends ChangeNotifier {
  List<Partida> items = [];
  Map<int, String> userBets = {};
  bool carregando = false;
  String? erro;

  // Captura a URL do .env com um fallback de segurança
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080';
  int get length => items.length;
  Partida getMatchById(int id) => items[id];

  Future<void> init() async {
    await loadData();
    await fetchBets();
  }

  Future<void> loadData() async {
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      // Uso da variável baseUrl
      final response = await http.get(Uri.parse('$baseUrl/api/matches'));

      if (response.statusCode != 200) {
        throw Exception('Erro na API: ${response.statusCode}');
      }

      final map = json.decode(response.body);
      items = [
        for (final bruto in map) Partida.fromMap(bruto as Map<String, dynamic>)
      ];
    } catch (e) {
      erro = "Não foi possível carregar as partidas. O backend está rodando?";
      debugPrint(e.toString());
    }

    carregando = false;
    notifyListeners();
  }

  Future<void> fetchBets() async {
    try {
      final userId = await UserService.getUserId();
      // Uso da variável baseUrl
      final response = await http.get(
        Uri.parse('$baseUrl/api/bets'),
        headers: {'X-User-Id': userId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        userBets.clear();

        for (var bet in data) {
          userBets[bet['partida_id']] = bet['previsao'];
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao buscar apostas: $e');
    }
  }

  void addBet(int partidaId, String previsao) {
    userBets[partidaId] = previsao;
    notifyListeners();
  }
}
