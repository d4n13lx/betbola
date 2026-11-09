import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Serviço centralizado para chamadas HTTP.
///
/// Fornece timeout, tratamento de erros padronizado e headers padrão.
/// Configuração via compile-time: `--dart-define=API_BASE_URL=http://10.0.2.2:8080`.
class ApiService {
  ApiService._();

  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const Duration _timeout = Duration(seconds: 10);

  /// Realiza uma requisição GET autenticada.
  ///
  /// Lança [ApiException] em caso de timeout, falta de rede ou resposta inválida.
  static Future<dynamic> get(String path, {required String userId}) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response =
          await http.get(uri, headers: {'X-User-Id': userId}).timeout(_timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Tempo de conexão esgotado. Tente novamente.');
    } on SocketException {
      throw ApiException('Sem conexão com a internet.');
    } on HttpException {
      throw ApiException('Erro na comunicação com o servidor.');
    }
  }

  /// Realiza uma requisição POST autenticada.
  static Future<dynamic> post(
    String path, {
    required String userId,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'X-User-Id': userId,
            },
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Tempo de conexão esgotado. Tente novamente.');
    } on SocketException {
      throw ApiException('Sem conexão com a internet.');
    } on HttpException {
      throw ApiException('Erro na comunicação com o servidor.');
    }
  }

  /// Realiza uma requisição DELETE autenticada.
  static Future<dynamic> delete(String path, {required String userId}) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await http
          .delete(uri, headers: {'X-User-Id': userId}).timeout(_timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Tempo de conexão esgotado.');
    } on SocketException {
      throw ApiException('Sem conexão com a internet.');
    } on HttpException {
      throw ApiException('Erro na comunicação com o servidor.');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
    } on FormatException {
      throw ApiException(
        'Resposta inválida do servidor (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body is Map
        ? (body['error'] ?? 'Erro desconhecido')
        : 'Erro HTTP ${response.statusCode}';
    throw ApiException(message.toString(), statusCode: response.statusCode);
  }
}

/// Exceção personalizada para erros de API.
class ApiException implements Exception {
  /// Mensagem amigável para exibir ao usuário.
  final String message;

  /// Código HTTP, se disponível.
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
