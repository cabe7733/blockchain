import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'app_colors.dart';
import 'app_typography.dart';
import 'component_theme.dart';

class AppTheme {
  AppTheme._();

  // ── Colores base (mantenemos compatibilidad) ─────────────────────
  static const Color primaryBlue = AppColors.primaryBlue;
  static const Color primaryViolet = AppColors.primaryViolet;
  static const Color primaryDark = AppColors.darkBg;
  static const Color textDark = AppColors.textPrimary;
  static const Color textGray = AppColors.textSecondary;
  static const Color white = AppColors.white;
  static const Color errorRed = AppColors.error;
  static const Color successGreen = AppColors.success;
  static const Color cardBorder = AppColors.primaryBlue;

  // ── Gradientes (compatibilidad) ───────────────────────────────────
  static const LinearGradient backgroundGradient = AppColors.backgroundGradient;
  static const LinearGradient buttonGradient = AppColors.primaryGradient;
  static const LinearGradient badgeGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryBlue, primaryViolet],
  );

  // ── Tema Claro ───────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Outfit',
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryViolet,
        surface: AppColors.surface,
        error: errorRed,
        onPrimary: white,
        onSecondary: white,
        onSurface: textDark,
        onError: white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: ComponentTheme.appBarTheme,
      inputDecorationTheme: ComponentTheme.inputDecorationTheme,
      elevatedButtonTheme: ComponentTheme.elevatedButtonTheme,
      textButtonTheme: ComponentTheme.textButtonTheme,
      outlinedButtonTheme: ComponentTheme.outlinedButtonTheme,
      cardTheme: ComponentTheme.cardTheme(),
      chipTheme: ComponentTheme.chipTheme,
      dialogTheme: ComponentTheme.dialogThemeData,
      snackBarTheme: ComponentTheme.snackbarTheme,
      floatingActionButtonTheme: ComponentTheme.fabTheme,
      tabBarTheme: ComponentTheme.tabBarThemeData,
      dividerTheme: ComponentTheme.dividerTheme,
      iconTheme: ComponentTheme.iconTheme,
      progressIndicatorTheme: ComponentTheme.progressIndicatorTheme,
    );
  }

  // ── Tema Oscuro ───────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Outfit',
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlueLight,
        secondary: AppColors.primaryVioletLight,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.darkTextPrimary,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBg,
      appBarTheme: ComponentTheme.appBarTheme.copyWith(
        titleTextStyle: AppTypography.headlineMedium.copyWith(
          color: AppColors.white,
        ),
      ),
      inputDecorationTheme: ComponentTheme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlueLight, width: 2),
        ),
      ),
      cardTheme: ComponentTheme.cardTheme(isDark: true),
      dialogTheme: ComponentTheme.dialogThemeData.copyWith(
        backgroundColor: AppColors.darkSurface,
      ),
      snackBarTheme: ComponentTheme.snackbarTheme.copyWith(
        backgroundColor: AppColors.darkSurfaceVariant,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
      ),
    );
  }
}