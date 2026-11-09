import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';
import '../../core/services/user_service.dart';
import '../../models/desafio.dart';
import 'package:provider/provider.dart';
import '../../models/user_provider.dart';

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
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080';
      final response = await http.get(
        Uri.parse('$baseUrl/api/desafios/aleatorio'),
        headers: {'X-User-Id': userId},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _desafio = Desafio.fromMap(data);
        });
      } else {
        setState(() => _erro = 'Erro ao carregar desafio.');
      }
    } catch (e) {
      setState(() => _erro = 'Falha de conexão: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _responder() async {
    if (!_formKey.currentState!.validate() || _desafio == null) return;
    setState(() => _isSubmitting = true);

    final userId = await UserService.getUserId();
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/desafios/responder'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-Id': userId,
        },
        body: jsonEncode({
          'desafio_id': _desafio!.id,
          'resposta': _respostaController.text.trim(),
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _acertou = data['acertou'];
          _mensagemResultado = data['mensagem'];
        });
        // Limpa o campo e opcionalmente carrega novo desafio
        _respostaController.clear();

        if (mounted) {
          context.read<UserProvider>().fetchUserStatus();
        }
      } else {
        setState(() => _erro = data['error'] ?? 'Erro ao responder.');
      }
    } catch (e) {
      setState(() => _erro = 'Falha de conexão: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          // Chip de pontos
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
                      '${context.watch<UserProvider>().pontos} pts',
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
          // Botão de recarregar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDesafio,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(child: Text(_erro!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pergunta
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
                        // Campo de resposta
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
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Campo obrigatório'
                                  : null,
                        ),
                        const SizedBox(height: 24),
                        // Botão
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
                        // Feedback
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
