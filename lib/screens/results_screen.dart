import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';
import '../../models/bet_history.dart';

/// Tela de Estatísticas e Resultados — Pedro
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Estatísticas e Resultados',
            style: TextStyle(fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(16),
                color: AppColors.surface,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Aproveitamento',
                          style: TextStyle(color: AppColors.textSecondary)),
                      Text('72%',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.72,
                    // ✅ era .withOpacity(0.3)
                    backgroundColor: AppColors.danger.withValues(alpha: 0.3),
                    color: AppColors.primary,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('• 18 acertos',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      Text('• 7 erros',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('ÚLTIMAS RODADAS', style: AppStyles.tagStyle),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Histórico de apostas',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderLight),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${BetHistory.mockHistory.length} jogos',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: BetHistory.mockHistory.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: AppColors.border),
                itemBuilder: (context, index) {
                  final item = BetHistory.mockHistory[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        // ✅ era .withOpacity(0.1)
                        color: (item.success
                                ? AppColors.primary
                                : AppColors.danger)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.success ? Icons.check : Icons.close,
                        color:
                            item.success ? AppColors.primary : AppColors.danger,
                      ),
                    ),
                    title: Text(item.game,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('${item.bet} • Placar ${item.result}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    trailing: Text('${item.points} pts',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
