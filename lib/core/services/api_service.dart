import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Serviço centralizado para chamadas HTTP.
/// Fornece timeout, tratamento de erros e headers padrão.
class ApiService {
  ApiService._();

  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080';

  /// Realiza uma requisição GET autenticada.
  /// Retorna o corpo decodificado ou lança uma [ApiException].
  static Future<dynamic> get(String path, {required String userId}) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final response = await http.get(uri,
          headers: {'X-User-Id': userId}).timeout(const Duration(seconds: 10));
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
          .timeout(const Duration(seconds: 10));
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
      final response = await http.delete(uri,
          headers: {'X-User-Id': userId}).timeout(const Duration(seconds: 10));
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
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      final message = body['error'] ?? 'Erro desconhecido';
      throw ApiException(message, statusCode: response.statusCode);
    }
  }
}

/// Exceção personalizada para erros de API.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
