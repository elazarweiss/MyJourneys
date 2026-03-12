import 'package:hive_flutter/hive_flutter.dart';
import '../core/models/day_entry_model.dart';
import '../core/models/week_entry_model.dart';

class JourneyRepository {
  static final instance = JourneyRepository._();
  JourneyRepository._();

  late Box<WeekEntry> _weekEntries;
  late Box<DayEntry> _dayEntries;

  Future<void> init() async {
    _weekEntries = await Hive.openBox<WeekEntry>('weekEntries');
    _dayEntries = await Hive.openBox<DayEntry>('dayEntries');
  }

  // ── Week entries ───────────────────────────────────────────────────────────

  WeekEntry? getWeekEntry(int week) => _weekEntries.get(week);

  Future<void> saveWeekEntry(WeekEntry entry) =>
      _weekEntries.put(entry.week, entry);

  // ── Day entries ────────────────────────────────────────────────────────────

  DayEntry? getDayEntry(int week, int dayIndex) =>
      _dayEntries.get('$week-$dayIndex');

  Future<void> saveDayEntry(DayEntry entry) =>
      _dayEntries.put('${entry.week}-${entry.dayIndex}', entry);

  /// Returns a list of 7 entries (null = no check-in for that day).
  List<DayEntry?> getDayEntriesForWeek(int week) =>
      List.generate(7, (i) => getDayEntry(week, i));

  /// Returns all day entries whose Hive key matches any day in [week].
  /// Useful for bulk checks; individual look-ups via [getDayEntry] also work.
  Map<int, DayEntry> getDayEntriesForWeekAsMap(int week) {
    final result = <int, DayEntry>{};
    for (var i = 0; i < 7; i++) {
      final entry = getDayEntry(week, i);
      if (entry != null) result[i] = entry;
    }
    return result;
  }
}
