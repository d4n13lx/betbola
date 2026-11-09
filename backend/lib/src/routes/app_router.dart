import 'package:shelf_router/shelf_router.dart';

import '../controllers/match_controller.dart';
import '../controllers/bet_controller.dart';
import '../controllers/desafio_controller.dart';
import '../controllers/usuario_controller.dart';

Router appRouter() {
  final router = Router();

  // Rotas de Partidas
  router.get('/api/matches', MatchController.getAll);
  router.get('/api/matches/<id>', MatchController.getById);

  // Rotas de Apostas
  router.get('/api/bets', BetController.getAll);
  router.post('/api/bets', BetController.create);
  router.patch('/api/bets/<id>', BetController.update);
  router.delete('/api/bets/<id>', BetController.delete);

  // Rotas de Resultados
  router.post('/api/bets/check-results', BetController.checkResults);

  // Rotas de Desafios
  router.get('/api/desafios/aleatorio', DesafioController.getRandom);
  router.post('/api/desafios/responder', DesafioController.responder);

  // Rotas de usuarios
  router.get('/api/usuarios/status', UsuarioController.getStatus);
  return router;
}
