import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white30, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipOval(
        child: SvgPicture.network(
          escudo,
          width: size,
          height: size,
          fit: BoxFit.contain,
          //  placeholderBuilder: (_) => Center(
          //    child: SizedBox(
          //      width: size * 0.4,
          //      height: size * 0.4,
          //      child: const CircularProgressIndicator(strokeWidth: 2),
          //    ),
          //  ),
        ),
      ),
    );
  }
}
