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
}
