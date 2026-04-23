import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/experience_model.dart';
import '../providers/auth_provider.dart';
import '../providers/experience_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../utils/pdf_generator.dart';
import '../widgets/experience_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/stats_card.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/gradient_button.dart';
import 'add_experience_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _stats;
  bool _statsLoading = true;
  bool _exportingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats =
        await context.read<ExperienceProvider>().getStats();
    if (mounted) setState(() { _stats = stats; _statsLoading = false; });
  }

  Future<void> _pickDateRange() async {
    final provider = context.read<ExperienceProvider>();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: provider.startDate != null && provider.endDate != null
          ? DateTimeRange(
              start: provider.startDate!, end: provider.endDate!)
          : null,
      locale: const Locale('es'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppTheme.primaryBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      provider.setDateRange(picked.start, picked.end);
    }
  }

  Future<void> _exportPdf(List<ExperienceModel> experiences) async {
    if (experiences.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay experiencias para exportar'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }
    setState(() => _exportingPdf = true);
    try {
      await PdfGenerator.generateReport(experiences);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e'),
              backgroundColor: AppTheme.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _exportingPdf = false);
    }
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue),
            child: const Text('Cerrar sesión',
                style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider  = context.watch<ThemeProvider>();
    final authProvider   = context.watch<AuthProvider>();
    final expProvider    = context.watch<ExperienceProvider>();
    final user           = authProvider.userModel;
    final screenWidth    = MediaQuery.of(context).size.width;
    final isMobile       = screenWidth < 768;
    final isTablet       = screenWidth >= 768 && screenWidth < 1100;
    final isDark         = themeProvider.isDark;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar personalizado ──────────────────
              _buildAppBar(context, user, themeProvider, isDark, isMobile),
              // ── Contenido scrollable ──────────────────
              Expanded(
                child: StreamBuilder<List<ExperienceModel>>(
                  stream: expProvider.experiencesStream,
                  builder: (context, snapshot) {
                    final allExp = snapshot.data ?? [];
                    final filtered = expProvider.filteredExperiences(allExp);

                    return CustomScrollView(
                      slivers: [
                        // Stats
                        SliverToBoxAdapter(
                          child: _buildStats(isMobile, isTablet),
                        ),
                        // Barra de filtros + botones
                        SliverToBoxAdapter(
                          child: _buildToolbar(
                              context, filtered, isMobile, expProvider),
                        ),
                        // Grid / Lista
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 16 : 32,
                            vertical: 12,
                          ),
                          sliver: _buildContent(
                              context, snapshot, filtered, isMobile),
                        ),
                        // Botón "Cargar más"
                        if (expProvider.hasMore && filtered.isNotEmpty)
                          SliverToBoxAdapter(
                            child: _buildLoadMoreButton(
                                context, allExp, expProvider),
                          ),
                        const SliverToBoxAdapter(
                            child: SizedBox(height: 40)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToAdd(context),
              backgroundColor: AppTheme.primaryBlue,
              icon: const Icon(Icons.add, color: AppTheme.white),
              label: const Text('Nueva',
                  style: TextStyle(
                      color: AppTheme.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildAppBar(
      BuildContext context,
      userModel,
      ThemeProvider themeProvider,
      bool isDark,
      bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 32, vertical: 14),
      child: Row(
        children: [
          // Ícono + título
          const Icon(Icons.hub_outlined, color: AppTheme.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isMobile ? 'Blockchain Exp.' : 'Blockchain en la Empresa',
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Toggle modo oscuro
          IconButton(
            onPressed: themeProvider.toggle,
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: AppTheme.white,
            ),
            tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
          ),
          const SizedBox(width: 8),
          // Avatar + info usuario
          if (userModel != null)
            GestureDetector(
              onTap: _showLogoutDialog,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    child: Text(
                      userModel.initials,
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userModel.name,
                            style: const TextStyle(
                                color: AppTheme.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        Text(userModel.company,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha:0.75),
                                fontSize: 11)),
                      ],
                    ),
                    IconButton(
                      onPressed: _showLogoutDialog,
                      icon: const Icon(Icons.logout,
                          color: AppTheme.white, size: 20),
                      tooltip: 'Cerrar sesión',
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStats(bool isMobile, bool isTablet) {
    if (_statsLoading) {
      return Container(
        height: 90,
        margin: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 32, vertical: 8),
        child: const Center(child: CircularProgressIndicator(color: AppTheme.white)),
      );
    }

    final stats = _stats!;
    final cards = [
      StatsCard(
        title: 'Experiencias',
        value: '${stats['total']}',
        icon: Icons.library_books_outlined,
        color: AppTheme.primaryBlue,
      ),
      StatsCard(
        title: 'Empresas distintas',
        value: '${stats['companies']}',
        icon: Icons.business_outlined,
        color: AppTheme.primaryViolet,
      ),
      StatsCard(
        title: 'Industria principal',
        value: stats['topIndustry'].isEmpty ? '-' : stats['topIndustry'],
        icon: Icons.category_outlined,
        color: const Color(0xFF0D9488),
      ),
      StatsCard(
        title: 'PDFs adjuntos',
        value: '${stats['totalPdfs']}',
        icon: Icons.attach_file,
        color: const Color(0xFFF59E0B),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 32, vertical: 8),
      child: isMobile
          ? GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.8,
              children: cards,
            )
          : GridView.count(
              crossAxisCount: isTablet ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: isTablet ? 2.5 : 2.8,
              children: cards,
            ),
    );
  }

  Widget _buildToolbar(BuildContext context, List<ExperienceModel> filtered,
      bool isMobile, ExperienceProvider expProvider) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 32, vertical: 10),
      child: Column(
        children: [
          // Barra de búsqueda/filtros
          SearchFilterBar(
            searchValue: expProvider.searchQuery,
            industryValue: expProvider.industryFilter,
            startDate: expProvider.startDate,
            endDate: expProvider.endDate,
            onSearchChanged: expProvider.setSearchQuery,
            onIndustryChanged: expProvider.setIndustryFilter,
            onDateRangePick: _pickDateRange,
            onClearFilters: expProvider.clearFilters,
          ),
          const SizedBox(height: 12),
          if (!isMobile)
            Row(
              children: [
                GradientButton(
                  label: '➕ Registrar Nueva Experiencia',
                  onPressed: () => _navigateToAdd(context),
                  height: 44,
                  fontSize: 13,
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _exportingPdf
                      ? null
                      : () => _exportPdf(filtered),
                  icon: _exportingPdf
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primaryBlue))
                      : const Icon(Icons.picture_as_pdf_outlined, size: 16),
                  label: const Text('📄 Exportar Reporte'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.white,
                    side: const BorderSide(color: AppTheme.white),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      AsyncSnapshot<List<ExperienceModel>> snapshot,
      List<ExperienceModel> filtered,
      bool isMobile) {
    if (snapshot.hasError) {
      return SliverToBoxAdapter(child: _errorWidget(snapshot.error.toString()));
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return SliverToBoxAdapter(
          child: LoadingShimmer(isMobile: isMobile, count: isMobile ? 3 : 4));
    }

    if (filtered.isEmpty) {
      return SliverToBoxAdapter(child: _emptyWidget(context));
    }

    if (isMobile) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ExperienceCard(experience: filtered[i]),
          ),
          childCount: filtered.length,
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.82,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, i) => ExperienceCard(experience: filtered[i]),
        childCount: filtered.length,
      ),
    );
  }

  Widget _buildLoadMoreButton(BuildContext context,
      List<ExperienceModel> currentList, ExperienceProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: provider.isLoadingMore
            ? const CircularProgressIndicator(color: AppTheme.white)
            : TextButton.icon(
                onPressed: () => provider.loadMore(currentList),
                icon: const Icon(Icons.expand_more, color: AppTheme.white),
                label: const Text('Cargar más',
                    style: TextStyle(color: AppTheme.white, fontSize: 15)),
              ),
      ),
    );
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddExperienceScreen()),
    ).then((_) => _loadStats());
  }

  Widget _emptyWidget(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined,
                size: 64, color: Colors.white.withValues(alpha:0.7)),
            const SizedBox(height: 16),
            Text(
              'Sin resultados',
              style: TextStyle(
                  color: Colors.white.withValues(alpha:0.9),
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'No se encontraron experiencias con los filtros actuales.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withValues(alpha:0.7), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorWidget(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.white, size: 48),
            const SizedBox(height: 12),
            const Text('Error al cargar datos',
                style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(error,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withValues(alpha:0.8), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
