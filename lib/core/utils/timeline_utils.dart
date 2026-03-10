import 'dart:math' as math;

abstract final class TimelineUtils {
  static double xForWeek(int week, double weekSpacing) {
    return (week - 1) * weekSpacing + weekSpacing / 2;
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
