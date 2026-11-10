import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase/supabase.dart';

import '../config/env.dart';

class FootballApiService {
  static final SupabaseClient _supabase = SupabaseClient(
    Env.supabaseUrl,
    Env.supabaseKey,
  );

  static const Duration _timeout = Duration(seconds: 10);

  static Map<String, String> get _headers => {
    'Authorization': 'Bearer ${Env.footballApiToken}',
  };

  /// IDs >= 90000 são exclusivamente do cache fictício (mock).
  static bool _isMockId(int id) => id >= 80000;

  static String _normalizarStatus(String? raw) {
    final s = (raw ?? '').toLowerCase().trim();
    if (s.isEmpty) return 'Agendada';
    if (s.contains('encerr') || s.contains('finaliz')) return 'Encerrada';
    if (s.contains('andamento') || s.contains('vivo')) return 'Em andamento';
    return 'Agendada';
  }

  static Map<String, dynamic> _normalizarApi(Map<String, dynamic> m) {
    final campeonato = m['campeonato'] as Map<String, dynamic>?;
    final mandante = m['time_mandante'] as Map<String, dynamic>?;
    final visitante = m['time_visitante'] as Map<String, dynamic>?;
    final estadio = m['estadio'] as Map<String, dynamic>?;

    return {
      'partida_id': (m['partida_id'] as int?) ?? 0,
      'campeonato': {
        'campeonato_id': (campeonato?['campeonato_id'] as int?) ?? 10,
        'nome': (campeonato?['nome'] as String?) ?? 'Brasileirão Série A',
        'slug': (campeonato?['slug'] as String?) ?? 'brasileirao-serie-a',
      },
      'placar': (m['placar'] as String?) ?? '',
      'time_mandante': {
        'time_id': (mandante?['time_id'] as int?) ?? 0,
        'nome_popular': (mandante?['nome_popular'] as String?) ?? 'Casa',
        'sigla': (mandante?['sigla'] as String?) ?? '',
        'escudo': (mandante?['escudo'] as String?) ?? '',
      },
      'time_visitante': {
        'time_id': (visitante?['time_id'] as int?) ?? 0,
        'nome_popular': (visitante?['nome_popular'] as String?) ?? 'Fora',
        'sigla': (visitante?['sigla'] as String?) ?? '',
        'escudo': (visitante?['escudo'] as String?) ?? '',
      },
      'placar_mandante': (m['placar_mandante'] as int?) ?? 0,
      'placar_visitante': (m['placar_visitante'] as int?) ?? 0,
      'disputa_penalti': (m['disputa_penalti'] as bool?) ?? false,
      'status': _normalizarStatus(m['status'] as String?),
      'slug': (m['slug'] as String?) ?? '',
      'data_realizacao': (m['data_realizacao'] as String?) ?? '',
      'hora_realizacao': (m['hora_realizacao'] as String?) ?? '',
      'data_realizacao_iso': (m['data_realizacao_iso'] as String?) ?? '',
      'estadio': {
        'estadio_id': (estadio?['estadio_id'] as int?) ?? 0,
        'nome_popular': (estadio?['nome_popular'] as String?) ?? '',
      },
      '_link': (m['_link'] as String?) ?? '',
    };
  }

  static Map<String, dynamic> _normalizarCache(Map<String, dynamic> c) {
    final status = _normalizarStatus(c['status'] as String?);
    final casa = (c['time_casa'] as String?) ?? 'Casa';
    final fora = (c['time_fora'] as String?) ?? 'Fora';

    return {
      'partida_id': (c['partida_id'] as int?) ?? 0,
      'campeonato': {
        'campeonato_id': 10,
        'nome': (c['campeonato'] as String?) ?? 'Brasileirão Série A',
        'slug': 'brasileirao-serie-a',
      },
      'placar': '${c['placar_casa'] ?? 0}x${c['placar_fora'] ?? 0}',
      'time_mandante': {
        'time_id': 0,
        'nome_popular': casa,
        'sigla': casa.isNotEmpty ? casa.substring(0, 1).toUpperCase() : '?',
        'escudo': (c['escudo_casa'] as String?) ?? '',
      },
      'time_visitante': {
        'time_id': 0,
        'nome_popular': fora,
        'sigla': fora.isNotEmpty ? fora.substring(0, 1).toUpperCase() : '?',
        'escudo': (c['escudo_fora'] as String?) ?? '',
      },
      'placar_mandante': (c['placar_casa'] as int?) ?? 0,
      'placar_visitante': (c['placar_fora'] as int?) ?? 0,
      'disputa_penalti': false,
      'status': status,
      'slug': '',
      'data_realizacao': (c['data_realizacao'] as String?) ?? '',
      'hora_realizacao': '',
      'data_realizacao_iso': (c['data_realizacao'] as String?) ?? '',
      'estadio': {'estadio_id': 0, 'nome_popular': ''},
      '_link': '',
    };
  }

