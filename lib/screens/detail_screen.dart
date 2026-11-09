import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/partida.dart';
import '../models/soccer_matches.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/team_shield.dart';
import '../core/services/user_service.dart';

class DetailScreen extends StatefulWidget {
  final Partida match;
  final String? currentBet; // 1. NOVA VARIÁVEL AQUI

  const DetailScreen({super.key, required this.match, this.currentBet});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? selectedBet;
  bool _isSubmitting = false; // Controle de loading no botão

  static const List<String> _betOptions = ['Mandante', 'Empate', 'Visitante'];

  @override
  void initState() {
    super.initState();
    // 3. Se currentBet tiver valor, usa ele. Se for nulo, o padrão é 'Mandante'.
    selectedBet = widget.currentBet ?? 'Mandante';
  }

  @override
  Widget build(BuildContext context) {
    final matchesProvider = context.watch<SoccerMatches>();

    // Verifica se já existe aposta para essa partida
    final apostaSalva = matchesProvider.userBets[widget.match.id];
    final jaApostou = apostaSalva != null;

    // Trava o estado se já existir aposta
    if (jaApostou) {
      if (apostaSalva == 'casa') selectedBet = 'Mandante';
      if (apostaSalva == 'empate') selectedBet = 'Empate';
      if (apostaSalva == 'fora') selectedBet = 'Visitante';
    } else if (selectedBet == null) {
      selectedBet = 'Mandante'; // Valor inicial
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Detalhes da Partida',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Área com Scroll para evitar overflow em telas pequenas
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMatchCard(),
                  const SizedBox(height: 32),

                  // Cabeçalho de instrução
                  Text(
                    jaApostou ? 'PALPITE REGISTRADO' : 'SEU JOGO, SUA ESCOLHA',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    jaApostou ? 'Sua aposta nesta partida:' : 'Escolha seu palpite:',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Botões de escolha
                  _buildBetSelector(jaApostou),
                ],
              ),
            ),
          ),

          // Botão fixo no fundo da tela (só aparece se não tiver apostado)
          if (!jaApostou)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildSaveButton(matchesProvider),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMatchCard() {
    return AppCard(
      radius: 20,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.match.dataRealizacao,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
                const Column(
                  children: [
                    Text(
                      'VS',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
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
        final isSelected = selectedBet == option;
        final isFaded = isLocked && !isSelected; // Esmaece os que não foram escolhidos

        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (!isLocked && !_isSubmitting) {
                setState(() => selectedBet = option);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surface,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isFaded ? Colors.transparent : AppColors.surfaceLight ?? AppColors.border),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    option,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : (isFaded ? AppColors.textSecondary.withValues(alpha: 0.3) : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton(SoccerMatches provider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: _isSubmitting ? null : () => _submitBet(provider),
        child: _isSubmitting
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3)
            )
          : Text(
              'Apostar no $selectedBet',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
      ),
    );
  }

  Future<void> _submitBet(SoccerMatches provider) async {
    setState(() => _isSubmitting = true);

    String previsaoFormatada = 'casa';
    if (selectedBet == 'Empate') previsaoFormatada = 'empate';
    if (selectedBet == 'Visitante') previsaoFormatada = 'fora';

    try {
      final userId = await UserService.getUserId();
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080';

      final response = await http.post(
        Uri.parse('$baseUrl/api/bets'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-Id': userId,
        },
        body: jsonEncode({
          'partida_id': widget.match.id,
          'previsao': previsaoFormatada,
        }),
      );

      if (response.statusCode == 200) {
        // Atualiza a tela Home automaticamente
        provider.addBet(widget.match.id, previsaoFormatada);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Palpite salvo com sucesso! Boa sorte!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating, // Flutua na tela, fica mais moderno
            ),
          );
          Navigator.pop(context);
        }
      } else {
        final erro = jsonDecode(response.body)['error'] ?? 'Erro ao salvar aposta';
        throw Exception(erro);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _TeamInfo extends StatelessWidget {
  final String name;
  final String escudo;
  final String type;

  const _TeamInfo({
    required this.name,
    required this.escudo,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TeamShield(escudo: escudo, size: 75), // Escudo em tamanho equilibrado
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          type,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}