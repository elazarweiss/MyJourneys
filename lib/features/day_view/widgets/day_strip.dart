import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final todayDayIndex = DateTime.now().weekday - 1; // 0=Mon…6=Sun
    final isCurrentWeek = weekNumber == mockJourney.currentWeek;

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
          final hasEntry = entry?.mood != null;
          final isSelected = i == selectedDayIndex;
          final isToday = isCurrentWeek && i == todayDayIndex;

          return GestureDetector(
            onTap: () => onDayTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.sageGreen
                    : hasEntry
                        ? AppColors.sageGreen.withValues(alpha: 0.15)
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
              child: Text(
                _dayLabels[i],
                style: AppTypography.label.copyWith(
                  color: isSelected ? Colors.white : AppColors.warmBrown,
                  letterSpacing: 0.2,
                  fontSize: 11,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
