import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';
import '../../core/services/user_service.dart';

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
        title: const Text('Estatísticas e Resultados',
            style: TextStyle(fontSize: 18)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(child: Text('Erro: $_erro'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderLight),
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.surface,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Aproveitamento',
                                    style: TextStyle(
                                        color: AppColors.textSecondary)),
                                Text(
                                    '${(aproveitamento * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: aproveitamento,
                              backgroundColor:
                                  AppColors.danger.withValues(alpha: 0.3),
                              color: AppColors.primary,
                              minHeight: 8,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('• $_acertos acertos',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                                Text('• $_erros erros',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                                Text('• $_totalPontos pts',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('HISTÓRICO', style: AppStyles.tagStyle),
                      const SizedBox(height: 8),
                      Text('${_bets.length} palpites',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _bets.isEmpty
                            ? const Center(
                                child: Text('Nenhum palpite feito ainda.',
                                    style: TextStyle(
                                        color: AppColors.textSecondary)))
                            : ListView.separated(
                                itemCount: _bets.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(color: AppColors.border),
                                itemBuilder: (context, index) {
                                  final bet = _bets[index];
                                  final isPendente =
                                      bet['status'] == 'pendente';
                                  final isAcertou = bet['status'] == 'acertou';

                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isPendente
                                            ? Colors.amber
                                                .withValues(alpha: 0.1)
                                            : isAcertou
                                                ? AppColors.primary
                                                    .withValues(alpha: 0.1)
                                                : AppColors.danger
                                                    .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        isPendente
                                            ? Icons.hourglass_empty
                                            : isAcertou
                                                ? Icons.check
                                                : Icons.close,
                                        color: isPendente
                                            ? Colors.amber
                                            : isAcertou
                                                ? AppColors.primary
                                                : AppColors.danger,
                                      ),
                                    ),
                                    title: Text(
                                        '${bet['time_casa']} x ${bet['time_fora']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    subtitle: Text(
                                        'Palpite: ${bet['previsao']} | Placar: ${bet['placar_real'] ?? '-'}',
                                        style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12)),
                                    trailing: isPendente
                                        ? IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: AppColors.danger),
                                            onPressed: () =>
                                                _deletarAposta(bet['id']),
                                          )
                                        : Text('${bet['pontos']} pts',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
