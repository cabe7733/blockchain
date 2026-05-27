import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'design_system.dart';

/// Design System: Temas predefinidos para componentes Material.
/// Unifica la apariencia de inputs, buttons, cards, etc.
class ComponentTheme {
  ComponentTheme._();

  // ── Input Decoration Theme ───────────────────────────────────────
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
    border: OutlineInputBorder(
      borderRadius: AppRadius.borderRadiusMd,
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.borderRadiusMd,
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.borderRadiusMd,
      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.borderRadiusMd,
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppRadius.borderRadiusMd,
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.borderRadiusMd,
      borderSide: const BorderSide(color: AppColors.borderLight),
    ),
    labelStyle: AppTypography.inputLabel,
    hintStyle: AppTypography.inputHint,
    errorStyle: AppTypography.inputError,
    prefixIconColor: AppColors.textSecondary,
    suffixIconColor: AppColors.textSecondary,
  );

  // ── Elevated Button Theme ─────────────────────────────────────────
  static ElevatedButtonThemeData get elevatedButtonTheme => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusMd,
      ),
    ),
  );

  // ── Text Button Theme ─────────────────────────────────────────────
  static TextButtonThemeData get textButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryBlue,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusMd,
      ),
    ),
  );

  // ── Outlined Button Theme ────────────────────────────────────────
  static OutlinedButtonThemeData get outlinedButtonTheme => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryBlue,
      side: const BorderSide(color: AppColors.primaryBlue),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusMd,
      ),
    ),
  );

  // ── Card Theme ───────────────────────────────────────────────────
  static CardThemeData cardTheme({bool isDark = false}) => CardThemeData(
    color: isDark ? AppColors.darkSurface : AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.borderRadiusLg,
      side: BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.borderLight,
        width: 1,
      ),
    ),
    margin: EdgeInsets.zero,
    surfaceTintColor: Colors.transparent,
  );

  // ── Chip Theme ───────────────────────────────────────────────────
  static ChipThemeData get chipTheme => ChipThemeData(
    backgroundColor: AppColors.surfaceVariant,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.borderRadiusSm,
    ),
  );

  // ── AppBar Theme ──────────────────────────────────────────────────
  static AppBarTheme get appBarTheme => const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    foregroundColor: AppColors.white,
    centerTitle: false,
    iconTheme: IconThemeData(color: AppColors.white),
  );

  // ── Dialog Theme ─────────────────────────────────────────────────
  static DialogThemeData get dialogThemeData => DialogThemeData(
    backgroundColor: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.borderRadiusXl,
    ),
    titleTextStyle: AppTypography.headlineSmall,
    contentTextStyle: AppTypography.bodyMedium,
  );

  // ── Snackbar Theme ───────────────────────────────────────────────
  static SnackBarThemeData get snackbarTheme => SnackBarThemeData(
    backgroundColor: AppColors.darkBg,
    contentTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.white),
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.borderRadiusMd,
    ),
    behavior: SnackBarBehavior.floating,
  );

  // ── Floating Action Button Theme ─────────────────────────────────
  static FloatingActionButtonThemeData get fabTheme => FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryBlue,
    foregroundColor: AppColors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.borderRadiusLg,
    ),
  );

  // ── Tab Bar Theme ────────────────────────────────────────────────
  static TabBarThemeData get tabBarThemeData => TabBarThemeData(
    labelColor: AppColors.primaryBlue,
    unselectedLabelColor: AppColors.textSecondary,
    indicator: const BoxDecoration(
      color: AppColors.primaryBlue,
      borderRadius: AppRadius.borderRadiusMd,
    ),
    indicatorSize: TabBarIndicatorSize.tab,
    dividerColor: Colors.transparent,
  );

  // ── Divider Theme ────────────────────────────────────────────────
  static DividerThemeData get dividerTheme => const DividerThemeData(
    color: AppColors.divider,
    thickness: 1,
    space: 1,
  );

  // ── Icon Theme ───────────────────────────────────────────────────
  static IconThemeData get iconTheme => const IconThemeData(
    color: AppColors.textSecondary,
    size: 24,
  );

  // ── Progress Indicator Theme ───────────────────────────────────────
  static ProgressIndicatorThemeData get progressIndicatorTheme => const ProgressIndicatorThemeData(
    color: AppColors.primaryBlue,
    linearTrackColor: AppColors.border,
    circularTrackColor: AppColors.border,
  );
}