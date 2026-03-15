import 'package:flutter/material.dart';
import '../../core/models/milestone_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/timeline_utils.dart';
import '../../data/mock_data.dart';
import '../../data/pregnancy_data.dart';
import '../../shared/widgets/cream_scaffold.dart';
import '../../shared/widgets/serif_text.dart';
import '../shell/app_shell.dart';
import '../shell/widgets/mode_switcher.dart';
import 'widgets/clothesline_painter.dart';
import 'widgets/milestone_card.dart';

class JourneyOverviewScreen extends StatelessWidget {
  const JourneyOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CreamScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: _buildHeader(),
          ),
          const ModeSwitcher(),
          const Expanded(child: _ClotheslineTimeline()),
          const SafeArea(top: false, child: SizedBox(height: 8)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SerifText(mockJourney.name, fontSize: 28),
          const SizedBox(height: 2),
          Text(
            'Week ${mockJourney.currentWeek} of ${mockJourney.totalWeeks}  ·  ${mockJourney.trimesterLabel}',
            style:
                AppTypography.bodySmall.copyWith(color: AppColors.warmTaupe),
          ),
        ],
      ),
    );
  }
}

// ─── Clothesline Timeline ─────────────────────────────────────────────────────

class _ClotheslineTimeline extends StatefulWidget {
  const _ClotheslineTimeline();

  @override
  State<_ClotheslineTimeline> createState() => _ClotheslineTimelineState();
}

class _ClotheslineTimelineState extends State<_ClotheslineTimeline> {
  static const double _weekSpacing = 88.0;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToCurrentWeek());
  }

  void _scrollToCurrentWeek() {
    if (!_scrollController.hasClients) return;
    final weekX =
        TimelineUtils.xForWeek(mockJourney.currentWeek, _weekSpacing);
    final viewportWidth = _scrollController.position.viewportDimension;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final target = (weekX - viewportWidth / 2).clamp(0.0, maxScroll);
    _scrollController.jumpTo(target);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final journey = mockJourney;
    final double totalW = journey.totalWeeks * _weekSpacing + _weekSpacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double canvasH = constraints.maxHeight;
        // 38% gives enough room for milestone cards (~130px) below
        final double lineY = canvasH * 0.38;

        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: totalW,
            height: canvasH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Background tint + ticks + current-week circle ──────
                CustomPaint(
                  size: Size(totalW, canvasH),
                  painter: ClotheslinePainter(
                    currentWeek: journey.currentWeek,
                    totalWeeks: journey.totalWeeks,
                    weekSpacing: _weekSpacing,
                    lineY: lineY,
                  ),
                ),

                // ── Gradient wire (sage → lavender → honey) ────────────
                Positioned(
                  left: 0,
                  right: 0,
                  top: lineY - 1.5,
                  child: IgnorePointer(
                    child: Container(
                      height: 3,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF90C48A),
                            Color(0xFFB8A0C0),
                            Color(0xFFCF9850),
                          ],
                          stops: [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Trimester labels — well above the wire ─────────────
                ..._buildTrimesterLabels(lineY),

                // ── Baby-size pills — just above the wire ──────────────
                ...journey.milestones.map((m) {
                  final x = TimelineUtils.xForWeek(m.week, _weekSpacing);
                  final info = pregnancyData[m.week - 1];
                  return _BabySizePill(
                    x: x,
                    lineY: lineY,
                    emoji: info.babySizeEmoji,
                    babySize: info.babySize,
                    week: m.week,
                  );
                }),

                // ── Milestone cards (below the wire) ────────────────────
                ...journey.milestones.asMap().entries.map((e) {
                  final x = TimelineUtils.xForWeek(
                      e.value.week, _weekSpacing);
                  return MilestoneCard(
                    milestone: e.value,
                    x: x,
                    lineY: lineY,
                    onTap: () => AppShell.of(context)
                        .openCalendarWeekDetail(e.value.week),
                  );
                }),

                // ── Invisible tap zones for every week ─────────────────
                ...List.generate(journey.totalWeeks, (i) {
                  final week = i + 1;
                  final x = TimelineUtils.xForWeek(week, _weekSpacing);
                  return Positioned(
                    left: x - 22,
                    top: lineY - 22,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => AppShell.of(context)
                          .openCalendarWeekDetail(week),
                      child: const SizedBox(width: 44, height: 44),
                    ),
                  );
                }),

              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildTrimesterLabels(double lineY) {
    const starts = [1, 13, 27];
    const labels = ['FIRST', 'SECOND', 'THIRD'];
    const colors = [
      Color(0xFF90C48A),
      Color(0xFFB8A0C0),
      Color(0xFFCF9850),
    ];
    return List.generate(3, (i) {
      final x = TimelineUtils.xForWeek(starts[i], _weekSpacing);
      return Positioned(
        left: x - 4,
        top: lineY - 56,
        child: Text(
          labels[i],
          style: AppTypography.label.copyWith(
            fontSize: 8,
            color: colors[i].withOpacity(0.85),
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    });
  }

}

// ─── Baby Size Pill ───────────────────────────────────────────────────────────

class _BabySizePill extends StatelessWidget {
  final double x;
  final double lineY;
  final String emoji;
  final String babySize;
  final int week;

  const _BabySizePill({
    required this.x,
    required this.lineY,
    required this.emoji,
    required this.babySize,
    required this.week,
  });

  Color get _trimesterColor {
    if (week <= 12) return const Color(0xFF90C48A);
    if (week <= 26) return const Color(0xFFB8A0C0);
    return const Color(0xFFCF9850);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x - 36,
      top: lineY - 28,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: _trimesterColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$emoji $babySize',
          style: TextStyle(
            fontSize: 9,
            color: AppColors.warmBrown.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
