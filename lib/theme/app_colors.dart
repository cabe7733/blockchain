import 'package:flutter/material.dart';

/// Design System: Paleta de colores extendida para la app.
/// Incluye colores semánticos, neutrales y de industria.
class AppColors {
  AppColors._();

  // ── Colores Primarios ───────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueLight = Color(0xFF3B82F6);
  static const Color primaryBlueDark = Color(0xFF1D4ED8);
  
  static const Color primaryViolet = Color(0xFF7C3AED);
  static const Color primaryVioletLight = Color(0xFF8B5CF6);
  static const Color primaryVioletDark = Color(0xFF6D28D9);

  // ── Colores Semánticos (Estado) ───────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF059669);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF06B6D4);
  static const Color infoLight = Color(0xFFCFFAFE);
  static const Color infoDark = Color(0xFF0891B2);

  // ── Colores Neutrales (Modo Claro) ────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);

  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color divider = Color(0xFFE5E7EB);

  // ── Colores Neutrales (Modo Oscuro) ────────────────────────────────
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextTertiary = Color(0xFF6B7280);
  
  static const Color darkBorder = Color(0xFF374151);
  static const Color darkDivider = Color(0xFF1E293B);

  // ── Colores para Industrias (Badge Colors) ────────────────────────
  static const Map<String, Color> industryColors = {
    'Finanzas': Color(0xFF10B981),
    'Logística': Color(0xFF3B82F6),
    'Salud': Color(0xFFEF4444),
    'Retail': Color(0xFFF59E0B),
    'Manufactura': Color(0xFF8B5CF6),
    'Gobierno': Color(0xFF6366F1),
    'Educación': Color(0xFF14B8A6),
    'Energía': Color(0xFFF97316),
    'Otro': Color(0xFF6B7280),
  };

  // ── Colores para Gradientes ───────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryViolet],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryBlueDark, primaryViolet],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, successDark],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [white, background],
  );

  // ── Métodos helpers ───────────────────────────────────────────────
  static Color getIndustryColor(String industry) {
    return industryColors[industry] ?? textSecondary;
  }

  static Color getIndustryColorLight(String industry) {
    final color = getIndustryColor(industry);
    return color.withValues(alpha: 0.1);
  }
}