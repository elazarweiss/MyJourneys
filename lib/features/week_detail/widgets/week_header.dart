import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/serif_text.dart';

class WeekHeader extends StatelessWidget {
  final int weekNumber;
  final String trimester;
  final String dateLabel;

  const WeekHeader({
    super.key,
    required this.weekNumber,
    required this.trimester,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          0,
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppColors.warmBrown,
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SerifText('Week $weekNumber', fontSize: 26),
                  Text(
                    '$trimester  ·  $dateLabel',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warmTaupe,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
