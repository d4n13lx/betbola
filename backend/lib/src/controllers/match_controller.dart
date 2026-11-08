import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../services/football_api_service.dart';

class MatchController {
  static Future<Response> getAll(Request request) async {
    try {
      final matches = await FootballApiService.getMatches();
      return Response.ok(
        jsonEncode(matches),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  static Future<Response> getById(Request request, String id) async {
    try {
      final match = await FootballApiService.getMatchById(int.parse(id));
      return Response.ok(
        jsonEncode(match),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }
}
