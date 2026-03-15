import 'package:flutter/material.dart';
import '../../../core/models/mood_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/journey_repository.dart';
import '../../../data/mock_data.dart';

class DayStrip extends StatelessWidget {
  final int weekNumber;
  final int selectedDayIndex;
  final ValueChanged<int> onDayTap;

  const DayStrip({
    super.key,
    required this.weekNumber,
    required this.selectedDayIndex,
    required this.onDayTap,
  });

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static const _moodColors = {
    Mood.joyful: Color(0xFFFFD166),
    Mood.grateful: Color(0xFF8FA888),
    Mood.anxious: Color(0xFFE07A5F),
    Mood.tired: Color(0xFFB5C4B1),
    Mood.peaceful: Color(0xFF81B29A),
  };

  @override
  Widget build(BuildContext context) {
    final todayDayIndex = DateTime.now().weekday - 1;
    final isCurrentWeek = weekNumber == mockJourney.currentWeek;

    // Calculate date for each day of this week
    final weekStart = _getWeekStart(weekNumber);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final entry =
              JourneyRepository.instance.getDayEntry(weekNumber, i);
          final hasMood = entry?.mood != null;
          final moodColor = hasMood
              ? (_moodColors[entry!.mood!] ?? AppColors.divider)
              : null;
          final isSelected = i == selectedDayIndex;
          final isToday = isCurrentWeek && i == todayDayIndex;
          final dayDate = weekStart?.add(Duration(days: i));
          final dateNum = dayDate?.day;

          return GestureDetector(
            onTap: () => onDayTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.sageGreen
                    : hasMood
                        ? AppColors.sageGreen.withOpacity(0.15)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
                border: Border.all(
                  color: isToday
                      ? AppColors.softGold
                      : isSelected
                          ? AppColors.sageGreen
                          : AppColors.divider,
                  width: isToday ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _dayLabels[i],
                    style: AppTypography.label.copyWith(
                      color: isSelected ? Colors.white : AppColors.warmBrown,
                      letterSpacing: 0.2,
                      fontSize: 11,
                    ),
                  ),
                  if (dateNum != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$dateNum',
                      style: AppTypography.label.copyWith(
                        fontSize: 8,
                        letterSpacing: 0,
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : AppColors.warmTaupe,
                      ),
                    ),
                  ],
                  // Mood dot
                  if (hasMood && moodColor != null) ...[
                    const SizedBox(height: 3),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : moodColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  DateTime? _getWeekStart(int pregnancyWeek) {
    try {
      final conception =
          mockJourney.dueDate.subtract(const Duration(days: 280));
      return conception.add(Duration(days: (pregnancyWeek - 1) * 7));
    } catch (_) {
      return null;
    }
  }
}
