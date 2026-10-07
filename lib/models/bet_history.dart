// lib/models/bet_history.dart
/// Representa uma entrada do histórico de apostas do usuário.
class BetHistory {
  final String game;
  final String bet;
  final String result;
  final bool success;
  final String points;

  const BetHistory({
    required this.game,
    required this.bet,
    required this.result,
    required this.success,
    required this.points,
  });

  /// Dados mockados
  static const List<BetHistory> mockHistory = [
    BetHistory(
      game: 'Palmeiras x Santos',
      bet: 'Palpite: Palmeiras',
      result: '2 × 0',
      success: true,
      points: '+100',
    ),
    BetHistory(
      game: 'Botafogo x Bahia',
      bet: 'Palpite: Empate',
      result: '3 × 1',
      success: false,
      points: '0',
    ),
    BetHistory(
      game: 'Grêmio x Cruzeiro',
      bet: 'Palpite: Cruzeiro',
      result: '1 × 2',
      success: true,
      points: '+100',
    ),
    BetHistory(
      game: 'Fluminense x Vasco',
      bet: 'Palpite: Fluminense',
      result: '0 × 1',
      success: false,
      points: '0',
    ),
  ];
}
