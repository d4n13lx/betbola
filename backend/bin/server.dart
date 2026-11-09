import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:backend/src/routes/app_router.dart';
import 'package:backend/src/middlewares/error_middleware.dart';
import 'package:backend/src/middlewares/auth_middleware.dart';
import 'package:backend/src/config/env.dart';
import 'package:backend/src/middlewares/rate_limit_middleware.dart';

void main() async {
  Env.load();

  final router = appRouter();

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(errorMiddleware())
      .addMiddleware(RateLimitMiddleware(maxRequests: 30).call())
      .addMiddleware(authMiddleware())
      .addHandler(router.call);

  final server = await io.serve(handler, '0.0.0.0', 8080);
  print(
    '✅ Servidor BetBola rodando em http://${server.address.host}:${server.port}',
  );
}
