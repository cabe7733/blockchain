import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Design System: Escala tipográfica consistente.
/// Define estilos de texto para toda la app con jerarquía clara.
class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Roboto';

  // ── Display: Títulos principales (hero sections) ─────────────────
  static TextStyle get displayLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle get displayMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static TextStyle get displaySmall => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ── Headline: Títulos de sección ──────────────────────────────────
  static TextStyle get headlineLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static TextStyle get headlineMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get headlineSmall => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ── Title: Títulos de cards y elementos ───────────────────────────
  static TextStyle get titleLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  static TextStyle get titleMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get titleSmall => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // ── Body: Contenido principal ─────────────────────────────────────
  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static TextStyle get bodySmall => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ── Label: Botones, chips, tabs ───────────────────────────────────
  static TextStyle get labelLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get labelMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get labelSmall => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // ── Caption: Metadatos, timestamps, hints ─────────────────────────
  static TextStyle get captionLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get captionMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  static TextStyle get captionSmall => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  // ── Estilos especiales ────────────────────────────────────────────
  static TextStyle get link => bodyMedium.copyWith(
    color: AppColors.primaryBlue,
    decoration: TextDecoration.underline,
  );

  static TextStyle get button => labelLarge.copyWith(
    color: AppColors.white,
  );

  static TextStyle get inputLabel => labelMedium.copyWith(
    color: AppColors.textSecondary,
  );

  static TextStyle get inputHint => bodyMedium.copyWith(
    color: AppColors.textTertiary,
  );

  static TextStyle get inputError => captionMedium.copyWith(
    color: AppColors.error,
  );

  // ── Versión para modo oscuro ─────────────────────────────────────
  static TextStyle get displayLargeDark => displayLarge.copyWith(
    color: AppColors.darkTextPrimary,
  );
  static TextStyle get bodyLargeDark => bodyLarge.copyWith(
    color: AppColors.darkTextPrimary,
  );
  static TextStyle get bodyMediumDark => bodyMedium.copyWith(
    color: AppColors.darkTextSecondary,
  );
  static TextStyle get captionLargeDark => captionLarge.copyWith(
    color: AppColors.darkTextTertiary,
  );
}