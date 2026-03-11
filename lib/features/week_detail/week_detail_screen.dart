import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/mood_model.dart';
import '../../core/models/week_entry_model.dart';
import '../../core/models/week_info_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/trimester_utils.dart';
import '../../data/journey_repository.dart';
import '../../data/mock_data.dart';
import '../../data/pregnancy_data.dart';
import '../../shared/widgets/cream_scaffold.dart';
import '../../shared/widgets/serif_text.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/milestone_marker.dart';
import 'widgets/spiral_path_painter.dart';

class WeekDetailScreen extends StatefulWidget {
  final int weekNumber;

  const WeekDetailScreen({super.key, required this.weekNumber});

  @override
  State<WeekDetailScreen> createState() => _WeekDetailScreenState();
}

class _WeekDetailScreenState extends State<WeekDetailScreen> {
  static const double _timelineHeight = 180.0;
  static const double _amplitude = 20.0;

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static const _moodColors = {
    Mood.joyful:   Color(0xFFFFD166),
    Mood.grateful: Color(0xFF8FA888),
    Mood.anxious:  Color(0xFFE07A5F),
    Mood.tired:    Color(0xFFB5C4B1),
    Mood.peaceful: Color(0xFF81B29A),
  };

  WeekInfo get _weekInfo =>
      pregnancyData[widget.weekNumber.clamp(1, 40) - 1];

  String _dateLabelForWeek() {
    final date = mockJourney.dueDate.subtract(
      Duration(days: (mockJourney.totalWeeks - widget.weekNumber) * 7),
    );
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  Future<void> _goToEntry() async {
    await context.push('/week/${widget.weekNumber}/entry');
    if (mounted) setState(() {});
  }

  Future<void> _goToDayCheckIn(int dayIndex) async {
    await context.push('/week/${widget.weekNumber}/day/$dayIndex');
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CreamScaffold(
      bottomNavigationBar: WeekDetailBottomNav(
        onAddPhoto: _goToEntry,
        onWriteJournal: _goToEntry,
        onMood: _goToEntry,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildMiniTimeline()),
          SliverToBoxAdapter(child: _buildDayRow()),
          SliverToBoxAdapter(child: _buildBabySizeCard()),
          SliverToBoxAdapter(child: _buildWeekInfo()),
          SliverToBoxAdapter(child: _buildReflectionSection()),
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
                    '/trimester/${TrimesterUtils.trimesterForWeek(widget.weekNumber)}',
                  );
                }
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SerifText(
                    'Week ${widget.weekNumber}',
                    fontSize: 24,
                  ),
                  Text(
                    '${TrimesterUtils.labelForTrimester(TrimesterUtils.trimesterForWeek(widget.weekNumber))}  ·  ${_dateLabelForWeek()}',
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

  // ── 7-day row ────────────────────────────────────────────────────────────

  Widget _buildDayRow() {
    final dayEntries = JourneyRepository.instance
        .getDayEntriesForWeek(widget.weekNumber);

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
              'THIS WEEK',
              style: AppTypography.label.copyWith(color: AppColors.warmTaupe),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final entry = dayEntries[i];
                final hasMood = entry?.mood != null;
                final dotColor = hasMood
                    ? _moodColors[entry!.mood!]!
                    : AppColors.divider;

                return GestureDetector(
                  onTap: () => _goToDayCheckIn(i),
                  child: Column(
                    children: [
                      Text(
                        _dayLabels[i],
                        style: AppTypography.label.copyWith(
                          fontSize: 9,
                          color: AppColors.warmTaupe,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: hasMood
                              ? dotColor.withValues(alpha: 0.25)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: hasMood ? dotColor : AppColors.divider,
                            width: hasMood ? 1.5 : 1,
                          ),
                        ),
                        child: hasMood
                            ? Center(
                                child: Text(
                                  entry!.mood!.emoji,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.add,
                                  size: 12,
                                  color: AppColors.warmTaupe,
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Baby size card ────────────────────────────────────────────────────────

  Widget _buildBabySizeCard() {
    final info = _weekInfo;
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
              child: Center(
                child: Text(
                  info.babySizeEmoji,
                  style: const TextStyle(fontSize: 26),
                ),
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
                    'The size of a ${info.babySize}',
                    style: AppTypography.body.copyWith(
                      color: AppColors.warmBrown,
                      fontWeight: FontWeight.w500,
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

  // ── This week's focus ────────────────────────────────────────────────────

  Widget _buildWeekInfo() {
    final info = _weekInfo;
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info.babySizeEmoji,
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    info.tip,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.darkOlive),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Weekly reflection section ─────────────────────────────────────────────

  Widget _buildReflectionSection() {
    final entry = JourneyRepository.instance.getWeekEntry(widget.weekNumber);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry != null) _buildReflectionPreview(entry),
          const SizedBox(height: AppSpacing.sm),
          _buildReflectionButton(hasEntry: entry != null),
        ],
      ),
    );
  }

  Widget _buildReflectionPreview(WeekEntry entry) {
    final mood = entry.mood;
    final text = entry.journalText;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mood != null) ...[
            Text(mood.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEEKLY REFLECTION',
                  style: AppTypography.label.copyWith(
                    color: AppColors.warmTaupe,
                    fontSize: 9,
                  ),
                ),
                if (text != null && text.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    text.length > 80 ? '${text.substring(0, 80)}…' : text,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.darkOlive),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionButton({required bool hasEntry}) {
    return GestureDetector(
      onTap: _goToEntry,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: hasEntry
              ? AppColors.surface
              : AppColors.sageGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: hasEntry ? AppColors.divider : AppColors.sageGreen,
          ),
        ),
        child: Center(
          child: Text(
            hasEntry ? 'Edit Reflection' : '+ Weekly Reflection',
            style: AppTypography.label.copyWith(
              color: hasEntry ? AppColors.warmBrown : AppColors.sageGreen,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
