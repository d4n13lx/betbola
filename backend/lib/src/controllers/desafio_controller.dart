import 'dart:convert';
import 'dart:math';

import 'package:shelf/shelf.dart';
import 'package:supabase/supabase.dart';

import '../config/env.dart';

class DesafioController {
  static SupabaseClient get _supabase =>
      SupabaseClient(Env.supabaseUrl, Env.supabaseKey);

  // GET /api/desafios/aleatorio
  static Future<Response> getRandom(Request request) async {
    try {
      final perguntas = await _supabase.from('perguntas').select();
      if (perguntas.isEmpty) {
        return Response.ok(
          jsonEncode({'error': 'Nenhuma pergunta cadastrada'}),
        );
      }
      final random = Random();
      final pergunta = perguntas[random.nextInt(perguntas.length)];
      // Retorna sem a resposta correta
      return Response.ok(
        jsonEncode({
          'id': pergunta['id'],
          'pergunta': pergunta['pergunta'],
          'tipo': pergunta['tipo'],
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  // POST /api/desafios/responder
  static Future<Response> responder(Request request) async {
    final userId = request.context['userId'] as String;
    final body = jsonDecode(await request.readAsString());
    final desafioId = body['desafio_id'];
    final respostaUsuario = body['resposta'].toString().trim();

    try {
      // Busca a pergunta
      final pergunta = await _supabase
          .from('perguntas')
          .select()
          .eq('id', desafioId)
          .single();
      final respostaCorreta = pergunta['resposta_correta'].toString().trim();
      final tipo = pergunta['tipo'];

      // Calcula similaridade
      double similaridade;
      if (tipo == 'numero') {
        similaridade = _calcularSimilaridadeNumerica(
          respostaUsuario,
          respostaCorreta,
        );
      } else {
        similaridade = _calcularSimilaridadeTexto(
          respostaUsuario,
          respostaCorreta,
        );
      }

      // Busca usuário (ou cria se não existir)
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

      int pontosAtuais = user['pontos'] as int;
      int errosConsecutivos = user['erros_consecutivos'] as int;

      bool acertou = similaridade >= 0.85;
      int pontosGanhos = 0;
      String mensagem;
      DateTime? bloqueadoAte;

      if (acertou) {
        pontosGanhos = 10;
        pontosAtuais += pontosGanhos;
        errosConsecutivos = 0; // reset
        mensagem = 'Parabéns! Você acertou e ganhou $pontosGanhos pontos.';
      } else {
        pontosGanhos = -10;
        pontosAtuais -= 10; // perde 10
        errosConsecutivos++;
        if (errosConsecutivos >= 3) {
          bloqueadoAte = DateTime.now().add(const Duration(minutes: 5));
          mensagem = 'Você errou 3 vezes seguidas. Fique bloqueado por 5 minutos para refletir.';
        } else {
          mensagem = 'Você errou! Perdeu 10 pontos. Tente novamente.';
        }
      }

      // Atualiza usuário
      await _supabase
          .from('usuarios')
          .update({
            'pontos': pontosAtuais,
            'erros_consecutivos': errosConsecutivos,
            'bloqueado_ate': bloqueadoAte?.toIso8601String(),
          })
          .eq('user_id', userId);

      return Response.ok(
        jsonEncode({
          'acertou': acertou,
          'pontos_ganhos': pontosGanhos,
          'pontos_atuais': pontosAtuais,
          'mensagem': mensagem,
          'bloqueado_ate': bloqueadoAte?.toIso8601String(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  static double _calcularSimilaridadeNumerica(String usuario, String correta) {
    final num1 = double.tryParse(usuario) ?? 0;
    final num2 = double.tryParse(correta) ?? 1;
    if (num2 == 0) return num1 == 0 ? 1.0 : 0.0;
    return 1.0 - (num1 - num2).abs() / num2;
  }

  static double _calcularSimilaridadeTexto(String usuario, String correta) {
    // Implementação simples de Jaro-Winkler (ou use pacote fuzzy_bolt)
    // Para simplificar, compare minúsculas e distância de Levenshtein normalizada
    final a = usuario.toLowerCase();
    final b = correta.toLowerCase();
    if (a == b) return 1.0;
    final dist = _levenshtein(a, b);
    final maxLen = max(a.length, b.length);
    if (maxLen == 0) return 1.0;
    return 1.0 - dist / maxLen;
  }

  static int _levenshtein(String a, String b) {
    final dp = List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));
    for (var i = 0; i <= a.length; i++) {
      dp[i][0] = i;
    }
    for (var j = 0; j <= b.length; j++) {
      dp[0][j] = j;
    }
    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = min(
          min(dp[i - 1][j] + 1, dp[i][j - 1] + 1),
          dp[i - 1][j - 1] + cost,
        );
      }
    }
    return dp[a.length][b.length];
  }
}
