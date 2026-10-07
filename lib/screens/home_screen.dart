import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';
import '../../core/widgets/team_shield.dart';
import '../../models/game.dart';
import 'detail_screen.dart';

/// Tela de Partidas (Home) — Daniel
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Bet na Bola',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('A rodada começa aqui', style: AppStyles.appBarSubtitle),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('B',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchField(),
            const SizedBox(height: 24),
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: Game.mockGames.length,
                itemBuilder: (context, index) {
                  final game = Game.mockGames[index];
                  return _GameCard(
                    game: game,
                    isFeatured: index == 0,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DetailScreen(game: game)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Pesquisar time...',
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('BRASILEIRÃO SÉRIE A', style: AppStyles.tagStyle),
            Text('Próximos Jogos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Rodada 12',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}

/// Card de partida isolado — permite const e evita rebuild do card inteiro.
class _GameCard extends StatelessWidget {
  final Game game;
  final bool isFeatured;
  final VoidCallback onTap;

  const _GameCard({
    required this.game,
    required this.isFeatured,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppStyles.cardDecoration(color: AppColors.surfaceLight),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(game.date,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  if (isFeatured)
                    const Text('Destaque',
                        style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(game.home,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  TeamShield(name: game.home, color: game.homeColor),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('X',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold)),
                  ),
                  TeamShield(name: game.away, color: game.awayColor),
                  const SizedBox(width: 8),
                  Text(game.away,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Toque para dar seu palpite ',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  Text('→',
                      style: TextStyle(color: AppColors.primary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
