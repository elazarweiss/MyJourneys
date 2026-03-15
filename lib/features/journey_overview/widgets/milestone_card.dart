import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/milestone_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/dashed_border_painter.dart';

class MilestoneCard extends StatelessWidget {
  final Milestone milestone;
  final double x;
  final double lineY;
  final VoidCallback onTap;

  const MilestoneCard({
    super.key,
    required this.milestone,
    required this.x,
    required this.lineY,
    required this.onTap,
  });

  static const _iconMap = {
    'First Heartbeat': Icons.favorite_outlined,
    'First Trimester End': Icons.eco_outlined,
    'First Kick': Icons.directions_walk_outlined,
    'Anatomy Scan': Icons.monitor_heart_outlined,
    'Third Trimester': Icons.pregnant_woman_outlined,
    'Full Term Soon': Icons.star_outline_rounded,
    'Due Date': Icons.cake_outlined,
  };

  static const _trimesterColors = [
    Color(0xFF90C48A), // trimesterSage
    Color(0xFFB8A0C0), // trimesterLavender
    Color(0xFFCF9850), // trimesterHoney
  ];

  Color get _trimesterColor {
    if (milestone.week <= 12) return _trimesterColors[0];
    if (milestone.week <= 26) return _trimesterColors[1];
    return _trimesterColors[2];
  }

  @override
  Widget build(BuildContext context) {
    const cardW = 72.0;
    const stemH = 16.0;
    final icon = _iconMap[milestone.label] ?? Icons.star_outline_rounded;
    final tc = _trimesterColor;

    return Positioned(
      left: x - cardW / 2,
      top: lineY + 4,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: cardW,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Stem
              Container(
                width: 1,
                height: stemH,
                color: AppColors.warmTaupe.withOpacity(0.35),
              ),
              // Card body
              Container(
                width: cardW,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warmBrown.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon circle
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: tc.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 15,
                          color: milestone.reached
                              ? AppColors.softGold
                              : AppColors.warmTaupe,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Label
                      Text(
                        milestone.label,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 8,
                          fontStyle: FontStyle.italic,
                          color: milestone.reached
                              ? AppColors.warmBrown
                              : AppColors.warmTaupe.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Photo slot
                      _PhotoSlot(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(borderRadius: 6),
      child: SizedBox(
        height: 36,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_a_photo_outlined,
                  size: 12, color: AppColors.warmTaupe),
              const SizedBox(width: 3),
              Text(
                'Add photo',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.warmTaupe,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
