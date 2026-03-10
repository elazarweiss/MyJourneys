import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/timeline_utils.dart';

class ClotheslinePainter extends CustomPainter {
  final int currentWeek;
  final int totalWeeks;
  final double weekSpacing;
  final double lineY;

  const ClotheslinePainter({
    required this.currentWeek,
    required this.totalWeeks,
    required this.weekSpacing,
    required this.lineY,
  });

  // Trimester gradient end-points (left → right = lighter → darker)
  static const _t1Light = Color(0xFFD4EDD4);
  static const _t1Dark  = Color(0xFF7A9E7A);
  static const _t2Light = Color(0xFFF5E8D0);
  static const _t2Dark  = Color(0xFFC8973C);
  static const _t3Light = Color(0xFFEDD8C0);
  static const _t3Dark  = Color(0xFF9E7040);

  @override
  void paint(Canvas canvas, Size size) {
    _drawBands(canvas, size);
    _drawLine(canvas);
    _drawTicks(canvas);
    _drawCurrentWeek(canvas);
  }

  void _drawBands(Canvas canvas, Size size) {
    final bands = [
      (1,  12, _t1Light, _t1Dark),
      (13, 26, _t2Light, _t2Dark),
      (27, totalWeeks, _t3Light, _t3Dark),
    ];
    for (final (start, end, light, dark) in bands) {
      final x1 = TimelineUtils.xForWeek(start, weekSpacing) - weekSpacing / 2;
      final x2 = TimelineUtils.xForWeek(end, weekSpacing) + weekSpacing / 2;
      // Subtle band only below the line — keeps icon zone clean
      final rect = Rect.fromLTRB(x1, lineY, x2, size.height);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            colors: [light.withOpacity(0.20), dark.withOpacity(0.38)],
          ).createShader(rect),
      );
      // Very faint tint above line too, for trimester separation
      final topRect = Rect.fromLTRB(x1, 0, x2, lineY);
      canvas.drawRect(
        topRect,
        Paint()..color = light.withOpacity(0.06),
      );
    }
  }

  void _drawLine(Canvas canvas) {
    final double currentX = TimelineUtils.xForWeek(currentWeek, weekSpacing);
    final double endX = TimelineUtils.xForWeek(totalWeeks, weekSpacing) + weekSpacing / 2;

    // Reached — solid wire
    canvas.drawLine(
      Offset(0, lineY),
      Offset(currentX, lineY),
      Paint()
        ..color = AppColors.warmBrown.withOpacity(0.65)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    // Future — dashed
    double x = currentX;
    bool draw = true;
    while (x < endX) {
      final step = draw ? 7.0 : 4.0;
      final segEnd = (x + step).clamp(0.0, endX);
      if (draw) {
        canvas.drawLine(
          Offset(x, lineY),
          Offset(segEnd, lineY),
          Paint()
            ..color = AppColors.warmBrown.withOpacity(0.22)
            ..strokeWidth = 1.5
            ..strokeCap = StrokeCap.round,
        );
      }
      x = segEnd;
      draw = !draw;
    }
  }

  void _drawTicks(Canvas canvas) {
    for (int week = 1; week <= totalWeeks; week++) {
      if (week == currentWeek) continue;
      final double x = TimelineUtils.xForWeek(week, weekSpacing);
      final bool isPast = week < currentWeek;
      final Color color = isPast
          ? AppColors.warmBrown.withOpacity(0.38)
          : AppColors.warmBrown.withOpacity(0.16);

      canvas.drawLine(
        Offset(x, lineY - 4),
        Offset(x, lineY + 4),
        Paint()..color = color..strokeWidth = 1.0,
      );

      // Week number — odd above, even below
      _drawText(
        canvas,
        '$week',
        Offset(x, week.isOdd ? lineY - 14 : lineY + 7),
        TextStyle(
          fontSize: 7,
          color: isPast
              ? AppColors.warmBrown.withOpacity(0.48)
              : AppColors.warmBrown.withOpacity(0.20),
        ),
      );
    }
  }

  void _drawCurrentWeek(Canvas canvas) {
    final double x = TimelineUtils.xForWeek(currentWeek, weekSpacing);
    canvas.drawCircle(
      Offset(x, lineY), 16,
      Paint()..color = AppColors.softGold.withOpacity(0.22),
    );
    canvas.drawCircle(
      Offset(x, lineY), 10,
      Paint()..color = AppColors.softGold,
    );
    _drawText(
      canvas,
      '$currentWeek',
      Offset(x, lineY),
      const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white),
      center: true,
    );
  }

  void _drawText(Canvas canvas, String text, Offset anchor, TextStyle style,
      {bool center = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      center
          ? Offset(anchor.dx - tp.width / 2, anchor.dy - tp.height / 2)
          : Offset(anchor.dx - tp.width / 2, anchor.dy),
    );
  }

  @override
  bool shouldRepaint(ClotheslinePainter old) =>
      old.currentWeek != currentWeek || old.weekSpacing != weekSpacing;
}
