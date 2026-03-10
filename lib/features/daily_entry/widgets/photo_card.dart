import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class PhotoCard extends StatelessWidget {
  final String? assetPath;
  final VoidCallback onTap;

  const PhotoCard({
    super.key,
    this.assetPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: assetPath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius - 1),
                child: Image.asset(assetPath!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40,
                    color: AppColors.warmTaupe.withOpacity(0.7),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Add a photo',
                    style: AppTypography.label.copyWith(
                      color: AppColors.warmTaupe,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
