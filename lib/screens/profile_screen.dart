import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/services/user_service.dart';

/// Tela de Perfil — Vinicius
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Meu Perfil', style: TextStyle(fontSize: 18)),
            Text('Seu desempenho', style: AppStyles.appBarSubtitle),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(20),
                color: AppColors.surface,
              ),
              child: Column(
                children: const [
                  Icon(Icons.bar_chart, color: AppColors.primary, size: 32),
                  SizedBox(height: 8),
                  Text('Pontuação Total',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  Text('1.280',
                      style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text('+120 pontos nesta rodada',
                      style: TextStyle(color: AppColors.primary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                      'Acertos', '18', '72% dos palpites', AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                      'Erros', '7', '28% dos palpites', AppColors.danger),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
                onPressed: _isLoading ? null : _conferirResultados,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Conferir Resultados',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _conferirResultados() async {
    setState(() => _isLoading = true);
    final userId = await UserService.getUserId();

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/bets/check-results'),
        headers: {'X-User-Id': userId},
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Resultados conferidos! Vá para a tela de histórico.')),
          );
        }
      } else {
        // ADICIONE ESTE PRINT AQUI
        print('ERRO DO SERVIDOR: ${response.statusCode} - ${response.body}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao conferir resultados.')),
          );
        }
      }
    } catch (e) {
      print('ERRO DE CONEXÃO FLUTTER: $e');
      // ...
    }
  }

  Widget _buildStatCard(String label, String value, String sub, Color color) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          Text(value,
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          Text(sub,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}
