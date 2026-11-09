import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:supabase/supabase.dart';

import '../config/env.dart';

class UsuarioController {
  static SupabaseClient get _supabase =>
      SupabaseClient(Env.supabaseUrl, Env.supabaseKey);

  // GET /api/usuarios/status
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
}
