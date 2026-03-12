import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // Twemoji CDN — colour emoji for every platform
  static String _twemojiUrl(String emoji) {
    final runes = emoji.runes
        .where((r) => r != 0xFE0F)
        .map((r) => r.toRadixString(16))
        .join('-');
    return 'https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/$runes.png';
  }

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
        // Line at 55% so emojis have room above and labels below
        final double lineY = canvasH * 0.55;

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
                // ── Background gradient + week dots (custom paint) ─────────
                CustomPaint(
                  size: Size(totalW, canvasH),
                  painter: ClotheslinePainter(
                    currentWeek: journey.currentWeek,
                    totalWeeks: journey.totalWeeks,
                    weekSpacing: _weekSpacing,
                    lineY: lineY,
                  ),
                ),

                // ── Gradient-coloured wire ─────────────────────────────────
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
                            Color(0xFF90C48A), // sage green — first trimester
                            Color(0xFFB8A0C0), // lavender — second trimester
                            Color(0xFFCF9850), // warm honey — third trimester
                          ],
                          stops: [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Trimester zone labels (above emoji row) ────────────────
                ..._buildTrimesterLabels(lineY),

                // ── Baby-size Twemoji images (above the wire) ─────────────
                ...List.generate(journey.totalWeeks, (i) {
                  final week = i + 1;
                  final x = TimelineUtils.xForWeek(week, _weekSpacing);
                  final emoji = pregnancyData[i].babySizeEmoji;
                  return Positioned(
                    left: x - 14,
                    top: lineY - 52,
                    child: Image.network(
                      _twemojiUrl(emoji),
                      width: 26,
                      height: 26,
                      errorBuilder: (_, __, ___) => Text(emoji,
                          style: const TextStyle(fontSize: 20)),
                    ),
                  );
                }),

                // ── Milestone markers (below the wire, alternating) ────────
                ...journey.milestones.asMap().entries.map((e) {
                  final x = TimelineUtils.xForWeek(
                      e.value.week, _weekSpacing);
                  return _MilestoneMarker(
                    milestone: e.value,
                    x: x,
                    lineY: lineY,
                    above: false, // all below keeps it clean vs emojis above
                    onTap: () => AppShell.of(context)
                        .openCalendarWeekDetail(e.value.week),
                  );
                }),

                // ── Key week numbers (every 4 weeks, below milestones) ─────
                ..._buildWeekLabels(lineY, journey.totalWeeks),

                // ── Invisible tap zone for every week dot ──────────────────
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

                // ── "Week N" Dancing Script label below current-week circle ─
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
        top: lineY - 78,
        child: Text(
          labels[i],
          style: AppTypography.label.copyWith(
            fontSize: 8,
            color: colors[i].withValues(alpha: 0.85),
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    });
  }

  List<Widget> _buildWeekLabels(double lineY, int totalWeeks) {
    return List.generate(totalWeeks ~/ 4, (i) {
      final week = (i + 1) * 4;
      final x = TimelineUtils.xForWeek(week, _weekSpacing);
      return Positioned(
        left: x - 8,
        top: lineY + 68,
        child: Text(
          '$week',
          style: AppTypography.label.copyWith(
            fontSize: 9,
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
    const w = 56.0;
    const stemH = 10.0;

    return Positioned(
      left: x - w / 2,
      top: lineY + stemH,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Stem
              Container(
                width: 1,
                height: stemH,
                color: AppColors.warmTaupe.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 3),
              // Milestone emoji in a soft circle
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: milestone.reached
                      ? AppColors.softGold.withValues(alpha: 0.18)
                      : AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: milestone.reached
                        ? AppColors.softGold.withValues(alpha: 0.5)
                        : AppColors.divider,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(milestone.emoji,
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                milestone.label,
                style: AppTypography.label.copyWith(
                  fontSize: 8,
                  color: milestone.reached
                      ? AppColors.warmBrown
                      : AppColors.warmTaupe.withValues(alpha: 0.55),
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
