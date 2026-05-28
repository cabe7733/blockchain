import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/experience_model.dart';
import '../providers/auth_provider.dart';
import '../providers/experience_provider.dart';
import '../theme/app_theme.dart';
import '../utils/pdf_generator.dart';
import '../widgets/industry_badge.dart';
import '../widgets/attachment_item.dart';
import '../widgets/gradient_button.dart';
import 'add_experience_screen.dart';

class ExperienceDetailScreen extends StatefulWidget {
  final ExperienceModel experience;

  const ExperienceDetailScreen({super.key, required this.experience});

  @override
  State<ExperienceDetailScreen> createState() => _ExperienceDetailScreenState();
}

class _ExperienceDetailScreenState extends State<ExperienceDetailScreen> {
  bool _exportingPdf = false;
  bool get _isOwner {
    final authProvider = context.read<AuthProvider>();
    return authProvider.userModel?.uid == widget.experience.createdBy;
  }

  String get _formattedDate {
    try {
      return DateFormat("dd 'de' MMMM 'de' yyyy", 'es')
          .format(widget.experience.registrationDate);
    } catch (_) {
      return DateFormat('dd/MM/yyyy')
          .format(widget.experience.registrationDate);
    }
  }

  Future<void> _exportDetail() async {
    setState(() => _exportingPdf = true);
    try {
      await PdfGenerator.generateDetailReport(widget.experience);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al exportar: $e'),
          backgroundColor: AppTheme.errorRed,
        ));
      }
    } finally {
      if (mounted) setState(() => _exportingPdf = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Experiencia'),
        content: Text(
          '¿Estás seguro de que deseas eliminar la experiencia de "${widget.experience.companyName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Eliminar', style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<ExperienceProvider>().deleteExperience(widget.experience.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Experiencia eliminada correctamente'),
              backgroundColor: AppTheme.successGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: AppTheme.errorRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _navigateToEdit() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AddExperienceScreen(
          experienceToEdit: widget.experience,
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Future<void> _openLink() async {
    final link = widget.experience.link;
    if (link == null || link.isEmpty) return;
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isMobile = sw < 768;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : sw * 0.12,
                    vertical: 20,
                  ),
                  child: _buildContent(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppTheme.white),
          ),
          Expanded(
            child: Text(
              'Detalle de Experiencia',
              style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isOwner) ...[
                _buildActionButton(
                  Icons.edit_outlined,
                  AppTheme.white,
                  _navigateToEdit,
                ),
                const SizedBox(width: 4),
                _buildActionButton(
                  Icons.delete_outline,
                  AppTheme.errorRed,
                  _confirmDelete,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: const Border(
            left: BorderSide(color: AppTheme.cardBorder, width: 5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header empresa + badge ─────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.experience.companyName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IndustryBadge(
                  industry: widget.experience.industry, fontSize: 13),
            ],
          ),
          // ── Tags ──────────────────────────────────────────
          if (widget.experience.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: widget.experience.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '#$tag',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),

          // ── Registrado por chip ────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_outline,
                    size: 15, color: AppTheme.primaryBlue),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Registrado por: ${widget.experience.createdByName}'
                    ' — ${widget.experience.createdByCompany}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Fecha ──────────────────────────────────────
          _infoRow(
              Icons.calendar_today_outlined, 'Fecha de Registro', _formattedDate),
          const SizedBox(height: 14),

          // ── Link de Referencia (opcional) ──────────────
          if (widget.experience.link != null && widget.experience.link!.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.link, size: 15, color: AppTheme.primaryBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Link de Referencia',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textGray,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      InkWell(
                        onTap: _openLink,
                        child: Text(
                          widget.experience.link!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlue,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _openLink,
                  icon: const Icon(Icons.open_in_new, size: 18, color: AppTheme.primaryBlue),
                  tooltip: 'Abrir enlace',
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          const Divider(),
          const SizedBox(height: 18),

          // ── Resumen ────────────────────────────────────
          const Text('Resumen de la Experiencia',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isDark
                      ? Colors.grey.shade700
                      : const Color(0xFFE2E8F0)),
            ),
            child: Text(
              widget.experience.summary,
              style: const TextStyle(fontSize: 14, height: 1.7),
            ),
          ),

          // ── Insights de IA (Retos y Beneficios) ──────────
          if (widget.experience.keyChallenges.isNotEmpty || widget.experience.keyBenefits.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 18),
            
            // Retos Clave
            if (widget.experience.keyChallenges.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Retos Técnicos y de Negocio',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...widget.experience.keyChallenges.map((challenge) => Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6, right: 10),
                      child: Icon(Icons.circle, color: Colors.orange, size: 6),
                    ),
                    Expanded(
                      child: Text(
                        challenge,
                        style: const TextStyle(fontSize: 13.5, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 18),
            ],
            
            // Beneficios Clave
            if (widget.experience.keyBenefits.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: AppTheme.successGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Beneficios y Lecciones Aprendidas',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...widget.experience.keyBenefits.map((benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6, right: 10),
                      child: Icon(Icons.circle, color: AppTheme.successGreen, size: 6),
                    ),
                    Expanded(
                      child: Text(
                        benefit,
                        style: const TextStyle(fontSize: 13.5, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],

          // ── Adjuntos ────────────────────────────────────
          if (widget.experience.attachments.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(Icons.attach_file,
                    color: AppTheme.primaryBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Archivos Adjuntos (${widget.experience.attachments.length})',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...widget.experience.attachments.map(
              (a) => AttachmentItem(attachment: a, compact: false),
            ),
          ],

          const SizedBox(height: 28),

          // ── Botones ──────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: '📄 Exportar a PDF',
                  icon: Icons.picture_as_pdf_outlined,
                  onPressed: _exportDetail,
                  isLoading: _exportingPdf,
                  height: 46,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Volver'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    side: const BorderSide(
                        color: AppTheme.primaryBlue, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: AppTheme.primaryBlue),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textGray,
                    fontWeight: FontWeight.w500)),
            Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
