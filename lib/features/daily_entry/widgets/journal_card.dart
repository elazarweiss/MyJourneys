import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class JournalCard extends StatelessWidget {
  final TextEditingController controller;

  const JournalCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'JOURNAL',
            style: AppTypography.label.copyWith(color: AppColors.warmTaupe),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            maxLines: 6,
            minLines: 4,
            style: GoogleFonts.playfairDisplay(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.warmBrown,
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: 'Write about today…',
              hintStyle: GoogleFonts.playfairDisplay(
                fontSize: 15,
                color: AppColors.warmTaupe.withOpacity(0.6),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
