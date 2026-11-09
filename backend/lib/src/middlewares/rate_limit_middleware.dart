import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

/// Rate limiter simples em memória (por IP).
/// Em produção, use Redis ou similar.
class RateLimitMiddleware {
  final int _maxRequests;
  final Duration _window;
  final Map<String, List<DateTime>> _requests = {};

  RateLimitMiddleware({this._maxRequests = 30, Duration? window})
    : _window = window ?? const Duration(minutes: 1);

  Middleware call() {
    return (innerHandler) {
      return (request) async {
        // 1. Tenta X-Forwarded-For (proxy reverso)
        String ip =
            request.headers['x-forwarded-for']?.split(',').first.trim() ?? '';

        // 2. Fallback: IP real do socket
        if (ip.isEmpty) {
          final info =
              request.context['shelf.io.connection_info']
                  as HttpConnectionInfo?;
          ip = info?.remoteAddress.address ?? 'unknown';
        }

        final now = DateTime.now();
        _requests[ip] ??= [];
        _requests[ip]!.removeWhere((t) => now.difference(t) > _window);

        if (_requests[ip]!.length >= _maxRequests) {
          return Response(
            429,
            body: jsonEncode({
              'error': 'Muitas requisições. Aguarde um instante.',
            }),
            headers: {'content-type': 'application/json'},
          );
        }

        _requests[ip]!.add(now);
        return innerHandler(request);
      };
    };
  }
}
