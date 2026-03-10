import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/milestone_model.dart';
import '../../../core/utils/timeline_utils.dart';

class TimelinePainter extends CustomPainter {
  final int currentWeek;
  final int totalWeeks;
  final double weekSpacing;
  final List<Milestone> milestones;
  final double amplitude;

  TimelinePainter({
    required this.currentWeek,
    required this.totalWeeks,
    required this.weekSpacing,
    required this.milestones,
    this.amplitude = 28,
  });

  double _waveX(double week) => (week - 1) * weekSpacing + weekSpacing / 2;

  double _waveY(double week, double centerY) {
    final double t = (week - 1) / (totalWeeks - 1);
    return centerY + amplitude * math.sin(t * 4 * math.pi);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double centerY = size.height / 2;
    _drawWave(canvas, centerY);
    _drawDots(canvas, centerY);
  }

  void _drawWave(Canvas canvas, double centerY) {
    const int samplesPerWeek = 14;
    final int totalSamples = (totalWeeks - 1) * samplesPerWeek;

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

    // Reached portion — solid
    final Path reached = Path();
    bool started = false;
    for (int i = 0; i <= totalSamples; i++) {
      final double week = 1.0 + i / samplesPerWeek;
      if (week > currentWeek + 0.02) break;
      final Offset pt = Offset(_waveX(week), _waveY(week, centerY));
      if (!started) {
        reached.moveTo(pt.dx, pt.dy);
        started = true;
      } else {
        reached.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(reached, reachedPaint);

    // Future portion — dashed
    Offset? prev;
    int dash = 0;
    for (int i = 0; i <= totalSamples; i++) {
      final double week = 1.0 + i / samplesPerWeek;
      if (week < currentWeek - 0.02) continue;
      final Offset pt = Offset(_waveX(week), _waveY(week, centerY));
      if (prev != null && dash % 5 < 3) {
        canvas.drawLine(prev, pt, futurePaint);
      }
      prev = pt;
      dash++;
    }
  }

  void _drawDots(Canvas canvas, double centerY) {
    for (final m in milestones) {
      final double x = TimelineUtils.xForWeek(m.week, weekSpacing);
      final double y = TimelineUtils.yForWeek(m.week, centerY, amplitude, totalWeeks);
      final bool isCurrent = m.week == currentWeek;
      final bool reached = m.week <= currentWeek;

      if (isCurrent) {
        // Soft glow
        canvas.drawCircle(
          Offset(x, y),
          20,
          Paint()..color = AppColors.softGold.withValues(alpha: 0.18),
        );
        // Gold fill
        canvas.drawCircle(Offset(x, y), 11, Paint()..color = AppColors.softGold);
        // Week number
        final tp = TextPainter(
          text: TextSpan(
            text: '${m.week}',
            style: const TextStyle(
              fontSize: 9,
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
          6,
          Paint()..color = reached ? AppColors.warmTaupe : AppColors.sageMuted,
        );
        if (reached) {
          canvas.drawCircle(Offset(x, y), 2.5, Paint()..color = Colors.white);
        }
      }
    }
  }

  @override
  bool shouldRepaint(TimelinePainter old) =>
      old.currentWeek != currentWeek || old.weekSpacing != weekSpacing;
}
