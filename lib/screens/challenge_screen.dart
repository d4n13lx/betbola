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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(
                    // ✅ era .withOpacity(0.4) — linha 41
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
                        style:
                            TextStyle(color: AppColors.danger, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('DESAFIO ANTI-VÍCIO', style: AppStyles.tagStyle),
              const Text('Pense antes de apostar',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildQuestion(
                'PERGUNTA 1',
                'Qual a % de apostadores que perdem a longo prazo?',
              ),
              const SizedBox(height: 16),
              _buildQuestion(
                'PERGUNTA 2',
                'Quantas substituições existem no futebol?',
              ),
              const SizedBox(height: 32),
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
                        const SnackBar(content: Text('Respostas validadas!')),
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

  Widget _buildQuestion(String tag, String question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            // ✅ era .withOpacity(0.1) — linha 117
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(tag, style: AppStyles.tagStyle),
        ),
        const SizedBox(height: 8),
        Text(question, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
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
          ),
        ),
      ],
    );
  }
}
