import 'package:betbola/models/partida.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/team_shield.dart';
import 'package:http/http.dart' as http;
import '../../core/services/user_service.dart';
import 'dart:convert';

/// Tela de Detalhe da Partida — Matheus
class DetailScreen extends StatefulWidget {
  final Partida match;
  const DetailScreen({super.key, required this.match});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String selectedBet = 'Mandante';

  static const List<String> _betOptions = ['Mandante', 'Empate', 'Visitante'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Detalhe da Partida', style: TextStyle(fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMatchCard(),
            const SizedBox(height: 32),
            const Text('SEU JOGO, SUA ESCOLHA', style: AppStyles.tagStyle),
            const Text('Escolha seu palpite:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildBetSelector(),
            const Spacer(),
            const SizedBox(height: 16),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard() {
    return AppCard(
      radius: 20,
      child: Column(
        children: [
          Text(widget.match.dataRealizacao,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 18)),
          const SizedBox(height: 16),
          Row(
            children: [
              // LADO ESQUERDO (Mandante)
              Expanded(
                child: _TeamInfo(
                  name: widget.match.timeMandante.nomePopular,
                  escudo: widget.match.timeMandante.escudo,
                  type: 'Mandante',
                ),
              ),

              // CENTRO ABSOLUTO ("VS")
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'VS',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 32),
                ),
              ),

              // LADO DIREITO (Visitante)
              Expanded(
                child: _TeamInfo(
                  name: widget.match.timeVisitante.nomePopular,
                  escudo: widget.match.timeVisitante.escudo,
                  type: 'Visitante',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBetSelector() {
    return Row(
      children: _betOptions.map((option) {
        final isSelected = selectedBet == option;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedBet = option),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surface,
                border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  option,
                  style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () async {
          // Mapeia a string da tela para o padrão do banco ('casa', 'empate', 'fora')
          String previsaoFormatada = 'casa';
          if (selectedBet == 'Empate') previsaoFormatada = 'empate';
          if (selectedBet == 'Visitante') previsaoFormatada = 'fora';

          final userId = await UserService.getUserId();

          try {
            final response = await http.post(
              Uri.parse('http://10.0.2.2:8080/api/bets'),
              headers: {
                'Content-Type': 'application/json',
                'X-User-Id': userId,
              },
              body: jsonEncode({
                'partida_id': widget.match.partidaId,
                'previsao': previsaoFormatada,
              }),
            );

            if (response.statusCode == 200) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Palpite salvo com sucesso!')),
                );
                Navigator.pop(context); // Volta para a Home após salvar
              }
            } else {
              final erro = jsonDecode(response.body)['error'];
              throw Exception(erro);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro: ${e.toString()}')),
              );
            }
          }
        },
        child: Text('Apostar em $selectedBet',
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
    );
  }
}

class _TeamInfo extends StatelessWidget {
  final String name;
  final String escudo;
  final String type;

  const _TeamInfo(
      {required this.name, required this.escudo, required this.type});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TeamShield(escudo: escudo, size: 90),
        const SizedBox(height: 8),
        Text(name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        Text(type,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
      ],
    );
  }
}
