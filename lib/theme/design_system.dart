import 'package:flutter/material.dart';

/// Design System: Constantes fundamentales para spacing, border radius y sombras.
/// Basado en sistema de 8px para consistencia visual.
class AppSpacing {
  AppSpacing._();

  // ── Espaciado (basado en 8px) ─────────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // ── Padding estándar para pantallas ───────────────────────────────
  static const EdgeInsets screenPadding = EdgeInsets.all(md);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets screenPaddingVertical = EdgeInsets.symmetric(vertical: md);

  // ── Padding para cards y containers ───────────────────────────────
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(lg);

  // ── Gap padrão para listas y grids ───────────────────────────────
  static const double gapXs = 4.0;
  static const double gapSm = 8.0;
  static const double gapMd = 16.0;
  static const double gapLg = 24.0;
  static const double gapXl = 32.0;
}

/// Design System: Radio de bordes consistentes.
class AppRadius {
  AppRadius._();

  // ── Radio para elementos pequeños ─────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;

  // ── Radio para elementos medianos (buttons, inputs, chips) ──────
  static const double md = 12.0;

  // ── Radio para cards y containers grandes ─────────────────────────
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  // ── BorderRadius predefinidos ─────────────────────────────────────
  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderRadiusXxl = BorderRadius.all(Radius.circular(xxl));

  // ── Radio para Pills (chips grandes) ──────────────────────────────
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

/// Design System: Sombras con diferentes niveles de elevación.
class AppShadows {
  AppShadows._();

  // ── Sombras para elevación sutil (cards, inputs) ──────────────────
  static List<BoxShadow> get subtle => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // ── Sombras para cards elevados ─────────────────────────────────────
  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Sombras para modals y dropdowns ────────────────────────────────
  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // ── Sombras para elementos flotantes (FAB, buttons activos) ───────
  static List<BoxShadow> get floating => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  // ── Sombras específicas para modo claro/oscuro ───────────────────
  static List<BoxShadow> cardLight([double opacity = 0.08]) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: opacity),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardDark([double opacity = 0.3]) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: opacity),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

/// Design System: Duraciones de animaciones predefinidas.
class AppDurations {
  AppDurations._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // ── Curvas de animación comunes ───────────────────────────────────
  static const Curve standard = Curves.easeInOut;
  static const Curve decelerate = Curves.easeOut;
  static const Curve accelerate = Curves.easeIn;
  static const Curve bounce = Curves.elasticOut;
}