import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:supabase/supabase.dart';

import '../config/env.dart';
import '../services/football_api_service.dart';

class BetController {
  static SupabaseClient get _supabase =>
      SupabaseClient(Env.supabaseUrl, Env.supabaseKey);

  // --- READ (Listar) ---
  static Future<Response> getAll(Request request) async {
    final userId = request.context['userId'] as String;
    try {
      final response = await _supabase
          .from('previsoes')
          .select()
          .eq('user_id', userId)
          .order('criada_em', ascending: false);

      return Response.ok(
        jsonEncode(response),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  // --- CREATE (Criar) ---
  static Future<Response> create(Request request) async {
    final userId = request.context['userId'] as String;
    final body = jsonDecode(await request.readAsString());

    try {
      // 1. Buscar usuário e verificar pontos/bloqueio
      var user = await _supabase
          .from('usuarios')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (user == null) {
        await _supabase.from('usuarios').insert({
          'user_id': userId,
          'pontos': 100,
          'erros_consecutivos': 0,
        });
        user = await _supabase
            .from('usuarios')
            .select()
            .eq('user_id', userId)
            .single();
      }

      final pontos = user['pontos'] as int;
      final bloqueadoAte = user['bloqueado_ate'] as String?;

      if (bloqueadoAte != null &&
          DateTime.parse(bloqueadoAte).isAfter(DateTime.now())) {
        return Response.forbidden(
          jsonEncode({
            'error': 'Você está bloqueado. Aguarde para apostar novamente.',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      if (pontos < 5) {
        return Response.badRequest(
          body: jsonEncode({
            'error':
                'Pontos insuficientes. Participe de desafios para ganhar mais.',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      // 2. Verifica se a partida já começou
      final match = await FootballApiService.getMatchById(
        body['partida_id'] as int,
      );
      if (match['status'] != 'Agendada') {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'Não é possível apostar em partidas já iniciadas ou encerradas.',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      // 3. Debita 5 pontos do usuário
      await _supabase
          .from('usuarios')
          .update({'pontos': pontos - 5})
          .eq('user_id', userId);

      // 4. Insere a previsão
      final response = await _supabase
          .from('previsoes')
          .insert({
            'user_id': userId,
            'partida_id': body['partida_id'],
            'time_casa': match['time_mandante']['nome_popular'],
            'time_fora': match['time_visitante']['nome_popular'],
            'escudo_casa': match['time_mandante']['escudo'],
            'escudo_fora': match['time_visitante']['escudo'],
            'rodada': match['campeonato']['rodada'] ?? 0,
            'previsao': body['previsao'],
            'status': 'pendente',
            'pontos': 0,
          })
          .select()
          .single();

      return Response.ok(
        jsonEncode(response),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      // Captura erro de chave única (previsão duplicada)
      if (e.toString().contains('23505')) {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'Você já fez uma previsão para esta partida.',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  // --- UPDATE (Editar) ---
  static Future<Response> update(Request request, String id) async {
    final userId = request.context['userId'] as String;
    final body = jsonDecode(await request.readAsString());

    try {
      final response = await _supabase
          .from('previsoes')
          .update({
            'previsao': body['previsao'],
            'atualizada_em': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', userId)
          .select()
          .single();

      return Response.ok(
        jsonEncode(response),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  // --- DELETE (Excluir) ---
  static Future<Response> delete(Request request, String id) async {
    final userId = request.context['userId'] as String;

    try {
      await _supabase
          .from('previsoes')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);

      return Response.ok(
        jsonEncode({'message': 'Previsão excluída com sucesso.'}),
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  // --- CHECK RESULTS (Conferir e Calcular Pontuação) ---
  static Future<Response> checkResults(Request request) async {
    final userId = request.context['userId'] as String;

    try {
      final bets = await _supabase
          .from('previsoes')
          .select()
          .eq('user_id', userId)
          .eq('status', 'pendente');

      if (bets.isEmpty) {
        return Response.ok(
          jsonEncode({'message': 'Nenhuma previsão pendente para conferir.'}),
        );
      }

      int conferidas = 0;
      int pontosGanhosTotal = 0;

      for (var bet in bets) {
        final match = await FootballApiService.getMatchById(
          bet['partida_id'] as int,
        );

        if (match['status'] == 'Encerrada') {
          int pontos = 0;
          final previsao = bet['previsao'] as String;
          final placarCasa = (match['placar_mandante'] as int?) ?? 0;
          final placarFora = (match['placar_visitante'] as int?) ?? 0;

          if (placarCasa == placarFora && previsao == 'empate') {
            pontos = 5;
          } else if (placarCasa > placarFora && previsao == 'casa') {
            pontos = 3;
          } else if (placarCasa < placarFora && previsao == 'fora') {
            pontos = 3;
          }

          final statusFinal = pontos > 0 ? 'acertou' : 'errou';

          await _supabase
              .from('previsoes')
              .update({
                'status': statusFinal,
                'pontos': pontos,
                'placar_real': '$placarCasa x $placarFora',
                'atualizada_em': DateTime.now().toIso8601String(),
              })
              .eq('id', bet['id']);

          if (pontos > 0) {
            pontosGanhosTotal += pontos;
          }
          conferidas++;
        }
      }

      // Credita pontos ganhos ao usuário
      if (pontosGanhosTotal > 0) {
        final user = await _supabase
            .from('usuarios')
            .select()
            .eq('user_id', userId)
            .single();
        final pontosAtuais = user['pontos'] as int;
        await _supabase
            .from('usuarios')
            .update({'pontos': pontosAtuais + pontosGanhosTotal})
            .eq('user_id', userId);
      }

      return Response.ok(
        jsonEncode({
          'message': 'Conferência concluída!',
          'processadas': conferidas,
          'pontos_ganhos': pontosGanhosTotal,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      print('❌ ERRO NO CHECK RESULTS: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }
}
