import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';

/// Tela de Desafio Anti-Vício — Pedro
class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _q1Controller = TextEditingController();
  final _q2Controller = TextEditingController();

  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    // Atualiza a barra de progresso conforme o usuário digita
    _q1Controller.addListener(_updateProgress);
    _q2Controller.addListener(_updateProgress);
  }

  @override
  void dispose() {
    _q1Controller.dispose();
    _q2Controller.dispose();
    super.dispose();
  }

  void _updateProgress() {
    int filled = 0;
    if (_q1Controller.text.trim().isNotEmpty) filled++;
    if (_q2Controller.text.trim().isNotEmpty) filled++;
    setState(() {
      _progress = filled / 2.0; // 2 é o número total de perguntas
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Desbloqueio de Palpite', style: TextStyle(fontSize: 18)),
            Text('Jogue com consciência', style: AppStyles.appBarSubtitle),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Relógio / Tempo Restante
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.surface,
                ),
                child: Column(
                  children: const [
                    Icon(Icons.timer, color: AppColors.danger, size: 40),
                    SizedBox(height: 8),
                    Text('TEMPO RESTANTE',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            letterSpacing: 1.2)),
                    Text('00:15',
                        style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text('Responda antes que o tempo acabe',
                        style: TextStyle(color: AppColors.danger, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Selo de Recompensa
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppStyles.highlightDecoration(
                  borderColor: AppColors.primary.withValues(alpha: 0.5),
                  color: AppColors.primary.withValues(alpha: 0.05),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: AppColors.primary, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Recompensa do Desafio',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Acerte as questões para liberar seu palpite na rodada!',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Barra de Progresso Interativa
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('SEU PROGRESSO', style: AppStyles.tagStyle),
                  Text('${(_progress * 100).toInt()}%',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: AppColors.borderLight,
                color: AppColors.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 24),

              const Text('DESAFIO ANTI-VÍCIO', style: AppStyles.tagStyle),
              const Text('Pense antes de apostar',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // 4. Perguntas
              _buildQuestion(
                'PERGUNTA 1',
                'Qual a % de apostadores que perdem a longo prazo?',
                _q1Controller,
              ),
              const SizedBox(height: 16),
              _buildQuestion(
                'PERGUNTA 2',
                'Quantas substituições existem no futebol?',
                _q2Controller,
              ),
              const SizedBox(height: 32),

              // 5. Botão de Validação Original
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Respostas validadas! Palpite liberado.')),
                      );
                    }
                  },
                  child: const Text('Validar e Liberar Palpite',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion(
      String tag, String question, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(tag, style: AppStyles.tagStyle),
        ),
        const SizedBox(height: 8),
        Text(question, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Campo obrigatório ou tempo esgotado';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Digite sua resposta',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}