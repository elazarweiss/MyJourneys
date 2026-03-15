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

  // Continuous pregnancy gradient: sage → lavender → honey
  static const _gradientColors = [
    Color(0xFF90C48A), // soft sage (early)
    Color(0xFFB8A0C0), // lavender-blush (mid)
    Color(0xFFCF9850), // warm honey (late)
  ];
  static const _gradientStops = [0.0, 0.45, 1.0];

  @override
  void paint(Canvas canvas, Size size) {
    _drawBands(canvas, size);
    _drawWire(canvas, size);
    _drawTicks(canvas);
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

  void _drawWire(Canvas canvas, Size size) {
    final double currentX = TimelineUtils.xForWeek(currentWeek, weekSpacing);
    final double endX = TimelineUtils.xForWeek(totalWeeks, weekSpacing) + weekSpacing / 2;

    // Past wire — solid, warmBrown 65%
    canvas.drawLine(
      Offset(0, lineY),
      Offset(currentX, lineY),
      Paint()
        ..color = AppColors.warmBrown.withOpacity(0.65)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Future wire — dashed, warmBrown 30%
    final futurePath = Path()..moveTo(currentX, lineY);
    futurePath.lineTo(endX, lineY);

    final pm = futurePath.computeMetrics().first;
    double dist = 0;
    bool draw = true;
    while (dist < pm.length) {
      const dashLen = 8.0;
      const gapLen = 5.0;
      final step = draw ? dashLen : gapLen;
      if (draw) {
        canvas.drawPath(
          pm.extractPath(dist, dist + step),
          Paint()
            ..color = AppColors.warmBrown.withOpacity(0.30)
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
        );
      }
      dist += step;
      draw = !draw;
    }
  }

  void _drawTicks(Canvas canvas) {
    for (int week = 1; week <= totalWeeks; week++) {
      final double x = TimelineUtils.xForWeek(week, weekSpacing);
      final bool isMajor = week % 4 == 0;
      final double tickH = isMajor ? 8.0 : 4.0;
      final double opacity = isMajor ? 0.30 : 0.12;

      canvas.drawLine(
        Offset(x, lineY),
        Offset(x, lineY + tickH),
        Paint()
          ..color = AppColors.warmBrown.withOpacity(opacity)
          ..strokeWidth = 1.0
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawCurrentWeek(Canvas canvas) {
    final double x = TimelineUtils.xForWeek(currentWeek, weekSpacing);
    // Outer glow ring
    canvas.drawCircle(
      Offset(x, lineY), 22,
      Paint()..color = AppColors.softGold.withOpacity(0.18),
    );
    // Inner filled circle
    canvas.drawCircle(
      Offset(x, lineY), 14,
      Paint()..color = AppColors.softGold,
    );
    _drawText(
      canvas,
      '$currentWeek',
      Offset(x, lineY),
      const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
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
