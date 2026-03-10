import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/trimester_utils.dart';
import '../../data/mock_data.dart';
import '../../shared/widgets/cream_scaffold.dart';
import '../../shared/widgets/serif_text.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/milestone_marker.dart';
import 'widgets/spiral_path_painter.dart';

class WeekDetailScreen extends StatelessWidget {
  final int weekNumber;

  const WeekDetailScreen({super.key, required this.weekNumber});

  static const double _timelineHeight = 180.0;
  static const double _amplitude = 20.0;


  String _dateLabelForWeek(int week) {
    final entry = mockJourney.entryForWeek(week);
    final date = entry?.date ??
        mockJourney.dueDate.subtract(
          Duration(days: (mockJourney.totalWeeks - week) * 7),
        );
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return CreamScaffold(
      bottomNavigationBar: WeekDetailBottomNav(
        onAddPhoto: () => context.push('/week/$weekNumber/entry'),
        onWriteJournal: () => context.push('/week/$weekNumber/entry'),
        onMood: () => context.push('/week/$weekNumber/entry'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildMiniTimeline()),
          SliverToBoxAdapter(child: _buildBabySizeCard()),
          SliverToBoxAdapter(child: _buildWeekInfo()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.lg,
          0,
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppColors.warmBrown,
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(
                    '/trimester/${TrimesterUtils.trimesterForWeek(weekNumber)}',
                  );
                }
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SerifText(
                    'You are in Week $weekNumber',
                    fontSize: 24,
                  ),
                  Text(
                    '${TrimesterUtils.labelForTrimester(TrimesterUtils.trimesterForWeek(weekNumber))}  ·  ${_dateLabelForWeek(weekNumber)}',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.warmTaupe),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTimeline() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final journey = mockJourney;

        return SizedBox(
          height: _timelineHeight,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(w, _timelineHeight),
                painter: MiniTimelinePainter(
                  currentWeek: journey.currentWeek,
                  totalWeeks: journey.totalWeeks,
                  milestones: journey.milestones,
                  amplitude: _amplitude,
                ),
              ),
              // Milestone labels — skip current week (gold dot speaks for itself)
              ...journey.milestones
                  .asMap()
                  .entries
                  .where((e) => e.value.week != journey.currentWeek)
                  .map(
                    (e) => MilestoneMarker(
                      milestone: e.value,
                      index: e.key,
                      canvasHeight: _timelineHeight,
                      canvasWidth: w,
                      amplitude: _amplitude,
                      totalWeeks: journey.totalWeeks,
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBabySizeCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.softGold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🍈', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR BABY THIS WEEK',
                    style: AppTypography.label.copyWith(
                      color: AppColors.warmTaupe,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'The size of a honeydew melon',
                    style: AppTypography.body.copyWith(
                      color: AppColors.warmBrown,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'About 47 cm · 2.6 kg',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.warmTaupe),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '✨  THIS WEEK\'S FOCUS',
              style: AppTypography.label.copyWith(color: AppColors.warmBrown),
            ),
            const SizedBox(height: AppSpacing.md),
            _tip('🌿', 'Baby\'s lungs are maturing rapidly — almost ready.'),
            const SizedBox(height: AppSpacing.sm),
            _tip('💧', 'Keep up hydration and gentle walks if you feel up to it.'),
            const SizedBox(height: AppSpacing.sm),
            _tip('📋', 'Double-check your hospital bag and birth plan.'),
          ],
        ),
      ),
    );
  }

  Widget _tip(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(color: AppColors.darkOlive),
          ),
        ),
      ],
    );
  }
}
