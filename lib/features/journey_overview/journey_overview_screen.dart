import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/milestone_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/timeline_utils.dart';
import '../../data/mock_data.dart';
import '../../shared/widgets/cream_scaffold.dart';
import '../../shared/widgets/serif_text.dart';
import '../shell/app_shell.dart';
import '../shell/widgets/mode_switcher.dart';
import 'widgets/clothesline_painter.dart';

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
          // Timeline fills all remaining space
          const Expanded(child: _ClotheslineTimeline()),
          const SafeArea(top: false, child: SizedBox(height: 8)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
          SerifText(mockJourney.name, fontSize: 28),
          const SizedBox(height: 2),
          Text(
            'Week ${mockJourney.currentWeek} of ${mockJourney.totalWeeks}  ·  ${mockJourney.trimesterLabel}',
            style: AppTypography.bodySmall.copyWith(color: AppColors.warmTaupe),
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentWeek());
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
        // Line sits a bit below center so there's room for labels above
        final double lineY = canvasH * 0.52;

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
                // ── Background gradient bands + week dots ──────────────────
                CustomPaint(
                  size: Size(totalW, canvasH),
                  painter: ClotheslinePainter(
                    currentWeek: journey.currentWeek,
                    totalWeeks: journey.totalWeeks,
                    weekSpacing: _weekSpacing,
                    lineY: lineY,
                  ),
                ),

                // ── Fixed wire ─────────────────────────────────────────────
                Positioned(
                  left: 0,
                  right: 0,
                  top: lineY - 1,
                  child: IgnorePointer(
                    child: Container(
                        height: 2, color: const Color(0xFF3A3A3A)),
                  ),
                ),

                // ── Trimester zone labels above the line ───────────────────
                ..._trimesterLabels(lineY),

                // ── Milestone markers (alternating above/below) ────────────
                ...journey.milestones.asMap().entries.map((e) {
                  final isAbove = e.key.isEven;
                  final x =
                      TimelineUtils.xForWeek(e.value.week, _weekSpacing);
                  return _MilestoneMarker(
                    milestone: e.value,
                    x: x,
                    lineY: lineY,
                    above: isAbove,
                    onTap: () => AppShell.of(context)
                        .openCalendarWeekDetail(e.value.week),
                  );
                }),

                // ── Key week numbers below the line ────────────────────────
                ..._weekNumberLabels(lineY, journey.totalWeeks),

                // ── Invisible tappable overlay for each week dot ───────────
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

                // ── Current-week "Week N" label below its circle ───────────
                Positioned(
                  left: TimelineUtils.xForWeek(
                              journey.currentWeek, _weekSpacing) -
                          40,
                  top: lineY + 18,
                  child: SizedBox(
                    width: 80,
                    child: Text(
                      'Week ${journey.currentWeek}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dancingScript(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.softGold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _trimesterLabels(double lineY) {
    const starts = [1, 13, 27];
    const labels = [
      'FIRST TRIMESTER',
      'SECOND TRIMESTER',
      'THIRD TRIMESTER',
    ];
    return List.generate(3, (i) {
      final x = TimelineUtils.xForWeek(starts[i], _weekSpacing);
      return Positioned(
        left: x - 4,
        top: lineY - 44,
        child: Text(
          labels[i],
          style: AppTypography.label.copyWith(
            fontSize: 7.5,
            color: AppColors.warmTaupe.withValues(alpha: 0.65),
            letterSpacing: 0.8,
          ),
        ),
      );
    });
  }

  List<Widget> _weekNumberLabels(double lineY, int totalWeeks) {
    // Show every 4th week as a small label below the line
    return List.generate(totalWeeks ~/ 4, (i) {
      final week = (i + 1) * 4;
      final x = TimelineUtils.xForWeek(week, _weekSpacing);
      return Positioned(
        left: x - 8,
        top: lineY + 10,
        child: Text(
          '$week',
          style: AppTypography.label.copyWith(
            fontSize: 8.5,
            color: AppColors.warmTaupe.withValues(alpha: 0.55),
            letterSpacing: 0,
          ),
        ),
      );
    });
  }
}

// ─── Milestone Marker ─────────────────────────────────────────────────────────

class _MilestoneMarker extends StatelessWidget {
  final Milestone milestone;
  final double x;
  final double lineY;
  final bool above;
  final VoidCallback onTap;

  const _MilestoneMarker({
    required this.milestone,
    required this.x,
    required this.lineY,
    required this.above,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const markerW = 52.0;
    const emojiSize = 20.0;
    const labelFontSize = 8.0;

    // Vertical stem connecting to line
    final stemH = above ? 20.0 : 14.0;

    return Positioned(
      left: x - markerW / 2,
      top: above ? lineY - stemH - emojiSize - 24 : lineY + stemH,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: markerW,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!above) ...[
                Container(
                    width: 1, height: stemH, color: AppColors.warmTaupe.withValues(alpha: 0.3)),
                const SizedBox(height: 2),
              ],
              Text(milestone.emoji, style: const TextStyle(fontSize: emojiSize)),
              const SizedBox(height: 3),
              Text(
                milestone.label,
                style: AppTypography.label.copyWith(
                  fontSize: labelFontSize,
                  color: milestone.reached
                      ? AppColors.warmBrown
                      : AppColors.warmTaupe.withValues(alpha: 0.5),
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              if (above) ...[
                const SizedBox(height: 2),
                Container(
                    width: 1, height: stemH, color: AppColors.warmTaupe.withValues(alpha: 0.3)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
