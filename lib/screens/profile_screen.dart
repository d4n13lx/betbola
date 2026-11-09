import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. Adicionado o import do dotenv
import '../core/services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<dynamic> userBets = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _checkResults();
  }

  Future<void> _checkResults() async {
    try {
      final userId = await UserService.getUserId();
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080';

      final response = await http.post(
        Uri.parse('$baseUrl/api/bets/check-results'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-Id': userId,
        },
      );

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);

        setState(() {
          if (decodedBody is List) {
            userBets = decodedBody;
          }
          else if (decodedBody is Map<String, dynamic>) {
            if (decodedBody.containsKey('data')) {
              userBets = decodedBody['data'] as List;
            } else if (decodedBody.containsKey('bets')) {
              userBets = decodedBody['bets'] as List;
            } else if (decodedBody.containsKey('resultados')) {
              userBets = decodedBody['resultados'] as List;
            } else if (decodedBody.containsKey('message')) {
              // Captura a mensagem do backend e limpa a lista
              userBets = [];
              // Define a mensagem para aparecer na tela de forma amigável
              errorMessage = decodedBody['message'];
            } else {
              errorMessage = 'Formato de resposta inesperado: $decodedBody';
            }
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Erro ao carregar resultados: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro de conexão: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil e Apostas')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : userBets.isEmpty
                  ? const Center(
                      child: Text('Você ainda não tem apostas registradas.'))
                  : ListView.builder(
                      itemCount: userBets.length,
                      itemBuilder: (context, index) {
                        final bet = userBets[index];
                        return ListTile(
                          title: Text('Partida: ${bet['partida_id']}'),
                          subtitle: Text('Palpite: ${bet['previsao']}'),
                          trailing: _buildStatusBadge(bet['status']),
                        );
                      },
                    ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color;
    String text;

    switch (status) {
      case 'ganhou':
        color = Colors.green;
        text = 'Ganhou';
        break;
      case 'perdeu':
        color = Colors.red;
        text = 'Perdeu';
        break;
      default:
        color = Colors.grey;
        text = 'Pendente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
