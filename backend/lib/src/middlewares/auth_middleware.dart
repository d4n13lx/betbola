import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

Middleware authMiddleware() {
  return (innerHandler) {
    return (request) async {
      // Ignora rotas públicas (ex: listagem de partidas)
      if (request.url.path.startsWith('api/matches')) {
        return innerHandler(request);
      }

      final userId = request.headers['x-user-id'];

      // Validação de UUID
      bool isValidUuid = false;
      if (userId != null && userId.isNotEmpty) {
        try {
          Uuid.parse(userId);
          isValidUuid = true;
        } catch (_) {
          isValidUuid = false;
        }
      }

      // Se a rota for check-results e o ID for válido, segue o baile.
      if (!isValidUuid) {
        return Response.forbidden(
          jsonEncode({'error': 'Header X-User-Id ausente ou inválido'}),
          headers: {'content-type': 'application/json'},
        );
      }

      // Adiciona o userId ao contexto para os controllers usarem
      final updatedRequest = request.change(context: {'userId': userId});
      return innerHandler(updatedRequest);
    };
  };
}
