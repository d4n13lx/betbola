import 'package:shelf_router/shelf_router.dart';

import '../controllers/match_controller.dart';
import '../controllers/bet_controller.dart';

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

  // ESTA É A ROTA QUE ESTÁ FALTANDO OU COM NOME ERRADO:
  router.post('/api/bets/check-results', BetController.checkResults);

  return router;
}
