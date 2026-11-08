// lib/models/bet_history.dart
import 'dart:convert';
import 'dart:io';

import 'package:betbola/core/env/env.dart';
import 'package:betbola/models/partida.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Lista das partidas em andamento ao vivo.
class SoccerMatches extends ChangeNotifier {
  List<Partida> items = [];

  final Set<Map<int, String>> bets = {};

  bool carregando = false;
  String? erro;

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
      final response = await http.get(Uri.parse('${Env.apiUrl}/ao-vivo'),
          headers: {HttpHeaders.authorizationHeader: 'Bearer ${Env.apiToken}'});

      if (response.statusCode != 200) {
        throw Exception(response.statusCode);
      }

      final map = json.decode(response.body);

      items = [
        for (final bruto in map) Partida.fromMap(bruto as Map<String, dynamic>)
      ];
    } catch (e) {
      erro = "Não foi possível carregar os dados da api.";
    }

    carregando = false;
    notifyListeners();
  }

  Future<void> fetchBets() async {}
}
