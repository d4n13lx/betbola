import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Escudo circular reutilizável para times.
/// Substitui _buildShield e _buildTeam duplicados.
class TeamShield extends StatelessWidget {
  final String name;
  final String escudo;
  final double size;

  const TeamShield({
    super.key,
    required this.name,
    required this.escudo,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      //   decoration: BoxDecoration(
      //     color: color,
      //     shape: BoxShape.circle,
      //     border: Border.all(color: Colors.white30, width: 2),
      //   ),
      child: Center(child: Image.network(escudo)),
    );
  }
}
