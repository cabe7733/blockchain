import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class ExperienceLineChart extends StatefulWidget {
  final Map<String, int> data;

  const ExperienceLineChart({super.key, required this.data});

  @override
  State<ExperienceLineChart> createState() => _ExperienceLineChartState();
}

class _ExperienceLineChartState extends State<ExperienceLineChart> {
  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entries = widget.data.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value.toDouble());
    }).toList();

    final maxY = widget.data.values.reduce((a, b) => a > b ? a : b).toDouble();
    final maxX = (entries.length - 1).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryViolet.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.trending_up_rounded, 
                  color: AppTheme.primaryViolet, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Tendencia de Crecimiento',
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  color: AppTheme.textDark,
                )),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: maxX,
                minY: 0,
                maxY: maxY + 2,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.primaryDark,
                    tooltipPadding: const EdgeInsets.all(10),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final month = entries[spot.x.toInt()].key;
                        return LineTooltipItem(
                          '$month\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: '${spot.y.toInt()} registros',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < entries.length) {
                          final parts = entries[value.toInt()].key.split('-');
                          final month = _getMonthName(parts[1]);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              month,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppColors.darkTextSecondary : AppTheme.textGray,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryViolet,
                        Color(0xFF06B6D4),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeWidth: 3,
                          strokeColor: AppTheme.primaryViolet,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryViolet.withValues(alpha: 0.3),
                          const Color(0xFF06B6D4).withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(String month) {
    final months = {
      '01': 'Ene', '02': 'Feb', '03': 'Mar', '04': 'Abr',
      '05': 'May', '06': 'Jun', '07': 'Jul', '08': 'Ago',
      '09': 'Sep', '10': 'Oct', '11': 'Nov', '12': 'Dic',
    };
    return months[month] ?? month;
  }
}