import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/team_shield.dart';
import '../../models/game.dart';

/// Tela de Detalhe da Partida — Matheus
class DetailScreen extends StatefulWidget {
  final Game game;
  const DetailScreen({super.key, required this.game});

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
            _buildSelectedBetInfo(),
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
          const Text('Hoje • 21:30',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TeamInfo(
                  name: widget.game.home,
                  color: widget.game.homeColor,
                  type: 'Mandante'),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('VS',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              _TeamInfo(
                  name: widget.game.away,
                  color: widget.game.awayColor,
                  type: 'Visitante'),
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
                // ✅ era .withOpacity(0.1) — linha 99
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

  Widget _buildSelectedBetInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Seu palpite',
            style: TextStyle(color: AppColors.textSecondary)),
        Text('$selectedBet: ${widget.game.home}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
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
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Palpite salvo! (Na próxima etapa)')),
          );
        },
        child: const Text('Salvar Palpite',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _TeamInfo extends StatelessWidget {
  final String name;
  final Color color;
  final String type;

  const _TeamInfo(
      {required this.name, required this.color, required this.type});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TeamShield(name: name, color: color, size: 60),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(type,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }
}
