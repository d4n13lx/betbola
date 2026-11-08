import 'dart:convert';

import 'package:shelf/shelf.dart';

Middleware errorMiddleware() {
  return (innerHandler) {
    return (request) async {
      try {
        return await innerHandler(request);
      } catch (e, stackTrace) {
        print('❌ ERRO INTERNO: $e\n$stackTrace');
        return Response.internalServerError(
          body: jsonEncode({
            'error': 'Erro interno no servidor',
            'details': e.toString(),
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    };
  };
}
