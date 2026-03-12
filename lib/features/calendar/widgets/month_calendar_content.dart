import 'package:flutter/material.dart';
import '../../../core/models/mood_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/journey_repository.dart';
import '../../../data/mock_data.dart';

class MonthCalendarContent extends StatefulWidget {
  /// Currently focused pregnancy week — its row gets a highlight.
  final int focusedWeek;

  /// Called when the user taps a day cell with (pregnancyWeek, dayIndex).
  final void Function(int week, int dayIndex) onDayTap;

  const MonthCalendarContent({
    super.key,
    required this.focusedWeek,
    required this.onDayTap,
  });

  @override
  State<MonthCalendarContent> createState() => _MonthCalendarContentState();
}

class _MonthCalendarContentState extends State<MonthCalendarContent> {
  late DateTime _displayMonth;

  static const _weekDayHeaders = [
    'M', 'T', 'W', 'T', 'F', 'S', 'S',
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

  @override
  void didUpdateWidget(MonthCalendarContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If focusedWeek changed and it's outside the current display month,
    // navigate to the correct month.
    if (oldWidget.focusedWeek != widget.focusedWeek) {
      _maybeScrollToFocusedWeek();
    }
  }

  /// Compute the calendar month that contains the start of [week].
  void _maybeScrollToFocusedWeek() {
    final weekStart = _weekStartDate(widget.focusedWeek);
    if (weekStart != null) {
      final weekMonth = DateTime(weekStart.year, weekStart.month);
      if (weekMonth != _displayMonth) {
        setState(() => _displayMonth = weekMonth);
      }
    }
  }

  DateTime? _weekStartDate(int pregnancyWeek) {
    final conception = mockJourney.dueDate.subtract(const Duration(days: 280));
    final start = conception.add(Duration(days: (pregnancyWeek - 1) * 7));
    return start;
  }

  int _pregnancyWeekForDate(DateTime date) {
    final conception = mockJourney.dueDate.subtract(const Duration(days: 280));
    final days = date.difference(conception).inDays;
    if (days < 0 || days >= 280) return -1;
    return days ~/ 7 + 1;
  }

  List<List<_CalendarDay>> _buildCalendarWeeks() {
    final first = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final last = DateTime(_displayMonth.year, _displayMonth.month + 1, 0);
    var start = first.subtract(Duration(days: first.weekday - 1));
    final end = last.add(Duration(days: 7 - last.weekday));

    final weeks = <List<_CalendarDay>>[];
    var date = start;
    while (!date.isAfter(end)) {
      final row = <_CalendarDay>[];
      for (var i = 0; i < 7; i++) {
        final pw = _pregnancyWeekForDate(date);
        row.add(_CalendarDay(
          date: date,
          pregnancyWeek: (pw >= 1 && pw <= 40) ? pw : null,
          dayIndex: date.weekday - 1,
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
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Month navigation header
          Row(
            children: [
              _NavChevron(
                icon: Icons.chevron_left,
                onTap: () => setState(() => _displayMonth =
                    DateTime(_displayMonth.year, _displayMonth.month - 1)),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${_monthNames[_displayMonth.month - 1]} ${_displayMonth.year}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warmBrown,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              _NavChevron(
                icon: Icons.chevron_right,
                onTap: () => setState(() => _displayMonth =
                    DateTime(_displayMonth.year, _displayMonth.month + 1)),
              ),
            ],
          ),
          // Day-of-week headers
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: _weekDayHeaders
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: AppTypography.label.copyWith(
                              color: AppColors.warmTaupe,
                              fontSize: 10,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Calendar rows
          ...weeks.map((week) => _buildWeekRow(week, today)),
        ],
      ),
    );
  }

  Widget _buildWeekRow(List<_CalendarDay> week, DateTime today) {
    // A row is "focused" if it contains the focused pregnancy week.
    final isFocusedRow = week.any((d) => d.pregnancyWeek == widget.focusedWeek);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        color: isFocusedRow
            ? AppColors.sageGreen.withValues(alpha: 0.09)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: week.map((day) => Expanded(child: _buildDayCell(day, today))).toList(),
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
      child: SizedBox(
        height: 40,
        child: Center(
          child: Container(
            width: 34,
            height: 34,
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
                    color: !calDay.isCurrentMonth
                        ? AppColors.warmTaupe.withValues(alpha: 0.3)
                        : isToday
                            ? AppColors.softGold
                            : AppColors.warmBrown,
                    fontSize: 12,
                    letterSpacing: 0,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                if (hasMood) ...[
                  const SizedBox(height: 1),
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
      ),
    );
  }
}

class _NavChevron extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavChevron({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Icon(icon, size: 20, color: AppColors.warmBrown),
      ),
    );
  }
}

class _CalendarDay {
  final DateTime date;
  final int? pregnancyWeek;
  final int dayIndex;
  final bool isCurrentMonth;

  const _CalendarDay({
    required this.date,
    required this.pregnancyWeek,
    required this.dayIndex,
    required this.isCurrentMonth,
  });
}
