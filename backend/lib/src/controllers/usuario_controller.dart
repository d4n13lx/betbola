import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:supabase/supabase.dart';

import '../config/env.dart';

class UsuarioController {
  static SupabaseClient get _supabase =>
      SupabaseClient(Env.supabaseUrl, Env.supabaseKey);

  /// GET /api/usuarios/status
  static Future<Response> getStatus(Request request) async {
    final userId = request.context['userId'] as String;
    try {
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
      return Response.ok(
        jsonEncode({
          'pontos': user['pontos'],
          'bloqueado_ate': user['bloqueado_ate'],
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  /// GET /api/usuarios/estatisticas
  static Future<Response> getEstatisticas(Request request) async {
    final userId = request.context['userId'] as String;
    try {
      final bets = await _supabase
          .from('previsoes')
          .select()
          .eq('user_id', userId);

      int acertos = 0, erros = 0, pendentes = 0, pontosTotal = 0;
      for (var b in bets) {
        if (b['status'] == 'acertou') {
          acertos++;
          pontosTotal += (b['pontos'] as int?) ?? 0;
        } else if (b['status'] == 'errou') {
          erros++;
        } else {
          pendentes++;
        }
      }

      final total = acertos + erros;
      final aproveitamento = total > 0 ? (acertos / total * 100) : 0.0;

      return Response.ok(
        jsonEncode({
          'acertos': acertos,
          'erros': erros,
          'pendentes': pendentes,
          'total_palpites': bets.length,
          'pontos_total': pontosTotal,
          'aproveitamento': double.parse(aproveitamento.toStringAsFixed(1)),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }
}
