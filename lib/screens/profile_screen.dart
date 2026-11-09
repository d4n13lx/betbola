import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/api_service.dart';
import '../core/services/user_service.dart';
import '../core/theme/app_colors.dart';
import '../models/user_provider.dart';
import 'results_screen.dart';

/// Tela de perfil com estatísticas e pontos.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  int _acertos = 0, _erros = 0, _pendentes = 0;
  String? _erro;
  bool _conferindo = false;

  @override
  void initState() {
    super.initState();
    _fetchBets();
  }

  Future<void> _fetchBets() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });
    try {
      final userId = await UserService.getUserId();
      final data = await ApiService.get('/api/bets', userId: userId);
      final list = data as List;
      int acertos = 0, erros = 0, pendentes = 0;
      for (var bet in list) {
        if (bet['status'] == 'acertou') {
          acertos++;
        } else if (bet['status'] == 'errou') {
          erros++;
        } else {
          pendentes++;
        }
      }
      setState(() {
        _acertos = acertos;
        _erros = erros;
        _pendentes = pendentes;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _erro = e.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _conferirResultados() async {
    setState(() => _conferindo = true);
    try {
      final userId = await UserService.getUserId();
      final data =
          await ApiService.post('/api/bets/check-results', userId: userId);
      final ganhos = data['pontos_ganhos'] ?? 0;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conferência concluída! +$ganhos pontos.')),
        );
        context.read<UserProvider>().fetchUserStatus();
        await _fetchBets();
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ResultsScreen()),
          );
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.message}')),
        );
      }
    } finally {
      if (mounted) setState(() => _conferindo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Meu Perfil'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    Text('${user.pontos} pts',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(child: Text('Erro: $_erro'))
              : RefreshIndicator(
                  onRefresh: () async {
                    await context.read<UserProvider>().fetchUserStatus();
                    await _fetchBets();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.2),
                                AppColors.surface,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.account_balance_wallet,
                                  color: AppColors.primary, size: 40),
                              const SizedBox(height: 8),
                              const Text('PONTOS DISPONÍVEIS',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    letterSpacing: 1.2,
                                  )),
                              Text('${user.pontos}',
                                  style: const TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  )),
                              if (user.estaBloqueado)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.danger.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                      '⚠️ Bloqueado temporariamente',
                                      style:
                                          TextStyle(color: AppColors.danger)),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                                child: _buildStatCard(
                                    'Acertos', '$_acertos', AppColors.primary)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _buildStatCard(
                                    'Erros', '$_erros', AppColors.danger)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _buildStatCard(
                                    'Pendentes', '$_pendentes', Colors.amber)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: _conferindo ? null : _conferirResultados,
                            icon: _conferindo
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.refresh,
                                    color: Colors.white),
                            label: Text(
                              _conferindo
                                  ? 'Conferindo...'
                                  : 'Conferir Resultados',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ResultsScreen()),
                            ),
                            icon: const Icon(Icons.history,
                                color: AppColors.primary),
                            label: const Text('Ver Histórico Completo',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
