import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Escudo circular reutilizável para times.
/// Substitui _buildShield e _buildTeam duplicados.
class TeamShield extends StatelessWidget {
  final String escudo;
  final double size;

  const TeamShield({
    super.key,
    required this.escudo,
    this.size = 70,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipOval(
        child: SvgPicture.network(
          escudo,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
