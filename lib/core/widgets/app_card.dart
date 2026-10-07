import 'package:flutter/material.dart';
import '../theme/app_styles.dart';

/// Card reutilizável que substitui os Containers duplicados.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? borderColor;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.borderColor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: AppStyles.cardDecoration(
        borderColor: borderColor,
        color: color,
        radius: radius,
      ),
      child: child,
    );
  }
}
