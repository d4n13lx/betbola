import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Estilos reutilizáveis para Containers com borda.
/// Elimina duplicação de BorderRadius + Border em todo o app.
class AppStyles {
  AppStyles._();

  /// Container padrão com borda sutil.
  static BoxDecoration cardDecoration({
    Color? borderColor,
    Color? color,
    double radius = 16,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.surface,
      border: Border.all(color: borderColor ?? AppColors.border),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// Container destacado (borda colorida, raio maior).
  static BoxDecoration highlightDecoration({
    Color borderColor = AppColors.primary,
    Color? color,
    double radius = 20,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.surface,
      border: Border.all(color: borderColor),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// Decoração do BottomNavigationBar.
  static BoxDecoration navBarDecoration() {
    return BoxDecoration(
      color: AppColors.surfaceLight.withValues(alpha: 0.92), // ✅
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.borderLight),
    );
  }

  /// Texto de tag/label pequeno (ex: "DESAFIO ANTI-VÍCIO").
  static const TextStyle tagStyle = TextStyle(
    color: AppColors.primary,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  /// Texto de subtítulo no AppBar.
  static const TextStyle appBarSubtitle = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}
