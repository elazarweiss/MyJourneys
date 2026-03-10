import 'package:flutter/material.dart';
import '../../../core/models/mood_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class MoodSelector extends StatelessWidget {
  final Mood? selectedMood;
  final ValueChanged<Mood> onMoodSelected;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOW ARE YOU FEELING?',
          style: AppTypography.label.copyWith(color: AppColors.warmTaupe),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: Mood.values.map((mood) {
            final bool isSelected = selectedMood == mood;
            return GestureDetector(
              onTap: () => onMoodSelected(mood),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: 58,
                height: 72,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.sageGreen.withOpacity(0.15)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.sageGreen : AppColors.divider,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(mood.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 4),
                    Text(
                      mood.label,
                      style: AppTypography.label.copyWith(
                        fontSize: 9,
                        letterSpacing: 0,
                        color: isSelected
                            ? AppColors.sageGreen
                            : AppColors.darkOlive.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
