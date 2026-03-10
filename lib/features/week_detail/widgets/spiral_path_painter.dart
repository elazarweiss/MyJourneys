import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/milestone_model.dart';

/// Positions milestones proportionally across a fixed width (no scrolling).
abstract final class MiniTimelineUtils {
  static double xForWeek(int week, double totalWidth, int totalWeeks) {
    return (week / totalWeeks) * totalWidth;
  }

  static double yForWeek(
    int week,
    double centerY,
    double amplitude,
    int totalWeeks,
  ) {
    final double t = (week - 1) / (totalWeeks - 1);
    return centerY + amplitude * math.sin(t * 4 * math.pi);
  }
}

class MiniTimelinePainter extends CustomPainter {
  final int currentWeek;
  final int totalWeeks;
  final List<Milestone> milestones;
  final double amplitude;

  const MiniTimelinePainter({
    required this.currentWeek,
    required this.totalWeeks,
    required this.milestones,
    this.amplitude = 20,
  });

  double _x(double week, double w) =>
      (week / totalWeeks) * w;

  double _y(double week, double centerY) {
    final double t = (week - 1) / (totalWeeks - 1);
    return centerY + amplitude * math.sin(t * 4 * math.pi);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double centerY = size.height / 2;
    _drawWave(canvas, size, centerY);
    _drawDots(canvas, size, centerY);
  }

  void _drawWave(Canvas canvas, Size size, double centerY) {
    const int steps = 400;

    final Paint reachedPaint = Paint()
      ..color = AppColors.sageGreen
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint futurePaint = Paint()
      ..color = AppColors.sageMuted
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path reachedPath = Path();
    bool started = false;
    for (int i = 0; i <= steps; i++) {
      final double week = 1.0 + (i / steps) * (totalWeeks - 1);
      if (week > currentWeek + 0.02) break;
      final Offset pt = Offset(_x(week, size.width), _y(week, centerY));
      if (!started) {
        reachedPath.moveTo(pt.dx, pt.dy);
        started = true;
      } else {
        reachedPath.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(reachedPath, reachedPaint);

    Offset? prev;
    int dash = 0;
    for (int i = 0; i <= steps; i++) {
      final double week = 1.0 + (i / steps) * (totalWeeks - 1);
      if (week < currentWeek - 0.02) continue;
      final Offset pt = Offset(_x(week, size.width), _y(week, centerY));
      if (prev != null && dash % 5 < 3) {
        canvas.drawLine(prev, pt, futurePaint);
      }
      prev = pt;
      dash++;
    }
  }

  void _drawDots(Canvas canvas, Size size, double centerY) {
    for (final m in milestones) {
      final double x = MiniTimelineUtils.xForWeek(m.week, size.width, totalWeeks);
      final double y = MiniTimelineUtils.yForWeek(m.week, centerY, amplitude, totalWeeks);
      final bool isCurrent = m.week == currentWeek;
      final bool reached = m.week <= currentWeek;

      if (isCurrent) {
        canvas.drawCircle(
          Offset(x, y),
          15,
          Paint()..color = AppColors.softGold.withValues(alpha: 0.2),
        );
        canvas.drawCircle(Offset(x, y), 9, Paint()..color = AppColors.softGold);
        final tp = TextPainter(
          text: TextSpan(
            text: '${m.week}',
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
      } else {
        canvas.drawCircle(
          Offset(x, y),
          5,
          Paint()..color = reached ? AppColors.warmTaupe : AppColors.sageMuted,
        );
        if (reached) {
          canvas.drawCircle(Offset(x, y), 2, Paint()..color = Colors.white);
        }
      }
    }
  }

  @override
  bool shouldRepaint(MiniTimelinePainter old) =>
      old.currentWeek != currentWeek;
}
