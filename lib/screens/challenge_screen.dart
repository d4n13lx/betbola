import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/api_service.dart';
import '../core/services/user_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_styles.dart';
import '../models/desafio.dart';
import '../models/user_provider.dart';

/// Tela de desafios anti-vício.
class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _respostaController = TextEditingController();

  Desafio? _desafio;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _erro;
  String? _mensagemResultado;
  bool? _acertou;

  @override
  void initState() {
    super.initState();
    _carregarDesafio();
  }

  @override
  void dispose() {
    _respostaController.dispose();
    super.dispose();
  }

  Future<void> _carregarDesafio() async {
    setState(() {
      _isLoading = true;
      _erro = null;
      _mensagemResultado = null;
      _acertou = null;
    });
    try {
      final userId = await UserService.getUserId();
      final data =
          await ApiService.get('/api/desafios/aleatorio', userId: userId);
      setState(() => _desafio = Desafio.fromMap(data));
    } on ApiException catch (e) {
      setState(() => _erro = e.message);
    } catch (_) {
      setState(() => _erro = 'Erro ao carregar desafio.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _responder() async {
    if (_isSubmitting) return; // Guard contra double-tap
    if (!_formKey.currentState!.validate() || _desafio == null) return;

    setState(() => _isSubmitting = true);

    try {
      final userId = await UserService.getUserId();
      final data = await ApiService.post(
        '/api/desafios/responder',
        userId: userId,
        body: {
          'desafio_id': _desafio!.id,
          'resposta': _respostaController.text.trim(),
        },
      );
      setState(() {
        _acertou = data['acertou'];
        _mensagemResultado = data['mensagem'];
      });
      _respostaController.clear();
      if (mounted) context.read<UserProvider>().fetchUserStatus();
    } on ApiException catch (e) {
      setState(() => _erro = e.message);
    } catch (_) {
      setState(() => _erro = 'Falha de conexão.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pontos = context.select<UserProvider, int>((p) => p.pontos);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Desafio Anti-Vício', style: TextStyle(fontSize: 18)),
            Text('Pense antes de apostar', style: AppStyles.appBarSubtitle),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                    Text(
                      '$pontos pts',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _carregarDesafio),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_erro!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _carregarDesafio,
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
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
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.quiz,
                                  color: AppColors.primary, size: 40),
                              const SizedBox(height: 16),
                              Text(
                                _desafio!.pergunta,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _respostaController,
                          decoration: InputDecoration(
                            hintText: 'Digite sua resposta',
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Campo obrigatório'
                              : null,
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
                            onPressed: _isSubmitting ? null : _responder,
                            child: _isSubmitting
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text('Responder',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                        if (_mensagemResultado != null) ...[
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _acertou == true
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : AppColors.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: _acertou == true
                                      ? AppColors.primary
                                      : AppColors.danger),
                            ),
                            child: Text(
                              _mensagemResultado!,
                              style: TextStyle(
                                color: _acertou == true
                                    ? AppColors.primary
                                    : AppColors.danger,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}
