import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/dashed_border_painter.dart';

class PhotoCard extends StatelessWidget {
  const PhotoCard({super.key});

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
              Icon(Icons.photo_camera_outlined,
                  size: 14, color: AppColors.sageGreen),
              const SizedBox(width: 6),
              Text(
                'PHOTOS TODAY',
                style: AppTypography.label.copyWith(
                  color: AppColors.sageGreen,
                  fontSize: 9,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Photo tile row
          Row(
            children: List.generate(3, (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 2 ? AppSpacing.sm : 0),
                child: const _PhotoTile(),
              ),
            )),
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(borderRadius: 12),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.divider.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            Icons.add_a_photo_outlined,
            size: 22,
            color: AppColors.warmTaupe.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