  static Future<List<dynamic>> getMatches() async {
    final resultados = <int, Map<String, dynamic>>{};

    // 1. Cache do Supabase (base)
    try {
      final cache = await _supabase.from('partidas_cache').select();
      for (final c in cache) {
        final id = (c['partida_id'] as int?) ?? 0;
        resultados[id] = _normalizarCache(c);
      }
      print('ℹ️ [Cache] ${resultados.length} partidas base.');
    } catch (e) {
      print('❌ [Cache] Falha: $e');
    }

    // 2. Ao vivo (real) — só sobrescreve se NÃO for ID mock
    try {
      final r = await http
          .get(Uri.parse('${Env.footballApiUrl}/ao-vivo'), headers: _headers)
          .timeout(_timeout);
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        if (data is List) {
          for (final m in data) {
            final id = (m['partida_id'] as int?) ?? 0;
            if (id > 0 && !_isMockId(id)) {
              resultados[id] = _normalizarApi(m as Map<String, dynamic>);
            }
          }
        }
        print('ℹ️ [API] /ao-vivo: total ${resultados.length}');
      }
    } catch (e) {
      print('⚠️ [API] /ao-vivo falhou: $e');
    }

    // 3. Campeonato (real) — parse robusto
    try {
      final r = await http
          .get(
            Uri.parse('${Env.footballApiUrl}/campeonatos/10/partidas'),
            headers: _headers,
          )
          .timeout(_timeout);
      if (r.statusCode == 200) {
        final dynamic decoded = jsonDecode(r.body);
        List<dynamic>? partidas;

        // Corrige o erro de cast: aceita List direto OU Map com chave 'partidas'
        if (decoded is List) {
          partidas = decoded;
        } else if (decoded is Map<String, dynamic>) {
          final p = decoded['partidas'];
          if (p is List) partidas = p;
        }

        if (partidas != null) {
          for (final m in partidas) {
            if (m is! Map<String, dynamic>) continue;
            final id = (m['partida_id'] as int?) ?? 0;
            if (id > 0 && !_isMockId(id)) {
              resultados[id] = _normalizarApi(m);
            }
          }
        }
        print('ℹ️ [API] /campeonatos/10/partidas: total ${resultados.length}');
      }
    } catch (e) {
      print('⚠️ [API] /campeonatos/10/partidas falhou: $e');
    }

    final lista = resultados.values.toList()
      ..sort((a, b) {
        final da = (a['data_realizacao_iso'] as String?) ?? '';
        final db = (b['data_realizacao_iso'] as String?) ?? '';
        return da.compareTo(db);
      });

    return lista;
  }

  static Future<Map<String, dynamic>> getMatchById(int id) async {
    // IDs fictícios: direto no cache
    if (_isMockId(id)) {
      final cache = await _supabase
          .from('partidas_cache')
          .select()
          .eq('partida_id', id)
          .maybeSingle();
      if (cache != null) return _normalizarCache(cache);
      throw Exception('Partida mock $id não encontrada no cache.');
    }

    // IDs reais: tenta a API, fallback cache
    try {
      final r = await http
          .get(
            Uri.parse('${Env.footballApiUrl}/partidas/$id'),
            headers: _headers,
          )
          .timeout(_timeout);
      if (r.statusCode == 200) {
        final decoded = jsonDecode(r.body);
        if (decoded is Map<String, dynamic>) {
          return _normalizarApi(decoded);
        }
      }
    } catch (e) {
      print('⚠️ [API] /partidas/$id falhou: $e');
    }

    final cache = await _supabase
        .from('partidas_cache')
        .select()
        .eq('partida_id', id)
        .maybeSingle();
    if (cache != null) return _normalizarCache(cache);

    throw Exception('Partida $id não encontrada.');
  }
}
