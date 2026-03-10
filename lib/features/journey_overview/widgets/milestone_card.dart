import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/models/milestone_model.dart';
import '../../../core/utils/timeline_utils.dart';

class MilestonePin extends StatelessWidget {
  final Milestone milestone;
  final double weekSpacing;
  final double canvasHeight;
  final double amplitude;
  final int totalWeeks;
  final VoidCallback onTap;

  const MilestonePin({
    super.key,
    required this.milestone,
    required this.weekSpacing,
    required this.canvasHeight,
    required this.amplitude,
    required this.totalWeeks,
    required this.onTap,
  });

  static const double _dotR = 6.0;
  static const double _labelW = 84.0;
  static const double _approxLabelH = 46.0;

  @override
  Widget build(BuildContext context) {
    final double centerY = canvasHeight / 2;
    final double x = TimelineUtils.xForWeek(milestone.week, weekSpacing);
    final double waveY =
        TimelineUtils.yForWeek(milestone.week, centerY, amplitude, totalWeeks);

    final double top = waveY - _dotR - 8.0 - _approxLabelH;

    return Positioned(
      left: x - _labelW / 2,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: _labelW,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(milestone.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 3),
              Text(
                milestone.label,
                style: AppTypography.label.copyWith(
                  color: milestone.reached
                      ? AppColors.warmBrown
                      : AppColors.sageMuted,
                  letterSpacing: 0.3,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
