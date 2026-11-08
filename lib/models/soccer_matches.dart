// lib/models/bet_history.dart
import 'dart:convert';
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
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/matches'),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro no servidor: ${response.statusCode}');
      }

      final List<dynamic> map = json.decode(response.body);
      items = [
        for (final bruto in map) Partida.fromMap(bruto as Map<String, dynamic>)
      ];
    } catch (e) {
      erro = "Não foi possível carregar as partidas. O backend está rodando?";
      print(e);
    }

    carregando = false;
    notifyListeners();
  }

  Future<void> fetchBets() async {}
}
