import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/soccer_matches.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/team_shield.dart';
import 'profile_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Garante o carregamento das partidas e apostas ao abrir a tela inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SoccerMatches>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SoccerMatches>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Olá, Torcedor!',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Bet na Bola',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(SoccerMatches provider) {
    // 1. Estado de Carregamento
    if (provider.carregando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // 2. Estado de Erro
    if (provider.erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                provider.erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => provider.init(),
                child: const Text('Tentar Novamente',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      );
    }

    // 3. Estado de Lista Vazia
    if (provider.items.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma partida disponível no momento.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      );
    }

    // 4. Lista de Partidas com Título e Pull-to-refresh
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Novo cabeçalho indicativo
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PARTIDAS DA RODADA',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Escolha um jogo e faça seu palpite',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // A lista precisa usar o Expanded para ocupar o resto da tela
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => provider.init(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.items.length,
              itemBuilder: (context, index) {
                final match = provider.items[index];
                final apostaFeita = provider.userBets[match.id];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(match: match),
                        ),
                      );
                    },
                    child: AppCard(
                      radius: 16,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                match.dataRealizacao,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              if (apostaFeita != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: AppColors.primary, width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle,
                                          size: 14, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        _traduzirAposta(apostaFeita),
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    TeamShield(
                                        escudo: match.timeMandante.escudo,
                                        size: 50),
                                    const SizedBox(height: 8),
                                    Text(
                                      match.timeMandante.nomePopular,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'VS',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    TeamShield(
                                        escudo: match.timeVisitante.escudo,
                                        size: 50),
                                    const SizedBox(height: 8),
                                    Text(
                                      match.timeVisitante.nomePopular,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Função auxiliar para deixar o texto do selo mais bonito
  String _traduzirAposta(String valor) {
    if (valor == 'casa') return 'Mandante';
    if (valor == 'empate') return 'Empate';
    if (valor == 'fora') return 'Visitante';
    return valor;
  }
}
