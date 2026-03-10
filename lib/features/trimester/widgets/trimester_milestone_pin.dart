import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/models/milestone_model.dart';
import '../../../core/utils/timeline_utils.dart';

class TrimesterMilestonePin extends StatelessWidget {
  final Milestone milestone;
  final int startWeek;
  final double weekSpacing;
  final double canvasHeight;
  final double amplitude;
  final VoidCallback onTap;

  const TrimesterMilestonePin({
    super.key,
    required this.milestone,
    required this.startWeek,
    required this.weekSpacing,
    required this.canvasHeight,
    required this.amplitude,
    required this.onTap,
  });

  static const int _totalWeeks = 40;
  static const double _approxLabelH = 46.0;
  static const double _labelW = 80.0;

  double _dotR(bool isCurrent, bool isMilestone, bool isPast) {
    if (isCurrent) return 11.0;
    if (isMilestone) return isPast ? 8.0 : 7.0;
    return 5.0;
  }

  @override
  Widget build(BuildContext context) {
    final double centerY = canvasHeight / 2;
    final double x =
        (milestone.week - startWeek) * weekSpacing + weekSpacing / 2;
    final double waveY = TimelineUtils.yForWeek(
      milestone.week,
      centerY,
      amplitude,
      _totalWeeks,
    );
    final double dotR = _dotR(false, true, milestone.reached);
    final double top = waveY - dotR - 8.0 - _approxLabelH;

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
