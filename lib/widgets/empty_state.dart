import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/design_system.dart';
import 'app_button.dart';

/// Pantalla de estado vacío (sin datos) profesional.
/// Incluye icono, mensaje, descripción opcional y botón de acción.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  // ── Constructor factory para casos comunes ───────────────────────
  factory EmptyState.noResults({
    VoidCallback? onClearFilters,
  }) {
    return EmptyState(
      icon: Icons.search_off_rounded,
      title: 'Sin resultados',
      description: 'No se encontraron experiencias con los filtros actuales.',
      actionLabel: onClearFilters != null ? 'Limpiar filtros' : null,
      onAction: onClearFilters,
    );
  }

  factory EmptyState.noData({
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return EmptyState(
      icon: Icons.inbox_outlined,
      title: 'No hay datos',
      description: 'Aún no se han registrado experiencias.',
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  factory EmptyState.error({
    required String message,
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: 'Algo salió mal',
      description: message,
      actionLabel: onRetry != null ? 'Reintentar' : null,
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: AppSpacing.cardPaddingLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono con círculo de fondo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.darkSurfaceVariant 
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: isDark 
                    ? AppColors.darkTextTertiary 
                    : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Título
            Text(
              title,
              style: AppTypography.headlineSmall.copyWith(
                color: isDark 
                    ? AppColors.darkTextPrimary 
                    : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Descripción
            if (description != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark 
                      ? AppColors.darkTextSecondary 
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Botón de acción
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                size: AppButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}