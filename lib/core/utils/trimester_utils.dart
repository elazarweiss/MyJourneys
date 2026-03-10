abstract final class TrimesterUtils {
  static const List<(int, int, String)> trimesters = [
    (1, 12, 'First Trimester'),
    (13, 26, 'Second Trimester'),
    (27, 40, 'Third Trimester'),
  ];

  static int trimesterForWeek(int week) => week <= 12 ? 1 : week <= 26 ? 2 : 3;
  static String labelForTrimester(int n) => trimesters[n - 1].$3;
  static int startWeek(int n) => trimesters[n - 1].$1;
  static int endWeek(int n) => trimesters[n - 1].$2;
}
