import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ExecutiveSummaryCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const ExecutiveSummaryCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats['total'] as int? ?? 0;
    final companies = stats['companies'] as int? ?? 0;
    final topIndustry = stats['topIndustry'] as String? ?? '';
    final industryDist = stats['industryDistribution'] as Map<String, int>? ?? {};
    final monthlyTrend = stats['monthlyTrend'] as Map<String, int>? ?? {};
    
    final insights = _generateInsights(total, companies, topIndustry, industryDist, monthlyTrend);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.primaryViolet],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              const Text('Resumen Ejecutivo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _generateInsights(int total, int companies, String topIndustry, 
      Map<String, int> industryDist, Map<String, int> monthlyTrend) {
    final insights = <String>[];

    if (total > 0) {
      insights.add('El repositorio cuenta con $total experiencias registradas.');
    }
    
    if (companies > 0) {
      insights.add('$companies empresas han compartido sus casos de éxito.');
    }
    
    if (topIndustry.isNotEmpty && industryDist.isNotEmpty) {
      final topCount = industryDist[topIndustry] ?? 0;
      final percentage = (topCount / total * 100).round();
      insights.add('El sector $topIndustry lidera con el $percentage% de las implementaciones.');
    }

    if (monthlyTrend.isNotEmpty) {
      final sortedMonths = monthlyTrend.keys.toList()..sort();
      if (sortedMonths.length >= 2) {
        final lastMonth = monthlyTrend[sortedMonths.last] ?? 0;
        final prevMonth = monthlyTrend[sortedMonths[sortedMonths.length - 2]] ?? 0;
        if (lastMonth > prevMonth) {
          final growth = ((lastMonth - prevMonth) / prevMonth * 100).round();
          insights.add('Crecimiento del $growth% respecto al mes anterior.');
        } else if (lastMonth < prevMonth) {
          final decrease = ((prevMonth - lastMonth) / prevMonth * 100).round();
          insights.add('Se registró una disminución del $decrease% comparado con el mes anterior.');
        }
      }
    }

    if (industryDist.length > 1) {
      insights.add('La diversidad sectorial cuenta con ${industryDist.length} industrias representadas.');
    }

    return insights;
  }
}