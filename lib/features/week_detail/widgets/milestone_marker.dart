import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/models/milestone_model.dart';
import 'spiral_path_painter.dart';

/// Floating label above/below a milestone dot on the mini timeline.
class MilestoneMarker extends StatelessWidget {
  final Milestone milestone;
  final int index;
  final double canvasHeight;
  final double canvasWidth;
  final double amplitude;
  final int totalWeeks;

  const MilestoneMarker({
    super.key,
    required this.milestone,
    required this.index,
    required this.canvasHeight,
    required this.canvasWidth,
    required this.amplitude,
    required this.totalWeeks,
  });

  bool get _isAbove => index.isEven;

  static const double _dotR = 5.0;
  static const double _stemH = 16.0;
  static const double _labelW = 80.0;
  static const double _approxLabelH = 44.0;

  @override
  Widget build(BuildContext context) {
    final double centerY = canvasHeight / 2;
    final double x =
        MiniTimelineUtils.xForWeek(milestone.week, canvasWidth, totalWeeks);
    final double waveY =
        MiniTimelineUtils.yForWeek(milestone.week, centerY, amplitude, totalWeeks);

    // Skip current week — it's handled by the gold dot painter
    if (milestone.week ==
        milestone.week) {
      // always render (we skip current in the screen's filter)
    }

    final double top = _isAbove
        ? waveY - _dotR - _stemH - _approxLabelH
        : waveY + _dotR;

    // Keep label within canvas bounds
    final double left = (x - _labelW / 2).clamp(4.0, canvasWidth - _labelW - 4);

    return Positioned(
      left: left,
      top: top,
      child: SizedBox(
        width: _labelW,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _isAbove
              ? [_buildLabel(), _buildStem()]
              : [_buildStem(), _buildLabel()],
        ),
      ),
    );
  }

  Widget _buildLabel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(milestone.emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(
          milestone.label,
          style: AppTypography.label.copyWith(
            color: milestone.reached ? AppColors.warmBrown : AppColors.sageMuted,
            fontSize: 9,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildStem() {
    return Center(
      child: Container(
        width: 1.5,
        height: _stemH,
        color: AppColors.warmTaupe.withValues(alpha: 0.3),
      ),
    );
  }
}
