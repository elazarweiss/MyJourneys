import 'milestone_model.dart';
import 'week_entry_model.dart';

class Journey {
  final String name;
  final int currentWeek;
  final int totalWeeks;
  final DateTime dueDate;
  final List<Milestone> milestones;
  final List<WeekEntry> entries;

  const Journey({
    required this.name,
    required this.currentWeek,
    required this.totalWeeks,
    required this.dueDate,
    required this.milestones,
    required this.entries,
  });

  String get trimesterLabel {
    if (currentWeek <= 12) return 'First Trimester';
    if (currentWeek <= 26) return 'Second Trimester';
    return 'Third Trimester';
  }

  WeekEntry? entryForWeek(int week) {
    try {
      return entries.firstWhere((e) => e.week == week);
    } catch (_) {
      return null;
    }
  }

  Milestone? milestoneForWeek(int week) {
    try {
      return milestones.firstWhere((m) => m.week == week);
    } catch (_) {
      return null;
    }
  }
}
