import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/env.dart';

class FootballApiService {
  static Map<String, String> get _headers => {
    'Authorization': 'Bearer ${Env.footballApiToken}',
  };

  static Future<List<dynamic>> getMatches() async {
    // final url = Uri.parse('${Env.footballApiUrl}/campeonatos/10/partidas');
    final url = Uri.parse('${Env.footballApiUrl}/ao-vivo');
    print('🔍 BUSCANDO: $url');

    final response = await http
        .get(url, headers: _headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      print('❌ ERRO API: ${response.statusCode} - ${response.body}');
      throw Exception('Falha ao carregar partidas: ${response.statusCode}');
    }

    final dynamic jsonResponse = jsonDecode(response.body);
    print('📦 TIPO DE RETORNO: ${jsonResponse.runtimeType}');

    // Tenta extrair a lista de várias maneiras
    if (jsonResponse is List) {
      return jsonResponse;
    }

    if (jsonResponse is Map) {
      print('🔑 CHAVES DISPONÍVEIS: ${jsonResponse.keys}');

      // Tenta a chave "partidas"
      if (jsonResponse.containsKey('partidas')) {
        final partidas = jsonResponse['partidas'];
        print('📋 TIPO DE PARTIDAS: ${partidas.runtimeType}');
        if (partidas is List) {
          return partidas;
        }
      }

      // Se não achou, procura qualquer valor que seja uma lista dentro do mapa
      for (var entry in jsonResponse.entries) {
        if (entry.value is List) {
          print('✅ Usando a chave "${entry.key}" que é uma lista');
          return entry.value as List;
        }
      }
    }

    print('⚠️ Não foi possível extrair uma lista. Retornando vazio.');
    return [];
  }

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
