import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class WeekDetailBottomNav extends StatelessWidget {
  final VoidCallback onAddPhoto;
  final VoidCallback onWriteJournal;
  final VoidCallback onMood;

  const WeekDetailBottomNav({
    super.key,
    required this.onAddPhoto,
    required this.onWriteJournal,
    required this.onMood,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        ),
        child: Row(
          children: [
            _NavItem(
              icon: Icons.edit_outlined,
              label: 'Journal Entry',
              onTap: onWriteJournal,
            ),
            Container(width: 1, height: 40, color: AppColors.divider),
            _NavItem(
              icon: Icons.add_photo_alternate_outlined,
              label: 'Upload Photo',
              onTap: onAddPhoto,
            ),
            Container(width: 1, height: 40, color: AppColors.divider),
            _NavItem(
              icon: Icons.mood_outlined,
              label: 'Mood Check-In',
              onTap: onMood,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: AppColors.warmBrown),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.label.copyWith(
                  color: AppColors.warmBrown,
                  fontSize: 10,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
