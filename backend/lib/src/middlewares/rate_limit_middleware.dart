import 'dart:convert';

import 'package:shelf/shelf.dart';

/// Rate limiter simples em memória (por IP).
/// Em produção, use Redis ou similar.
class RateLimitMiddleware {
  final int _maxRequests;
  final Duration _window;
  final Map<String, List<DateTime>> _requests = {};

  RateLimitMiddleware({int maxRequests = 30, Duration? window})
    : _maxRequests = maxRequests,
      _window = window ?? const Duration(minutes: 1);

  Middleware call() {
    return (innerHandler) {
      return (request) async {
        final ip =
            request.headers['x-forwarded-for'] ??
            request.context['shelf.io.connection_info']?.toString() ??
            'unknown';
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
