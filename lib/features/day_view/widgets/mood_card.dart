import 'package:flutter/material.dart';
import '../../../core/models/mood_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class MoodCard extends StatelessWidget {
  final Mood? selectedMood;
  final ValueChanged<Mood> onMoodSelected;

  const MoodCard({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  static const _moodColors = {
    Mood.joyful: Color(0xFFFFD166),
    Mood.grateful: Color(0xFF8FA888),
    Mood.anxious: Color(0xFFE07A5F),
    Mood.tired: Color(0xFFB5C4B1),
    Mood.peaceful: Color(0xFF81B29A),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmBrown.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.mood_outlined, size: 14, color: AppColors.sageGreen),
              const SizedBox(width: 6),
              Text(
                'HOW DO YOU FEEL?',
                style: AppTypography.label.copyWith(
                  color: AppColors.sageGreen,
                  fontSize: 9,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Mood chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: Mood.values.map((mood) {
              final isSelected = selectedMood == mood;
              final moodColor = _moodColors[mood] ?? AppColors.sageGreen;
              return GestureDetector(
                onTap: () => onMoodSelected(mood),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 56,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? moodColor.withOpacity(0.20)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? moodColor : AppColors.divider,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(mood.emoji,
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(
                        mood.label,
                        style: AppTypography.label.copyWith(
                          fontSize: 9,
                          letterSpacing: 0,
                          color: isSelected
                              ? moodColor
                              : AppColors.warmTaupe,
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
      ),
    );
  }
}
