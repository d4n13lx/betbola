import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/team_shield.dart';
import '../models/partida.dart';
import '../models/soccer_matches.dart';
import '../models/user_provider.dart';
import 'detail_screen.dart';
import 'profile_screen.dart';

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
    final pontos = context.select<UserProvider, int>((p) => p.pontos);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        toolbarHeight: 80,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Olá, Torcedor!',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            SizedBox(height: 4),
            Text('Bet na Bola',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, color: AppColors.primary, size: 18),
                    const SizedBox(width: 4),
                    Text('$pontos pts',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                  if (context.mounted) {
                    context.read<UserProvider>().fetchUserStatus();
                  }
                },
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
      body: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SoccerMatches>();

    if (provider.carregando) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (provider.erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(provider.erro!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => provider.init(),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return const _HomeContent();
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  String _filtro = 'Todas';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SoccerMatches>();
    final todas = provider.items;
    final filtradas = _aplicarFiltro(todas);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. FIX: Chips com padding na direita para não cortar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              _chip('Todas'),
              _chip('Agendada'),
              _chip('Em andamento'),
              _chip('Encerrada'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${filtradas.length} partidas',
                  style: const TextStyle(color: AppColors.textSecondary)),
              TextButton.icon(
                onPressed: () => context.read<SoccerMatches>().init(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Atualizar'),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<SoccerMatches>().init(),
            child: filtradas.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 80),
                      Center(
                        child: Text('Nenhuma partida neste filtro.',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    ],
                  )
                : ListView.builder(
                    // 2. FIX: Padding no bottom para não encostar na BottomNavBar
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filtradas.length,
                    itemBuilder: (context, index) {
                      final match = filtradas[index];
                      final aposta = provider.userBets[match.id];
                      return _MatchCard(
                        match: match,
                        apostaFeita: aposta,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => DetailScreen(match: match)),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  List<Partida> _aplicarFiltro(List<Partida> todas) {
    if (_filtro == 'Todas') return todas;
    return todas.where((p) => p.status == _filtro).toList();
  }

  Widget _chip(String valor) {
    final ativo = _filtro == valor;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(valor),
        selected: ativo,
        onSelected: (_) => setState(() => _filtro = valor),
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        backgroundColor: AppColors.surface,
        labelStyle: TextStyle(
          color: ativo ? AppColors.primary : AppColors.textSecondary,
          fontWeight: ativo ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(color: ativo ? AppColors.primary : AppColors.border),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final Partida match;
  final String? apostaFeita;
  final VoidCallback onTap;

  const _MatchCard({
    required this.match,
    this.apostaFeita,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAgendada = match.status == 'Agendada';
    final isAoVivo = match.status == 'Em andamento';
    final isEncerrada = match.status == 'Encerrada';

    final corStatus = isAoVivo
        ? Colors.red
        : isEncerrada
            ? Colors.grey
            : AppColors.primary;

    final podeTocar = isAgendada || apostaFeita != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: podeTocar ? onTap : null,
        child: AppCard(
          radius: 16,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: corStatus, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        match.status.toUpperCase(),
                        style: TextStyle(
                            color: corStatus,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(match.dataRealizacao,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _TeamColumn(
                      nome: match.timeMandante.nomePopular,
                      escudo: match.timeMandante.escudo,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isAoVivo
                          ? Colors.red.withValues(alpha: 0.1)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (isAoVivo || isEncerrada)
                          ? '${match.placarMandante} - ${match.placarVisitante}'
                          : 'VS',
                      style: TextStyle(
                        color: isAoVivo ? Colors.red : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: (isAoVivo || isEncerrada) ? 20 : 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _TeamColumn(
                      nome: match.timeVisitante.nomePopular,
                      escudo: match.timeVisitante.escudo,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 3. FIX: Indicador claro de aposta
              _buildIndicadorAposta(isAgendada, isAoVivo, isEncerrada),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicadorAposta(
      bool isAgendada, bool isAoVivo, bool isEncerrada) {
    // Usuário JÁ APOSTOU
    if (apostaFeita != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'Seu palpite: ${_traduzirAposta(apostaFeita!)}',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    // Usuário NÃO APOSTOU
    if (isAgendada) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app, size: 16, color: AppColors.textSecondary),
            SizedBox(width: 6),
            Text('Toque para apostar',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    // Jogo em andamento/encerrado e sem aposta
    return Text(
      isAoVivo ? 'Partida em andamento' : 'Partida encerrada',
      style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontStyle: FontStyle.italic),
    );
  }

  String _traduzirAposta(String v) {
    switch (v) {
      case 'casa':
        return 'Mandante';
      case 'empate':
        return 'Empate';
      case 'fora':
        return 'Visitante';
      default:
        return v;
    }
  }
}

class _TeamColumn extends StatelessWidget {
  final String nome;
  final String escudo;

  const _TeamColumn({required this.nome, required this.escudo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TeamShield(escudo: escudo, name: nome, size: 50), // ← name: nome
        const SizedBox(height: 8),
        Text(
          nome, /* ... */
        ),
      ],
    );
  }
}
