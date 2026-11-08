import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/env.dart';

class FootballApiService {
  static Map<String, String> get _headers => {
    'Authorization': 'Bearer ${Env.footballApiToken}', // Usa o token do .env
  };

  /// Busca a lista de partidas do Brasileirão (Campeonato ID 10)
  static Future<List<dynamic>> getMatches() async {
    final response = await http.get(
      Uri.parse('${Env.footballApiUrl}/campeonatos/10/partidas'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao carregar partidas: ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }

  /// Busca os detalhes de uma partida específica (usado no Conferir Resultados)
  static Future<Map<String, dynamic>> getMatchById(int id) async {
    final response = await http.get(
      Uri.parse('${Env.footballApiUrl}/partidas/$id'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Falha ao carregar detalhes da partida: ${response.statusCode}',
      );
    }

    return jsonDecode(response.body);
  }
}
