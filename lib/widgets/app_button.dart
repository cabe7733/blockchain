import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/design_system.dart';

/// Botón con variantes: primary, secondary, ghost, danger.
/// Parte del Design System.
enum AppButtonVariant { primary, secondary, ghost, danger }

/// Botón con diferentes tamaños.
enum AppButtonSize { small, medium, large }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  // ── Configuración por tamaño ───────────────────────────────────
  double get _height {
    switch (widget.size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return 44;
      case AppButtonSize.large:
        return 52;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 18;
      case AppButtonSize.large:
        return 20;
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case AppButtonSize.small:
        return AppTypography.labelSmall;
      case AppButtonSize.medium:
        return AppTypography.labelMedium;
      case AppButtonSize.large:
        return AppTypography.labelLarge;
    }
  }

  // ── Configuración por variante ─────────────────────────────────
  Color get _backgroundColor {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return isDisabled 
            ? AppColors.border 
            : AppColors.primaryBlue;
      case AppButtonVariant.secondary:
        return isDisabled 
            ? AppColors.borderLight 
            : AppColors.primaryBlue.withValues(alpha: 0.1);
      case AppButtonVariant.ghost:
        return Colors.transparent;
      case AppButtonVariant.danger:
        return isDisabled 
            ? AppColors.border 
            : AppColors.error;
    }
  }

  Color get _foregroundColor {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return isDisabled ? AppColors.textTertiary : AppColors.white;
      case AppButtonVariant.secondary:
        return isDisabled ? AppColors.textTertiary : AppColors.primaryBlue;
      case AppButtonVariant.ghost:
        return isDisabled ? AppColors.textTertiary : AppColors.primaryBlue;
      case AppButtonVariant.danger:
        return isDisabled ? AppColors.textTertiary : AppColors.white;
    }
  }

  BorderSide? get _border {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    
    if (widget.variant == AppButtonVariant.secondary) {
      return BorderSide(
        color: isDisabled ? AppColors.border : AppColors.primaryBlue,
        width: 1.5,
      );
    }
    return null;
  }

  List<BoxShadow>? get _shadow {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    
    if (widget.variant == AppButtonVariant.primary && !isDisabled) {
      return [
        BoxShadow(
          color: AppColors.primaryBlue.withValues(alpha: 0.35),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;
    
    if (widget.isLoading) {
      child = SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _foregroundColor,
        ),
      );
    } else {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: _iconSize, color: _foregroundColor),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            widget.label,
            style: _textStyle.copyWith(color: _foregroundColor),
          ),
        ],
      );
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        height: _height,
        width: widget.fullWidth ? double.infinity : null,
        padding: _padding,
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: AppRadius.borderRadiusMd,
          border: _border != null ? Border.fromBorderSide(_border!) : null,
          boxShadow: _shadow,
        ),
        transform: _isPressed 
            ? (Matrix4.identity()..scale(0.98)) 
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        child: child,
      ),
    );
  }
}