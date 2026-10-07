// lib/models/game.dart
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class Game {
  final String home;
  final String away;
  final String date;
  final Color homeColor;
  final Color awayColor;

  const Game({
    required this.home,
    required this.away,
    required this.date,
    required this.homeColor,
    required this.awayColor,
  });

  /// Dados mockados centralizados.
  static const List<Game> mockGames = [
    Game(
      home: 'Palmeiras',
      away: 'Flamengo',
      date: 'Hoje, 21:30',
      homeColor: AppColors.teamGreen,
      awayColor: AppColors.teamRed,
    ),
    Game(
      home: 'Corinthians',
      away: 'Grêmio',
      date: 'Amanhã, 19:00',
      homeColor: AppColors.teamWhite,
      awayColor: AppColors.teamBlue,
    ),
    Game(
      home: 'São Paulo',
      away: 'Cruzeiro',
      date: 'Sáb, 16:00',
      homeColor: AppColors.teamRed,
      awayColor: AppColors.teamBlue,
    ),
  ];
}
