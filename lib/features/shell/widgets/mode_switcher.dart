import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../app_shell.dart';

class ModeSwitcher extends StatelessWidget {
  const ModeSwitcher({super.key});

  static const _labels = ['Journey', 'Calendar', 'Day'];

  @override
  Widget build(BuildContext context) {
    final shellState = AppShell.of(context);
    final activeIndex = shellState.currentMode;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: List.generate(_labels.length, (i) {
            final isActive = i == activeIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => shellState.switchMode(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.sageGreen : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.pillRadius - 3),
                  ),
                  child: Center(
                    child: Text(
                      _labels[i],
                      style: AppTypography.label.copyWith(
                        color: isActive ? Colors.white : AppColors.warmBrown,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w400,
                        letterSpacing: 0.3,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
