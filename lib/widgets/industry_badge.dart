import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class IndustryBadge extends StatelessWidget {
  final String industry;
  final double fontSize;

  const IndustryBadge({
    super.key,
    required this.industry,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: AppTheme.badgeGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        industry,
        style: TextStyle(
          color: AppTheme.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
