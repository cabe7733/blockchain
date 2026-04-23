import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/experience_model.dart';
import '../providers/auth_provider.dart';
import '../providers/experience_provider.dart';
import '../screens/experience_detail_screen.dart';
import '../theme/app_theme.dart';
import 'industry_badge.dart';
import 'attachment_item.dart';

/// Card de experiencia con hover effect, rol admin y botón eliminar.
class ExperienceCard extends StatefulWidget {
  final ExperienceModel experience;

  const ExperienceCard({super.key, required this.experience});

  @override
  State<ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<ExperienceCard> {
  bool _isHovered = false;

  String get _formattedDate =>
      DateFormat('dd/MM/yyyy').format(widget.experience.registrationDate);

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Experiencia'),
        content: Text(
          '¿Estás seguro de que deseas eliminar la experiencia de '
          '"${widget.experience.companyName}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed),
            child: const Text('Eliminar',
                style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context
            .read<ExperienceProvider>()
            .deleteExperience(widget.experience.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Experiencia eliminada'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: AppTheme.errorRed,
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
    final cardBg = isDark ? const Color(0xFF1E293B) : AppTheme.white;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: const Border(
                left: BorderSide(color: AppTheme.cardBorder, width: 4)),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(_isHovered ? 0.18 : 0.07),
                blurRadius: _isHovered ? 28 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Efecto blur decorativo
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryViolet.withOpacity(0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Empresa ─────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.experience.companyName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAdmin)
                          IconButton(
                            onPressed: () => _confirmDelete(context),
                            icon: const Icon(Icons.delete_outline,
                                color: AppTheme.errorRed, size: 20),
                            tooltip: 'Eliminar',
                            constraints: const BoxConstraints(
                                minWidth: 32, minHeight: 32),
                            padding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // ── Badge industria ──────────────────────
                    IndustryBadge(industry: widget.experience.industry),
                    const SizedBox(height: 10),
                    // ── Resumen ─────────────────────────────
                    Text(
                      widget.experience.summary,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.grey.shade400
                            : AppTheme.textGray,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    // ── Fecha ───────────────────────────────
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 12, color: AppTheme.textGray),
                        const SizedBox(width: 5),
                        Text(
                          _formattedDate,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textGray),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // ── Autor ───────────────────────────────
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 12, color: AppTheme.textGray),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '${widget.experience.createdByName} — ${widget.experience.createdByCompany}',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textGray),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // ── Adjuntos compactos ──────────────────
                    if (widget.experience.attachments.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: widget.experience.attachments
                            .map((a) => AttachmentItem(
                                attachment: a, compact: true))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 14),
                    // ── Botón ver detalle ───────────────────
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExperienceDetailScreen(
                                  experience: widget.experience),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility_outlined, size: 15),
                        label: const Text('Ver detalle'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          side:
                              const BorderSide(color: AppTheme.primaryBlue),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
