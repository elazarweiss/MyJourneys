import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/timeline_utils.dart';

class TrimesterLabel extends StatelessWidget {
  final String label;
  final int startWeek;
  final double weekSpacing;
  final double top;
  final VoidCallback? onTap;

  const TrimesterLabel({
    super.key,
    required this.label,
    required this.startWeek,
    required this.weekSpacing,
    required this.top,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double x = TimelineUtils.xForWeek(startWeek, weekSpacing);
    return Positioned(
      left: x,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.sageGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label.toUpperCase(),
            style: AppTypography.label.copyWith(
              color: AppColors.sageGreen,
              fontSize: 9,
            ),
          ),
        ),
      ),
    );
  }
}
