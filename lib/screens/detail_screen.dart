import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/api_service.dart';
import '../core/services/user_service.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/team_shield.dart';
import '../models/partida.dart';
import '../models/soccer_matches.dart';
import '../models/user_provider.dart';

class DetailScreen extends StatefulWidget {
  final Partida match;
  final String? currentBet;

  const DetailScreen({super.key, required this.match, this.currentBet});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late String _selectedBet;
  bool _isSubmitting = false;

  static const List<String> _betOptions = ['Mandante', 'Empate', 'Visitante'];

  @override
  void initState() {
    super.initState();
    _selectedBet = widget.currentBet ?? 'Mandante';
  }

  @override
  Widget build(BuildContext context) {
    final matchesProvider = context.watch<SoccerMatches>();
    final user = context.watch<UserProvider>();
    final apostaSalva = matchesProvider.userBets[widget.match.id];
    final jaApostou = apostaSalva != null;

    final isAgendada = widget.match.status == 'Agendada';
    final isAoVivo = widget.match.status == 'Em andamento';
    final isEncerrada = widget.match.status == 'Encerrada';

    if (jaApostou) {
      final novo = apostaSalva == 'casa'
          ? 'Mandante'
          : apostaSalva == 'empate'
              ? 'Empate'
              : 'Visitante';
      if (novo != _selectedBet) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedBet = novo);
        });
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text('Detalhes da Partida',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBanner(isAgendada, isAoVivo, isEncerrada),
                  const SizedBox(height: 16),
                  _buildMatchCard(isAoVivo || isEncerrada),
                  const SizedBox(height: 16),
                  if (isAgendada && !jaApostou) _buildRegrasCard(user.pontos),
                  const SizedBox(height: 16),
                  Text(
                    jaApostou ? 'PALPITE REGISTRADO' : 'SEU JOGO, SUA ESCOLHA',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    jaApostou
                        ? 'Sua aposta nesta partida:'
                        : 'Escolha seu palpite:',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildBetSelector(jaApostou || !isAgendada),
                ],
              ),
            ),
          ),
          if (!jaApostou && isAgendada)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildSaveButton(matchesProvider, user),
              ),
            )
          else if (!jaApostou)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.danger),
                  ),
                  child: Text(
                    isAoVivo
                        ? '⏱️ Partida em andamento — não é possível apostar'
                        : '🔒 Partida encerrada — não é possível apostar',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.danger, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(bool isAgendada, bool isAoVivo, bool isEncerrada) {
    final color = isAoVivo
        ? Colors.red
        : isEncerrada
            ? Colors.grey
            : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(
            isAoVivo
                ? Icons.play_circle_filled
                : isEncerrada
                    ? Icons.lock
                    : Icons.schedule,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(widget.match.status,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRegrasCard(int pontos) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('REGRAS DA APOSTA',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 12),
          _buildRegra('Custo da aposta:', '-5 pontos'),
          const SizedBox(height: 6),
          _buildRegra('Acertar o vencedor:', '+3 pontos'),
          const SizedBox(height: 6),
          _buildRegra('Acertar empate:', '+5 pontos'),
          const Divider(color: AppColors.border, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Seu saldo:', style: TextStyle(fontSize: 14)),
              Text('$pontos pontos',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          pontos >= 5 ? AppColors.primary : AppColors.danger)),
            ],
          ),
          if (pontos < 5) ...[
            const SizedBox(height: 8),
            Text('⚠️ Você não tem pontos suficientes. Participe de desafios.',
                style: TextStyle(color: AppColors.danger, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildRegra(String label, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(valor,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildMatchCard(bool isFinalizado) {
    return AppCard(
      radius: 20,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(widget.match.dataRealizacao,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _TeamInfo(
                    name: widget.match.timeMandante.nomePopular,
                    escudo: widget.match.timeMandante.escudo,
                    type: 'Mandante',
                  ),
                ),
                Column(
                  children: [
                    Text(
                      isFinalizado
                          ? '${widget.match.placarMandante} - ${widget.match.placarVisitante}'
                          : 'VS',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: isFinalizado ? 32 : 24,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: _TeamInfo(
                    name: widget.match.timeVisitante.nomePopular,
                    escudo: widget.match.timeVisitante.escudo,
                    type: 'Visitante',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildBetSelector(bool isLocked) {
    return Row(
      children: _betOptions.map((option) {
        final isSelected = _selectedBet == option;
        final isFaded = isLocked && !isSelected;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (!isLocked && !_isSubmitting) {
                setState(() => _selectedBet = option);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : (isFaded ? Colors.transparent : AppColors.surfaceLight),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isFaded ? Colors.transparent : AppColors.surfaceLight),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    const Icon(Icons.check_circle,
                        color: AppColors.primary, size: 20),
                    const SizedBox(height: 8),
                  ],
                  Text(option,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : (isFaded
                                ? AppColors.textSecondary.withValues(alpha: 0.3)
                                : AppColors.textSecondary),
                      )),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton(SoccerMatches provider, UserProvider user) {
    final podeApostar = user.pontos >= 5;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              podeApostar ? AppColors.primary : AppColors.surfaceLight,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed:
            (_isSubmitting || !podeApostar) ? null : () => _submitBet(provider),
        child: _isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: Colors.black, strokeWidth: 3),
              )
            : Text(
                podeApostar
                    ? 'Apostar no $_selectedBet (-5 pts)'
                    : 'Sem pontos suficientes',
                style: TextStyle(
                    color: podeApostar ? Colors.black : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
      ),
    );
  }

  Future<void> _submitBet(SoccerMatches provider) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    String previsaoFormatada = 'casa';
    if (_selectedBet == 'Empate') previsaoFormatada = 'empate';
    if (_selectedBet == 'Visitante') previsaoFormatada = 'fora';

    try {
      final userId = await UserService.getUserId();
      await ApiService.post(
        '/api/bets',
        userId: userId,
        body: {
          'partida_id': widget.match.id,
          'previsao': previsaoFormatada,
        },
      );
      provider.addBet(widget.match.id, previsaoFormatada);
      if (mounted) {
        context.read<UserProvider>().fetchUserStatus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Palpite salvo! -5 pontos.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.message}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
        TeamShield(escudo: escudo, name: name, size: 75), // ← name: name,
        const SizedBox(height: 12),
        Text(name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(type,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
