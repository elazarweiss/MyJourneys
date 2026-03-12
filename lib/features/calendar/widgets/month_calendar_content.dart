import 'package:flutter/material.dart';
import '../../../core/models/mood_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/journey_repository.dart';
import '../../../data/mock_data.dart';

class MonthCalendarContent extends StatefulWidget {
  /// Called when the user taps a week-row label ("W36").
  final ValueChanged<int> onWeekTap;

  /// Called when the user taps a day cell.
  final void Function(int week, int dayIndex) onDayTap;

  const MonthCalendarContent({
    super.key,
    required this.onWeekTap,
    required this.onDayTap,
  });

  @override
  State<MonthCalendarContent> createState() => _MonthCalendarContentState();
}

class _MonthCalendarContentState extends State<MonthCalendarContent> {
  late DateTime _displayMonth;

  static const _weekDayHeaders = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const _moodColors = {
    Mood.joyful: Color(0xFFFFD166),
    Mood.grateful: Color(0xFF8FA888),
    Mood.anxious: Color(0xFFE07A5F),
    Mood.tired: Color(0xFFB5C4B1),
    Mood.peaceful: Color(0xFF81B29A),
  };

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  /// Returns the pregnancy week number (1–40) for a given calendar date,
  /// or -1 if the date is outside the pregnancy window.
  int _pregnancyWeekForDate(DateTime date) {
    final conceptionDate =
        mockJourney.dueDate.subtract(const Duration(days: 280));
    final days = date.difference(conceptionDate).inDays;
    if (days < 0 || days >= 280) return -1;
    return days ~/ 7 + 1;
  }

  /// Builds a 2D list: each inner list is 7 days (Mon-Sun) for one calendar row.
  List<List<_CalendarDay>> _buildCalendarWeeks() {
    final first = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final last = DateTime(_displayMonth.year, _displayMonth.month + 1, 0);

    // Pad to the nearest Monday before the 1st
    var start = first.subtract(Duration(days: first.weekday - 1));
    // Pad to the nearest Sunday after the last day
    final end = last.add(Duration(days: 7 - last.weekday));

    final weeks = <List<_CalendarDay>>[];
    var date = start;
    while (!date.isAfter(end)) {
      final row = <_CalendarDay>[];
      for (var i = 0; i < 7; i++) {
        final week = _pregnancyWeekForDate(date);
        row.add(_CalendarDay(
          date: date,
          pregnancyWeek: (week >= 1 && week <= 40) ? week : null,
          dayIndex: date.weekday - 1, // 0=Mon…6=Sun
          isCurrentMonth: date.month == _displayMonth.month,
        ));
        date = date.add(const Duration(days: 1));
      }
      weeks.add(row);
    }
    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    final weeks = _buildCalendarWeeks();
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Month navigation header
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 22),
                color: AppColors.warmBrown,
                onPressed: () => setState(() {
                  _displayMonth =
                      DateTime(_displayMonth.year, _displayMonth.month - 1);
                }),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${_monthNames[_displayMonth.month - 1]} ${_displayMonth.year}',
                    style: AppTypography.body.copyWith(
                      color: AppColors.warmBrown,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 22),
                color: AppColors.warmBrown,
                onPressed: () => setState(() {
                  _displayMonth =
                      DateTime(_displayMonth.year, _displayMonth.month + 1);
                }),
              ),
            ],
          ),
          // Day-of-week column headers
          Row(
            children: [
              const SizedBox(width: 36), // week-label column
              ..._weekDayHeaders.map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: AppTypography.label.copyWith(
                        color: AppColors.warmTaupe,
                        fontSize: 9,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // Calendar rows
          ...weeks.map((week) => _buildWeekRow(week, today)),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _buildWeekRow(List<_CalendarDay> week, DateTime today) {
    // Find the pregnancy week for this row (use first non-null entry).
    final pregnancyWeek =
        week.where((d) => d.pregnancyWeek != null).firstOrNull?.pregnancyWeek;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          // Week label
          GestureDetector(
            onTap:
                pregnancyWeek != null ? () => widget.onWeekTap(pregnancyWeek) : null,
            child: SizedBox(
              width: 36,
              child: Text(
                pregnancyWeek != null ? 'W$pregnancyWeek' : '',
                style: AppTypography.label.copyWith(
                  color: AppColors.warmTaupe,
                  fontSize: 9,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          // Day cells
          ...week.map((day) => Expanded(child: _buildDayCell(day, today))),
        ],
      ),
    );
  }

  Widget _buildDayCell(_CalendarDay calDay, DateTime today) {
    final isToday = calDay.date.year == today.year &&
        calDay.date.month == today.month &&
        calDay.date.day == today.day;

    final entry = calDay.pregnancyWeek != null
        ? JourneyRepository.instance
            .getDayEntry(calDay.pregnancyWeek!, calDay.dayIndex)
        : null;
    final hasMood = entry?.mood != null;

    return GestureDetector(
      onTap: calDay.pregnancyWeek != null
          ? () => widget.onDayTap(calDay.pregnancyWeek!, calDay.dayIndex)
          : null,
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: AppColors.softGold, width: 2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${calDay.date.day}',
                style: AppTypography.label.copyWith(
                  color: calDay.isCurrentMonth
                      ? AppColors.warmBrown
                      : AppColors.warmTaupe.withValues(alpha: 0.4),
                  fontSize: 12,
                  letterSpacing: 0,
                ),
              ),
              if (hasMood) ...[
                const SizedBox(height: 2),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _moodColors[entry!.mood!] ?? AppColors.sageMuted,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarDay {
  final DateTime date;
  final int? pregnancyWeek;
  final int dayIndex; // 0=Mon…6=Sun
  final bool isCurrentMonth;

  const _CalendarDay({
    required this.date,
    required this.pregnancyWeek,
    required this.dayIndex,
    required this.isCurrentMonth,
  });
}
