import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    if (oldWidget.focusedWeek != widget.focusedWeek) {
      _maybeScrollToFocusedWeek();
    }
  }

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
              _NavButton(
                icon: Icons.chevron_left,
                onTap: () => setState(() => _displayMonth =
                    DateTime(_displayMonth.year, _displayMonth.month - 1)),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${_monthNames[_displayMonth.month - 1]} ${_displayMonth.year}',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warmBrown,
                    ),
                  ),
                ),
              ),
              _NavButton(
                icon: Icons.chevron_right,
                onTap: () => setState(() => _displayMonth =
                    DateTime(_displayMonth.year, _displayMonth.month + 1)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Day-of-week headers
          Row(
            children: _weekDayHeaders
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: AppTypography.label.copyWith(
                            color: AppColors.warmTaupe,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          Divider(
            color: AppColors.divider,
            thickness: 1,
            height: 8,
          ),
          // Calendar rows
          ...weeks.map((week) => _buildWeekRow(week, today)),
        ],
      ),
    );
  }

  Widget _buildWeekRow(List<_CalendarDay> week, DateTime today) {
    final isFocusedRow = week.any((d) => d.pregnancyWeek == widget.focusedWeek);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        color: isFocusedRow
            ? AppColors.sageGreen.withOpacity(0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
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

    final isPast = calDay.date.isBefore(today) && !isToday;

    final entry = calDay.pregnancyWeek != null
        ? JourneyRepository.instance
            .getDayEntry(calDay.pregnancyWeek!, calDay.dayIndex)
        : null;
    final hasMood = entry?.mood != null;
    final moodColor = hasMood ? (_moodColors[entry!.mood!] ?? AppColors.sageMuted) : null;

    Color bgColor;
    Color textColor;
    double bgOpacity = 0;

    if (isToday) {
      bgColor = AppColors.softGold;
      textColor = Colors.white;
      bgOpacity = 1.0;
    } else if (hasMood && moodColor != null) {
      bgColor = moodColor;
      textColor = AppColors.warmBrown;
      bgOpacity = 0.30;
    } else if (isPast && calDay.isCurrentMonth) {
      bgColor = AppColors.divider;
      textColor = AppColors.warmTaupe;
      bgOpacity = 0.30;
    } else if (!calDay.isCurrentMonth) {
      bgColor = Colors.transparent;
      textColor = AppColors.warmTaupe.withOpacity(0.25);
      bgOpacity = 0;
    } else {
      // Future current month
      bgColor = Colors.transparent;
      textColor = AppColors.warmBrown.withOpacity(0.60);
      bgOpacity = 0;
    }

    return GestureDetector(
      onTap: calDay.pregnancyWeek != null
          ? () => widget.onDayTap(calDay.pregnancyWeek!, calDay.dayIndex)
          : null,
      child: SizedBox(
        height: 44,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: isToday ? 34 : (hasMood || isPast ? 30 : 0),
                height: isToday ? 34 : (hasMood || isPast ? 30 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgOpacity > 0
                      ? bgColor.withOpacity(bgOpacity)
                      : Colors.transparent,
                ),
              ),
              // Day number
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${calDay.date.day}',
                    style: AppTypography.label.copyWith(
                      color: textColor,
                      fontSize: 12,
                      letterSpacing: 0,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  // Mood emoji overlay for hasMood
                  if (hasMood && !isToday) ...[
                    Text(entry!.mood!.emoji,
                        style: const TextStyle(fontSize: 8)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.softGold.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.softGold.withOpacity(0.40),
            width: 1,
          ),
        ),
        child: Icon(icon, size: 18, color: AppColors.warmBrown),
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
