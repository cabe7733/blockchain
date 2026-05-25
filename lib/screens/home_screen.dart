import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/experience_model.dart';
import '../providers/auth_provider.dart';
import '../providers/experience_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../utils/pdf_generator.dart';
import '../widgets/experience_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/stats_card.dart';
import '../widgets/industry_bar_chart.dart';
import '../widgets/experience_line_chart.dart';
import '../widgets/executive_summary_card.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/gradient_button.dart';
import 'add_experience_screen.dart';
import '../widgets/copilot_chat_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _stats;
  bool _statsLoading = true;
  bool _exportingPdf = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final stats = await context.read<ExperienceProvider>().getStats();
    if (mounted) setState(() { _stats = stats; _statsLoading = false; });
  }

  Future<void> _pickDateRange() async {
    final provider = context.read<ExperienceProvider>();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: provider.startDate != null && provider.endDate != null
          ? DateTimeRange(start: provider.startDate!, end: provider.endDate!)
          : null,
      locale: const Locale('es'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primaryBlue),
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
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final expProvider = context.watch<ExperienceProvider>();
    final user = authProvider.userModel;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1100;
    final isDark = themeProvider.isDark;

    return Scaffold(
      endDrawer: const CopilotChatDrawer(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, user, themeProvider, isDark, isMobile),
              _buildTabBar(isMobile),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildExperiencesTab(expProvider, isMobile, isTablet),
                    _buildStatsTab(isMobile, isTablet),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Builder(
        builder: (ctx) {
          final isAiEnabled = expProvider.isAiEnabled;
          final showAddFab = isMobile && _tabController.index == 0;

          if (!isAiEnabled && !showAddFab) return const SizedBox();

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (showAddFab) ...[
                FloatingActionButton.extended(
                  heroTag: 'add_exp_fab',
                  onPressed: () => _navigateToAdd(context),
                  backgroundColor: AppTheme.primaryBlue,
                  icon: const Icon(Icons.add, color: AppTheme.white),
                  label: const Text('Nueva',
                      style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
              ],
              if (isAiEnabled)
                FloatingActionButton(
                  heroTag: 'copilot_fab',
                  onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                  backgroundColor: Colors.transparent,
                  elevation: 6,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      gradient: AppTheme.buttonGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, userModel, ThemeProvider themeProvider,
      bool isDark, bool isMobile) {
    final expProvider = context.watch<ExperienceProvider>();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: 14),
      child: Row(
        children: [
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
          if (expProvider.isAiEnabled) ...[
            Builder(
              builder: (ctx) => TextButton.icon(
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                icon: const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                label: const Text('Copilot', style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.white.withValues(alpha: 0.15),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          IconButton(
            onPressed: themeProvider.toggle,
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: AppTheme.white,
            ),
            tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
          ),
          const SizedBox(width: 8),
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
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 11)),
                      ],
                    ),
                    IconButton(
                      onPressed: _showLogoutDialog,
                      icon: const Icon(Icons.logout, color: AppTheme.white, size: 20),
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

  Widget _buildTabBar(bool isMobile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppTheme.primaryDark,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.library_books_outlined, 
                  size: 18, color: _tabController.index == 0 
                    ? AppTheme.primaryDark : Colors.white70),
                const SizedBox(width: 8),
                const Text('Experiencias'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined, 
                  size: 18, color: _tabController.index == 1 
                    ? AppTheme.primaryDark : Colors.white70),
                const SizedBox(width: 8),
                const Text('Estadísticas'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperiencesTab(ExperienceProvider expProvider, bool isMobile, bool isTablet) {
    return StreamBuilder<List<ExperienceModel>>(
      stream: expProvider.experiencesStream,
      builder: (context, snapshot) {
        final allExp = snapshot.data ?? [];
        final filtered = expProvider.filteredExperiences(allExp);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildToolbar(context, filtered, isMobile, expProvider),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: 12),
              sliver: _buildContent(context, snapshot, filtered, isMobile),
            ),
            if (expProvider.hasMore && filtered.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildLoadMoreButton(context, allExp, expProvider),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      },
    );
  }

  Widget _buildStatsTab(bool isMobile, bool isTablet) {
    if (_statsLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.white));
    }

    final industryData = _stats!['industryDistribution'] as Map<String, int>? ?? {};
    final monthlyData = _stats!['monthlyTrend'] as Map<String, int>? ?? {};

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(isMobile, isTablet),
          const SizedBox(height: 20),
          if (_stats != null) ExecutiveSummaryCard(stats: _stats!),
          const SizedBox(height: 20),
          if (industryData.isNotEmpty) IndustryBarChart(data: industryData),
          const SizedBox(height: 16),
          if (monthlyData.isNotEmpty) ExperienceLineChart(data: monthlyData),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isMobile, bool isTablet) {
    final stats = _stats!;
    final cards = [
      StatsCard(title: 'Total', value: '${stats['total']}', 
        icon: Icons.library_books, color: AppTheme.primaryBlue),
      StatsCard(title: 'Empresas', value: '${stats['companies']}', 
        icon: Icons.business, color: AppTheme.primaryViolet),
      StatsCard(title: 'Sector Líder', value: stats['topIndustry'].isEmpty ? '-' : stats['topIndustry'], 
        icon: Icons.category, color: const Color(0xFF0D9488)),
      StatsCard(title: 'PDFs', value: '${stats['totalPdfs']}', 
        icon: Icons.attach_file, color: const Color(0xFFF59E0B)),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cards.map((card) {
        return SizedBox(
          width: isMobile 
              ? (MediaQuery.of(context).size.width - 80) / 2
              : 150,
          child: card,
        );
      }).toList(),
    );
  }

  Widget _buildToolbar(BuildContext context, List<ExperienceModel> filtered,
      bool isMobile, ExperienceProvider expProvider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: 10),
      child: Column(
        children: [
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
                  onPressed: _exportingPdf ? null : () => _exportPdf(filtered),
                  icon: _exportingPdf
                      ? const SizedBox(width: 14, height: 14, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue))
                      : const Icon(Icons.picture_as_pdf_outlined, size: 16),
                  label: const Text('📄 Exportar Reporte'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.white,
                    side: const BorderSide(color: AppTheme.white),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AsyncSnapshot<List<ExperienceModel>> snapshot,
      List<ExperienceModel> filtered, bool isMobile) {
    if (snapshot.hasError) {
      return SliverToBoxAdapter(child: _errorWidget(snapshot.error.toString()));
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return SliverToBoxAdapter(child: LoadingShimmer(isMobile: isMobile, count: isMobile ? 3 : 4));
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

  Widget _buildLoadMoreButton(BuildContext context, List<ExperienceModel> currentList, ExperienceProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: provider.isLoadingMore
            ? const CircularProgressIndicator(color: AppTheme.white)
            : TextButton.icon(
                onPressed: () => provider.loadMore(currentList),
                icon: const Icon(Icons.expand_more, color: AppTheme.white),
                label: const Text('Cargar más', style: TextStyle(color: AppTheme.white, fontSize: 15)),
              ),
      ),
    );
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExperienceScreen()))
        .then((_) => _loadStats());
  }

  Widget _emptyWidget(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.white.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            Text('Sin resultados', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('No se encontraron experiencias con los filtros actuales.', textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
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
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.white, size: 48),
            const SizedBox(height: 12),
            const Text('Error al cargar datos', style: TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}