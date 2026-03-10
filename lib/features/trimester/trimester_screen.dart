import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/timeline_utils.dart';
import '../../core/utils/trimester_utils.dart';
import '../../data/mock_data.dart';
import '../../shared/widgets/cream_scaffold.dart';
import '../../shared/widgets/serif_text.dart';
import 'widgets/trimester_milestone_pin.dart';
import 'widgets/trimester_timeline_painter.dart';

class TrimesterScreen extends StatefulWidget {
  final int trimesterNumber;

  const TrimesterScreen({super.key, required this.trimesterNumber});

  @override
  State<TrimesterScreen> createState() => _TrimesterScreenState();
}

class _TrimesterScreenState extends State<TrimesterScreen> {
  static const double _weekSpacing = 56.0;
  static const double _canvasHeight = 220.0;
  static const double _amplitude = 28.0;

  late final ScrollController _timelineScroll;

  int get _startWeek => TrimesterUtils.startWeek(widget.trimesterNumber);
  int get _endWeek => TrimesterUtils.endWeek(widget.trimesterNumber);
  int get _weekCount => _endWeek - _startWeek + 1;
  double get _canvasWidth => _weekCount * _weekSpacing + _weekSpacing;

  @override
  void initState() {
    super.initState();
    _timelineScroll = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoScroll());
  }

  @override
  void dispose() {
    _timelineScroll.dispose();
    super.dispose();
  }

  void _autoScroll() {
    if (!_timelineScroll.hasClients) return;
    final int current = mockJourney.currentWeek;
    double targetX;
    if (current >= _startWeek && current <= _endWeek) {
      final double x =
          (current - _startWeek) * _weekSpacing + _weekSpacing / 2;
      final double screenWidth = MediaQuery.of(context).size.width;
      targetX = x - screenWidth / 2;
    } else {
      targetX = (_canvasWidth - MediaQuery.of(context).size.width) / 2;
    }
    _timelineScroll.animateTo(
      targetX.clamp(0.0, _timelineScroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final journey = mockJourney;
    final trimesterMilestones = journey.milestones
        .where((m) => m.week >= _startWeek && m.week <= _endWeek)
        .toList();

    return CreamScaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: _canvasHeight,
              child: SingleChildScrollView(
                controller: _timelineScroll,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: _canvasWidth,
                  height: _canvasHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomPaint(
                        size: Size(_canvasWidth, _canvasHeight),
                        painter: TrimesterTimelinePainter(
                          startWeek: _startWeek,
                          endWeek: _endWeek,
                          currentWeek: journey.currentWeek,
                          weekSpacing: _weekSpacing,
                          amplitude: _amplitude,
                          milestones: trimesterMilestones,
                        ),
                      ),
                      ...trimesterMilestones
                          .where((m) => m.week != journey.currentWeek)
                          .map(
                            (m) => TrimesterMilestonePin(
                              milestone: m,
                              startWeek: _startWeek,
                              weekSpacing: _weekSpacing,
                              canvasHeight: _canvasHeight,
                              amplitude: _amplitude,
                              onTap: () => context.push('/week/${m.week}'),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildWeekGrid(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
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
                if (context.canPop()) context.pop();
                else context.go('/');
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SerifText(
                  TrimesterUtils.labelForTrimester(widget.trimesterNumber),
                  fontSize: 24,
                ),
                Text(
                  'Weeks $_startWeek–$_endWeek',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.warmTaupe),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekGrid(BuildContext context) {
    final journey = mockJourney;
    final milestoneWeeks =
        journey.milestones.map((m) => m.week).toSet();

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
          Text(
            'WEEKS',
            style: AppTypography.label.copyWith(color: AppColors.warmTaupe),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (int week = _startWeek; week <= _endWeek; week++)
                _WeekChip(
                  week: week,
                  isCurrent: week == journey.currentWeek,
                  isPast: week < journey.currentWeek,
                  hasMilestone: milestoneWeeks.contains(week),
                  milestoneEmoji: milestoneWeeks.contains(week)
                      ? journey.milestones
                          .firstWhere((m) => m.week == week)
                          .emoji
                      : null,
                  onTap: () => context.push('/week/$week'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekChip extends StatelessWidget {
  final int week;
  final bool isCurrent;
  final bool isPast;
  final bool hasMilestone;
  final String? milestoneEmoji;
  final VoidCallback onTap;

  const _WeekChip({
    required this.week,
    required this.isCurrent,
    required this.isPast,
    required this.hasMilestone,
    required this.milestoneEmoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isCurrent
        ? AppColors.softGold
        : isPast
            ? AppColors.sageGreen.withValues(alpha: 0.15)
            : AppColors.surface;
    final Color textColor = isCurrent
        ? Colors.white
        : isPast
            ? AppColors.warmBrown
            : AppColors.warmTaupe;
    final Color borderColor = isCurrent
        ? AppColors.softGold
        : isPast
            ? AppColors.sageGreen.withValues(alpha: 0.3)
            : AppColors.divider;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Center(
              child: Text(
                '$week',
                style: AppTypography.bodySmall.copyWith(
                  color: textColor,
                  fontWeight:
                      isCurrent ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
          if (hasMilestone && milestoneEmoji != null)
            Positioned(
              top: -6,
              right: -6,
              child: Text(
                milestoneEmoji!,
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
