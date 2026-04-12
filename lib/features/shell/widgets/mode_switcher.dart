import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../app_shell.dart';

class ModeSwitcher extends StatelessWidget {
  const ModeSwitcher({super.key});

  static const _labels = ['Journey', 'Calendar', 'Day', 'Baby'];
  static const _icons = [
    Icons.timeline_outlined,
    Icons.calendar_month_outlined,
    Icons.wb_sunny_outlined,
    Icons.child_care_outlined,
  ];

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
        height: 48,
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
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.sageGreen.withOpacity(0.30),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _icons[i],
                          size: 13,
                          color: isActive
                              ? Colors.white
                              : AppColors.warmBrown,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _labels[i],
                          style: AppTypography.label.copyWith(
                            color: isActive
                                ? Colors.white
                                : AppColors.warmBrown,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                            letterSpacing: 0.5,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
