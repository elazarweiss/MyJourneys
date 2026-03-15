import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class StatsPillRow extends StatelessWidget {
  final int dayOfPregnancy;
  final int weekNumber;
  final String babyEmoji;
  final String babySize;

  const StatsPillRow({
    super.key,
    required this.dayOfPregnancy,
    required this.weekNumber,
    required this.babyEmoji,
    required this.babySize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StatPill(
          icon: Icons.child_friendly_outlined,
          label: 'Day $dayOfPregnancy',
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatPill(
          label: 'Week $weekNumber',
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatPill(
          label: '$babyEmoji $babySize',
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData? icon;
  final String label;

  const _StatPill({this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.warmTaupe),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.label.copyWith(
              fontSize: 10,
              color: AppColors.warmBrown,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
