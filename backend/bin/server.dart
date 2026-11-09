import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:backend/src/config/env.dart';
import 'package:backend/src/middlewares/auth_middleware.dart';
import 'package:backend/src/middlewares/error_middleware.dart';
import 'package:backend/src/middlewares/rate_limit_middleware.dart';
import 'package:backend/src/routes/app_router.dart';

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type, X-User-Id',
};

Middleware _corsMiddleware() {
  return (innerHandler) {
    return (request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }
      final response = await innerHandler(request);
      return response.change(headers: _corsHeaders);
    };
  };
}

void main() async {
  Env.load();

  final router = appRouter();

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware())
      .addMiddleware(errorMiddleware())
      .addMiddleware(RateLimitMiddleware(maxRequests: 60).call())
      .addMiddleware(authMiddleware())
      .addHandler(router.call);

  final server = await io.serve(handler, '0.0.0.0', 8080);
  print(
    '✅ Servidor BetBola rodando em http://${server.address.host}:${server.port}',
  );
}
