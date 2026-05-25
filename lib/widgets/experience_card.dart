import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/experience_model.dart';
import '../providers/auth_provider.dart';
import '../providers/experience_provider.dart';
import '../screens/experience_detail_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/design_system.dart';
import 'industry_badge.dart';
import 'attachment_item.dart';

class ExperienceCard extends StatefulWidget {
  final ExperienceModel experience;

  const ExperienceCard({super.key, required this.experience});

  @override
  State<ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<ExperienceCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: AppDurations.standard),
    );
    _shadowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppDurations.standard),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _formattedDate => DateFormat('dd MMM yyyy').format(widget.experience.registrationDate);

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXl),
        title: Text('Eliminar Experiencia', style: AppTypography.headlineSmall),
        content: Text(
          '¿Estás seguro de que deseas eliminar la experiencia de "${widget.experience.companyName}"?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<ExperienceProvider>().deleteExperience(widget.experience.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Experiencia eliminada correctamente'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMd),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: AppRadius.borderRadiusLg,
                border: Border(
                  left: BorderSide(
                    color: _isHovered ? AppColors.primaryBlue : AppColors.primaryViolet,
                    width: _isHovered ? 4 : 3,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _isHovered ? 0.12 : 0.06),
                    blurRadius: _isHovered ? 24 : 12,
                    offset: Offset(0, _isHovered ? 8 : 4),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Stack(
          children: [
            // Decorative gradient
            Positioned(
              top: -30,
              right: -30,
              child: AnimatedContainer(
                duration: AppDurations.fast,
                width: _isHovered ? 120 : 80,
                height: _isHovered ? 120 : 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryViolet.withValues(alpha: _isHovered ? 0.15 : 0.08),
                      AppColors.primaryBlue.withValues(alpha: _isHovered ? 0.1 : 0.05),
                    ],
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: AppSpacing.cardPaddingLarge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Company name + Delete button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.experience.companyName,
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.primaryBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isAdmin)
                        _buildActionButton(
                          Icons.delete_outline,
                          AppColors.error,
                          () => _confirmDelete(context),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Industry badge
                  IndustryBadge(industry: widget.experience.industry),
                  const SizedBox(height: AppSpacing.md),

                  // AI Tags
                  if (widget.experience.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: widget.experience.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  
                  // Summary
                  Text(
                    widget.experience.summary,
                    style: AppTypography.bodyMedium.copyWith(
                      color: textSecondary,
                      height: 1.6,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Meta info
                  _buildMetaRow(
                    Icons.calendar_today_outlined,
                    _formattedDate,
                    textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildMetaRow(
                    Icons.person_outline,
                    '${widget.experience.createdByName} · ${widget.experience.createdByCompany}',
                    textSecondary,
                  ),
                  
                  // Attachments
                  if (widget.experience.attachments.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: widget.experience.attachments
                          .map((a) => AttachmentItem(attachment: a, compact: true))
                          .toList(),
                    ),
                  ],
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // View details button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExperienceDetailScreen(
                              experience: widget.experience,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('Ver detalle'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: BorderSide(
                          color: _isHovered 
                              ? AppColors.primaryBlue 
                              : AppColors.primaryBlue.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusMd,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: AppTypography.captionLarge.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderRadiusSm,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}