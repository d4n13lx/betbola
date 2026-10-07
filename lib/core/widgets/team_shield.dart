import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Escudo circular reutilizável para times.
/// Substitui _buildShield e _buildTeam duplicados.
class TeamShield extends StatelessWidget {
  final String name;
  final Color color;
  final double size;

  const TeamShield({
    super.key,
    required this.name,
    required this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = color == AppColors.teamWhite;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white30, width: 2),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : '?',
          style: TextStyle(
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
            color: isLight ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
