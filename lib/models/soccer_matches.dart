// lib/models/bet_history.dart
import 'dart:convert';
import 'dart:io';

import 'package:betbola/core/env/env.dart';
import 'package:betbola/models/partida.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String cacheKey = 'cache_partidas';
const String betsKey = 'minhas_apostas';

/// Lista das partidas em andamento ao vivo.
class SoccerMatches extends ChangeNotifier {
  List<Partida> items = [];
  Map<int, String> bets = {};

  bool carregando = false;
  String? erro;

  int get length => items.length;

  // CORREÇÃO: Pegar pelo Index (posição na lista) para o ListView.builder
  Partida getMatchByIndex(int index) => items[index];

  // FUNÇÃO NOVA: Caso precise buscar pelo ID real da partida
  Partida? getMatchByRealId(int id) {
    try {
      return items.firstWhere((partida) => partida.id == id);
    } catch (e) {
      return null;
    }
  }

  // FUNÇÃO NOVA: Retorna a aposta formatada
  String getBet(int partidaId) {
    return bets[partidaId] ?? 'Toque para dar seu palpite';
  }

  Future<void> init() async {
    await loadData();
    await fetchBets();
  }

  Future<void> loadData() async {
    carregando = true;
    erro = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Env.apiUrl}/ao-vivo'),
        headers: {HttpHeaders.authorizationHeader: 'Bearer ${Env.apiToken}'},
      );

      if (response.statusCode != 200) {
        throw Exception('Erro na API: ${response.statusCode}');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          cacheKey, response.body); // Guarda a String JSON crua

      final map = json.decode(response.body);
      items = [
        for (final bruto in map) Partida.fromMap(bruto as Map<String, dynamic>)
      ];
    } catch (e) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedData = prefs.getString(cacheKey);

        if (cachedData != null) {
          final map = json.decode(cachedData);
          items = [
            for (final bruto in map)
              Partida.fromMap(bruto as Map<String, dynamic>)
          ];
        } else {
          erro =
              "Não foi possível carregar os dados da API e não há dados salvos.";
        }
      } catch (cacheError) {
        erro = "Erro ao carregar dados offline.";
      }
    }

    carregando = false;
    notifyListeners();
  }

  Future<void> saveBet(int partidaId, String palpite) async {
    // 1. Atualiza a memória
    bets[partidaId] = palpite;

    // CORREÇÃO: Avisa a tela (HomeScreen) para se redesenhar com a nova aposta
    notifyListeners();

    // 2. Salva no disco
    Map<String, String> betsConvertido =
        bets.map((key, value) => MapEntry(key.toString(), value));

    String jsonBets = json.encode(betsConvertido);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(betsKey, jsonBets);
  }

  Future<void> fetchBets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonBets = prefs.getString(betsKey);

    if (jsonBets != null) {
      Map<String, dynamic> mapaDecodificado = json.decode(jsonBets);

      bets = mapaDecodificado.map((key, value) {
        return MapEntry(int.parse(key), value.toString());
      });

      // Avisa a tela caso as apostas carreguem depois das partidas
      notifyListeners();
    }
  }
}
