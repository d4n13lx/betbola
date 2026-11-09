import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';
import '../../core/services/user_service.dart';
import '../../core/widgets/app_card.dart';

/// Tela de Estatísticas e Resultados — Pedro
class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isLoading = true;
  List<dynamic> _bets = [];
  String? _erro;

  // Estatísticas
  int _totalPontos = 0;
  int _acertos = 0;
  int _erros = 0;

  @override
  void initState() {
    super.initState();
    _fetchBets();
  }

  Future<void> _fetchBets() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });

    final userId = await UserService.getUserId();

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/bets'),
        headers: {'X-User-Id': userId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        int pontos = 0;
        int acertos = 0;
        int erros = 0;

        for (var bet in data) {
          if (bet['status'] == 'acertou') {
            acertos++;
            pontos += (bet['pontos'] as int? ?? 0);
          } else if (bet['status'] == 'errou') {
            erros++;
          }
        }

        if (mounted) {
          setState(() {
            _bets = data;
            _totalPontos = pontos;
            _acertos = acertos;
            _erros = erros;
          });
        }
      } else {
        throw Exception('Erro ao carregar dados do servidor.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _erro = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deletarAposta(dynamic id) async {
    final userId = await UserService.getUserId();
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8080/api/bets/$id'),
        headers: {'X-User-Id': userId},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aposta excluída!')),
          );
        }
        _fetchBets(); // Recarrega a lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao excluir aposta.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalApostas = _acertos + _erros;
    double aproveitamento = totalApostas > 0 ? (_acertos / totalApostas) : 0.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Resultados', style: TextStyle(fontSize: 18)),
            Text('Seu histórico completo', style: AppStyles.appBarSubtitle),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _erro != null
              ? Center(
                  child: Text('Erro: $_erro',
                      style: const TextStyle(color: AppColors.danger)))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card de Estatísticas Principal
                      AppCard(
                        radius: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Aproveitamento',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 16)),
                                Text(
                                  '${(aproveitamento * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: aproveitamento,
                              backgroundColor: AppColors.surfaceLight,
                              color: AppColors.primary,
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatBadge(
                                    'Acertos', '$_acertos', AppColors.primary),
                                _buildStatBadge(
                                    'Erros', '$_erros', AppColors.danger),
                                _buildStatBadge(
                                    'Pontos', '$_totalPontos', Colors.amber),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      const Text('HISTÓRICO DE PALPITES',
                          style: AppStyles.tagStyle),
                      const SizedBox(height: 8),
                      Text('${_bets.length} palpites registrados',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      Expanded(
                        child: _bets.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                itemCount: _bets.length,
                                itemBuilder: (context, index) {
                                  final bet = _bets[index];
                                  return _buildBetCard(bet);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // Mini-cards (chips) dentro do Card de Estatísticas
  Widget _buildStatBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  // Estado Vazio (Nenhuma aposta)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.history_toggle_off,
              size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text('Nenhum palpite feito ainda.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }

  // Card individual do Histórico de Apostas
  Widget _buildBetCard(dynamic bet) {
    final isPendente = bet['status'] == 'pendente';
    final isAcertou = bet['status'] == 'acertou';

    final Color statusColor = isPendente
        ? Colors.amber
        : isAcertou
            ? AppColors.primary
            : AppColors.danger;

    final IconData statusIcon = isPendente
        ? Icons.access_time_filled
        : isAcertou
            ? Icons.check_circle
            : Icons.cancel;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppStyles.cardDecoration(
        color: AppColors.surfaceLight,
        radius: 16,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(statusIcon, color: statusColor, size: 28),
        ),
        title: Text(
          '${bet['time_casa']} x ${bet['time_fora']}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Palpite: ${bet['previsao'].toString().toUpperCase()}\nPlacar real: ${bet['placar_real'] ?? 'Aguardando'}',
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
        ),
        trailing: isPendente
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                tooltip: 'Excluir palpite',
                onPressed: () => _deletarAposta(bet['id']),
              )
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isAcertou
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isAcertou ? '+${bet['pontos']} pts' : '0 pts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        isAcertou ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
      ),
    );
  }
}
