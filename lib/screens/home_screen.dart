import 'package:betbola/core/theme/app_colors.dart';
import 'package:betbola/core/theme/app_styles.dart';
import 'package:betbola/core/widgets/team_shield.dart';
import 'package:betbola/models/partida.dart';
import 'package:betbola/models/soccer_matches.dart';
import 'package:betbola/screens/detail_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Tela de Partidas (Home) — Daniel
///
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SoccerMatches>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final matches = context.watch<SoccerMatches>();

    if (matches.carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (matches.erro != null) {
      return Center(child: Text(matches.erro!));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: const [
            Text('Bet na Bola',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
            Text('A rodada começa aqui',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                )),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('B',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 26)),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchField(),
            const SizedBox(height: 24),
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final match = matches.getMatchById(index);
                  return _GameCard(
                    match: matches.getMatchById(index),
                    isFeatured: index == 0,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DetailScreen(match: match)),
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
  final Partida match;
  final bool isFeatured;
  final VoidCallback onTap;

  const _GameCard({
    required this.match,
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
                  Text(match.dataRealizacao,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 16)),
                  if (isFeatured)
                    const Text('Destaque',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 235, 80),
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  // LADO ESQUERDO (Mandante)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Flexible evita erro de overflow se o nome do time for muito grande
                        Flexible(
                          child: Text(
                            match.timeMandante.nomePopular,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TeamShield(escudo: match.timeMandante.escudo),
                      ],
                    ),
                  ),

                  // CENTRO ABSOLUTO (Ícone)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(CupertinoIcons.xmark),
                  ),

                  // LADO DIREITO (Visitante)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TeamShield(escudo: match.timeVisitante.escudo),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            match.timeVisitante.nomePopular,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
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
