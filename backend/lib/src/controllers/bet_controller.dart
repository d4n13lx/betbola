import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:supabase/supabase.dart';

import '../config/env.dart';
import '../services/football_api_service.dart';

class BetController {
  static SupabaseClient get _supabase =>
      SupabaseClient(Env.supabaseUrl, Env.supabaseKey);

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

  static Future<Response> create(Request request) async {
    final userId = request.context['userId'] as String;
    final body = jsonDecode(await request.readAsString());

    try {
      final partidaId = body['partida_id'];
      final previsao = body['previsao'] as String?;

      if (partidaId == null || previsao == null || previsao.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'partida_id e previsao são obrigatórios.',
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      // 1. Verificar bloqueio do usuário
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

      final bloqueadoAte = user['bloqueado_ate'] as String?;
      if (bloqueadoAte != null) {
        final parsed = DateTime.tryParse(bloqueadoAte);
        if (parsed != null && parsed.isAfter(DateTime.now())) {
          return Response.forbidden(
            jsonEncode({
              'error': 'Você está bloqueado. Aguarde para apostar novamente.',
            }),
            headers: {'content-type': 'application/json'},
          );
        }
      }

      // 2. Verificar status da partida
      final match = await FootballApiService.getMatchById(partidaId as int);
      final status = match['status'] as String?;

      if (status == 'Em andamento') {
        return Response.badRequest(
          body: jsonEncode({
            'error':
                'Partida em andamento. Aguarde o encerramento para conferir.',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      if (status == 'Encerrada') {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'Partida já encerrada. Não é possível apostar.',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      if (status != 'Agendada') {
        return Response.badRequest(
          body: jsonEncode({'error': 'Status desconhecido da partida.'}),
          headers: {'content-type': 'application/json'},
        );
      }

      // 3. Chamar a função SQL atômica (debita 5 pontos + insere previsão)
      final result = await _supabase.rpc(
        'criar_previsao_atomica',
        params: {
          'p_user_id': userId,
          'p_partida_id': partidaId,
          'p_time_casa': match['time_mandante']['nome_popular'],
          'p_time_fora': match['time_visitante']['nome_popular'],
          'p_escudo_casa': match['time_mandante']['escudo'],
          'p_escudo_fora': match['time_visitante']['escudo'],
          'p_rodada': match['campeonato']['rodada'] ?? 0,
          'p_previsao': previsao,
        },
      );

      return Response.ok(
        jsonEncode(result),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('PONTOS_INSUFICIENTES')) {
        return Response.badRequest(
          body: jsonEncode({
            'error':
                'Pontos insuficientes. Participe de desafios para ganhar mais.',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      if (msg.contains('23505') || msg.contains('duplicate')) {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'Você já fez uma previsão para esta partida.',
          }),
          headers: {'content-type': 'application/json'},
        );
      }
      return Response.internalServerError(body: jsonEncode({'error': msg}));
    }
  }

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
        try {
          final match = await FootballApiService.getMatchById(
            bet['partida_id'] as int,
          );

          if (match['status'] != 'Encerrada') continue;

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

          if (pontos > 0) pontosGanhosTotal += pontos;
          conferidas++;
        } catch (e) {
          print('⚠️ Erro ao conferir previsão ${bet['id']}: $e');
        }
      }

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
      print('❌ Erro no checkResults: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }
}
