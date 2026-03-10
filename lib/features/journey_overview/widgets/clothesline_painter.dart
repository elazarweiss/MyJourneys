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

  // Continuous pregnancy gradient: sage → blush → honey
  static const _gradientColors = [
    Color(0xFF90C48A), // soft sage (early)
    Color(0xFFB8A0C0), // lavender-blush (mid)
    Color(0xFFCF9850), // warm honey (late)
  ];
  static const _gradientStops = [0.0, 0.45, 1.0];

  @override
  void paint(Canvas canvas, Size size) {
    _drawBands(canvas, size);
    // Line is drawn as a fixed widget — not here
    _drawDots(canvas);
    _drawCurrentWeek(canvas);
  }

  void _drawBands(Canvas canvas, Size size) {
    // Very faint continuous background tint across full timeline
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      bgRect,
      Paint()
        ..shader = LinearGradient(
          colors: _gradientColors
              .map((c) => c.withOpacity(0.06))
              .toList(),
          stops: _gradientStops,
        ).createShader(bgRect),
    );

    // Thin accent strip directly below the wire (10px)
    final stripRect = Rect.fromLTRB(0, lineY + 1, size.width, lineY + 11);
    canvas.drawRect(
      stripRect,
      Paint()
        ..shader = LinearGradient(
          colors: _gradientColors
              .map((c) => c.withOpacity(0.50))
              .toList(),
          stops: _gradientStops,
        ).createShader(stripRect),
    );
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

  void _drawDots(Canvas canvas) {
    for (int week = 1; week <= totalWeeks; week++) {
      if (week == currentWeek) continue;
      final double x = TimelineUtils.xForWeek(week, weekSpacing);
      final bool isPast = week < currentWeek;
      canvas.drawCircle(
        Offset(x, lineY),
        5.0,
        Paint()
          ..color = isPast
              ? const Color(0xFF3A3A3A).withOpacity(0.60)
              : const Color(0xFF3A3A3A).withOpacity(0.28),
      );
    }
  }

  void _drawCurrentWeek(Canvas canvas) {
    final double x = TimelineUtils.xForWeek(currentWeek, weekSpacing);
    canvas.drawCircle(
      Offset(x, lineY), 20,
      Paint()..color = AppColors.softGold.withOpacity(0.22),
    );
    canvas.drawCircle(
      Offset(x, lineY), 13,
      Paint()..color = AppColors.softGold,
    );
    _drawText(
      canvas,
      '$currentWeek',
      Offset(x, lineY),
      const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
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
