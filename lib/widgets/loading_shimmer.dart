import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer skeleton con forma idéntica a la ExperienceCard real.
class LoadingShimmer extends StatelessWidget {
  final bool isMobile;
  final int count;

  const LoadingShimmer({super.key, this.isMobile = false, this.count = 4});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlight = isDark ? Colors.grey.shade600 : Colors.grey.shade100;

    if (isMobile) {
      return Column(
        children: List.generate(
            count < 3 ? count : 3, (_) => _buildCard(base, highlight)),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.85,
      ),
      itemCount: count,
      itemBuilder: (_, __) => _buildCard(base, highlight),
    );
  }

  Widget _buildCard(Color base, Color highlight) {
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // 👈 importante
          children: [
            Container(width: 180, height: 20, color: Colors.white),
            const SizedBox(height: 12),

            Container(
              width: 80,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            const SizedBox(height: 14),

            Container(width: double.infinity, height: 12, color: Colors.white),
            const SizedBox(height: 6),
            Container(width: double.infinity, height: 12, color: Colors.white),
            const SizedBox(height: 6),
            Container(width: 200, height: 12, color: Colors.white),

            const SizedBox(height: 14),

            Container(width: 100, height: 12, color: Colors.white),

            const SizedBox(height: 14),

            Container(width: 160, height: 12, color: Colors.white),

            const SizedBox(height: 20), // 👈 reemplazo del Spacer

            Container(
              width: double.infinity,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
