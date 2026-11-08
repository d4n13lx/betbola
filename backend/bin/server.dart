import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:backend/src/routes/app_router.dart';
import 'package:backend/src/middlewares/error_middleware.dart';
import 'package:backend/src/middlewares/auth_middleware.dart';

void main() async {
  // Cria o roteador
  final router = appRouter();

  // Configura os middlewares (CORS, tratamento de erro e autenticação)
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(errorMiddleware())
      .addMiddleware(authMiddleware())
      .addHandler(router.call);

  // Inicia o servidor na porta 8080
  final server = await io.serve(handler, '0.0.0.0', 8080);
  print(
    '✅ Servidor BetBola rodando em http://${server.address.host}:${server.port}',
  );
}
