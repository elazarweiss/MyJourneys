import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/milestone_model.dart';
import '../../../core/utils/timeline_utils.dart';

class TrimesterTimelinePainter extends CustomPainter {
  final int startWeek;
  final int endWeek;
  final int currentWeek;
  final double weekSpacing;
  final double amplitude;
  final List<Milestone> milestones;

  TrimesterTimelinePainter({
    required this.startWeek,
    required this.endWeek,
    required this.currentWeek,
    required this.weekSpacing,
    required this.amplitude,
    required this.milestones,
  });

  static const int _totalWeeks = 40;

  double _localX(int week) =>
      (week - startWeek) * weekSpacing + weekSpacing / 2;

  double _waveY(int week, double centerY) =>
      TimelineUtils.yForWeek(week, centerY, amplitude, _totalWeeks);

  // fractional version for smooth wave sampling
  double _localXf(double week) =>
      (week - startWeek) * weekSpacing + weekSpacing / 2;

  double _waveYf(double week, double centerY) {
    final double t = (week - 1) / (_totalWeeks - 1);
    return centerY + amplitude * math.sin(t * 4 * math.pi);
  }

  Set<int> get _milestoneWeeks => milestones.map((m) => m.week).toSet();

  @override
  void paint(Canvas canvas, Size size) {
    final double centerY = size.height / 2;
    _drawWave(canvas, centerY);
    _drawDots(canvas, centerY);
    _drawWeekLabels(canvas, size, centerY);
  }

  void _drawWave(Canvas canvas, double centerY) {
    const int samplesPerWeek = 14;
    final int totalSamples = (endWeek - startWeek) * samplesPerWeek;

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

    // Reached — solid
    final Path reached = Path();
    bool started = false;
    for (int i = 0; i <= totalSamples; i++) {
      final double week = startWeek + i / samplesPerWeek.toDouble();
      if (week > currentWeek + 0.02) break;
      final Offset pt = Offset(_localXf(week), _waveYf(week, centerY));
      if (!started) {
        reached.moveTo(pt.dx, pt.dy);
        started = true;
      } else {
        reached.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(reached, reachedPaint);

    // Future — dashed
    Offset? prev;
    int dash = 0;
    for (int i = 0; i <= totalSamples; i++) {
      final double week = startWeek + i / samplesPerWeek.toDouble();
      if (week < currentWeek - 0.02) continue;
      final Offset pt = Offset(_localXf(week), _waveYf(week, centerY));
      if (prev != null && dash % 5 < 3) {
        canvas.drawLine(prev, pt, futurePaint);
      }
      prev = pt;
      dash++;
    }
  }

  void _drawDots(Canvas canvas, double centerY) {
    final milestoneWeeks = _milestoneWeeks;
    for (int week = startWeek; week <= endWeek; week++) {
      final double x = _localX(week);
      final double y = _waveY(week, centerY);
      final bool isCurrent = week == currentWeek;
      final bool isPast = week <= currentWeek;
      final bool isMilestone = milestoneWeeks.contains(week);

      if (isCurrent) {
        canvas.drawCircle(
          Offset(x, y),
          20,
          Paint()..color = AppColors.softGold.withValues(alpha: 0.18),
        );
        canvas.drawCircle(Offset(x, y), 11, Paint()..color = AppColors.softGold);
        final tp = TextPainter(
          text: TextSpan(
            text: '$week',
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
      } else if (isMilestone) {
        final double r = isPast ? 8.0 : 7.0;
        canvas.drawCircle(
          Offset(x, y),
          r,
          Paint()..color = isPast ? AppColors.warmTaupe : AppColors.sageMuted,
        );
        if (isPast) {
          canvas.drawCircle(Offset(x, y), 3.0, Paint()..color = Colors.white);
        }
      } else {
        canvas.drawCircle(
          Offset(x, y),
          5,
          Paint()..color = isPast ? AppColors.warmTaupe : AppColors.sageMuted,
        );
        if (isPast) {
          canvas.drawCircle(Offset(x, y), 2.0, Paint()..color = Colors.white);
        }
      }
    }
  }

  void _drawWeekLabels(Canvas canvas, Size size, double centerY) {
    for (int week = startWeek; week <= endWeek; week++) {
      if (week == currentWeek) continue; // current week already shows number inside dot
      final double x = _localX(week);
      final double y = _waveY(week, centerY);
      final bool isMilestone = _milestoneWeeks.contains(week);
      final double dotR = isMilestone ? (week <= currentWeek ? 8.0 : 7.0) : 5.0;

      final tp = TextPainter(
        text: TextSpan(
          text: '$week',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w500,
            color: week <= currentWeek
                ? AppColors.warmTaupe
                : AppColors.sageMuted.withValues(alpha: 0.7),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y + dotR + 3));
    }
  }

  @override
  bool shouldRepaint(TrimesterTimelinePainter old) =>
      old.currentWeek != currentWeek ||
      old.weekSpacing != weekSpacing ||
      old.startWeek != startWeek;
}
