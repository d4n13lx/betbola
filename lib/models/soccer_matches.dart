import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../core/services/user_service.dart';
import 'partida.dart';

/// Provedor de estado das partidas e apostas do usuário.
class SoccerMatches extends ChangeNotifier {
  List<Partida> _items = [];
  final Map<int, String> _userBets = {};
  bool _carregando = false;
  String? _erro;

  List<Partida> get items => List.unmodifiable(_items);
  Map<int, String> get userBets => Map.unmodifiable(_userBets);
  bool get carregando => _carregando;
  String? get erro => _erro;
  int get length => _items.length;

  Partida getMatchById(int id) => _items[id];

  Future<void> init() async {
    await loadData();
    await fetchBets();
  }

  Future<void> loadData() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final data = await ApiService.get('/api/matches', userId: '');
      final list = data as List;
      _items =
          list.map((e) => Partida.fromMap(e as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      _erro = e.message;
    } catch (e) {
      _erro = 'Erro ao carregar partidas.';
      if (kDebugMode) debugPrint('Erro loadData: $e');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> fetchBets() async {
    try {
      final userId = await UserService.getUserId();
      final data = await ApiService.get('/api/bets', userId: userId);
      final list = data as List;
      _userBets.clear();
      for (var bet in list) {
        _userBets[bet['partida_id']] = bet['previsao'];
      }
      notifyListeners();
    } on ApiException catch (e) {
      if (kDebugMode) debugPrint('Erro fetchBets: ${e.message}');
    }
  }

  void addBet(int partidaId, String previsao) {
    _userBets[partidaId] = previsao;
    notifyListeners();
  }
}
