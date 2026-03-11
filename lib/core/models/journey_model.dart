import 'milestone_model.dart';

class Journey {
  final String name;
  final DateTime dueDate;
  final int totalWeeks;
  final List<Milestone> milestones;

  const Journey({
    required this.name,
    required this.dueDate,
    this.totalWeeks = 40,
    this.milestones = const [],
  });

  /// Computes the current week number from the due date.
  /// Conception is assumed to be 280 days before the due date.
  int get currentWeek {
    final conceptionDate = dueDate.subtract(const Duration(days: 280));
    final daysSinceConception = DateTime.now().difference(conceptionDate).inDays;
    return (daysSinceConception / 7).ceil().clamp(1, totalWeeks);
  }

  String get trimesterLabel {
    final w = currentWeek;
    if (w <= 12) return 'First Trimester';
    if (w <= 26) return 'Second Trimester';
    return 'Third Trimester';
  }

  Milestone? milestoneForWeek(int week) {
    try {
      return milestones.firstWhere((m) => m.week == week);
    } catch (_) {
      return null;
    }
  }
}
