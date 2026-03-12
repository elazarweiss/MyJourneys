import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          const SliverToBoxAdapter(child: ModeSwitcher()),
          const SliverToBoxAdapter(child: _ClotheslineTimeline()),
          SliverToBoxAdapter(child: _buildScrollHint()),
          SliverToBoxAdapter(child: _buildBabySizeCard()),
          SliverToBoxAdapter(child: _buildJournalColumns(context)),
          SliverToBoxAdapter(child: _buildWeekFocus()),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs,
        ),
        child: Builder(builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SerifText(mockJourney.name, fontSize: 30),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Week ${mockJourney.currentWeek} of ${mockJourney.totalWeeks}  ·  ${mockJourney.trimesterLabel}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.warmTaupe),
            ),
          ],
        )),
      ),
    );
  }

  Widget _buildScrollHint() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      child: Row(
        children: [
          const Icon(Icons.pinch_rounded, size: 13, color: AppColors.warmTaupe),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Drag to scroll · pinch to zoom',
            style: AppTypography.label.copyWith(color: AppColors.warmTaupe, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildBabySizeCard() {
    final currentWeek = mockJourney.currentWeek.clamp(1, 40);
    final info = pregnancyData[currentWeek - 1];

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
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
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.softGold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(info.babySizeEmoji, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('YOUR BABY THIS WEEK',
                      style: AppTypography.label.copyWith(color: AppColors.warmTaupe, fontSize: 9)),
                  const SizedBox(height: 4),
                  Text('The size of a ${info.babySize}',
                      style: AppTypography.body.copyWith(
                          color: AppColors.warmBrown, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(info.tip,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.warmTaupe),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalColumns(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TODAY\'S CHECK-IN',
              style: AppTypography.label.copyWith(color: AppColors.warmTaupe)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _JournalColumn(emoji: '🤸', title: 'Physical', subtitle: 'How\'s your body?',
                  onTap: () => _goEntry(context)),
              const SizedBox(width: AppSpacing.sm),
              _JournalColumn(emoji: '💛', title: 'Emotional', subtitle: 'Mood & thoughts',
                  onTap: () => _goEntry(context)),
              const SizedBox(width: AppSpacing.sm),
              _JournalColumn(emoji: '🩺', title: 'Medical', subtitle: 'Reminders',
                  onTap: () => _goEntry(context)),
            ],
          ),
        ],
      ),
    );
  }

  void _goEntry(BuildContext context) =>
      context.push('/week/${mockJourney.currentWeek}/entry');

  Widget _buildWeekFocus() {
    final currentWeek = mockJourney.currentWeek.clamp(1, 40);
    final info = pregnancyData[currentWeek - 1];

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
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
            Text('✨  THIS WEEK\'S FOCUS',
                style: AppTypography.label.copyWith(color: AppColors.warmBrown)),
            const SizedBox(height: AppSpacing.md),
            _FocusTip(emoji: info.babySizeEmoji, text: info.tip),
          ],
        ),
      ),
    );
  }
}

// ─── Clothesline Timeline ────────────────────────────────────────────────────

class _ClotheslineTimeline extends StatefulWidget {
  const _ClotheslineTimeline();

  @override
  State<_ClotheslineTimeline> createState() => _ClotheslineTimelineState();
}

class _ClotheslineTimelineState extends State<_ClotheslineTimeline> {
  static const double _canvasH = 200.0;
  static const double _lineY = 78.0;
  static const double _weekSpacing = 110.0;
  static const double _pinW = 88.0;

  late final ScrollController _scrollController;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentWeek());
  }

  void _scrollToCurrentWeek() {
    if (!_scrollController.hasClients) return;
    final weekX = TimelineUtils.xForWeek(mockJourney.currentWeek, _weekSpacing);
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

    return SizedBox(
      height: _canvasH,
      child: Stack(
        children: [
          // ── Scrollable content ──────────────────────────────────────
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: totalW,
              height: _canvasH,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Bands + dots + current-week gold circle
                  CustomPaint(
                    size: Size(totalW, _canvasH),
                    painter: ClotheslinePainter(
                      currentWeek: journey.currentWeek,
                      totalWeeks: journey.totalWeeks,
                      weekSpacing: _weekSpacing,
                      lineY: _lineY,
                    ),
                  ),

                  // Baby size emojis above the line — from static data
                  ...List.generate(journey.totalWeeks, (i) {
                    final week = i + 1;
                    final x = TimelineUtils.xForWeek(week, _weekSpacing);
                    final emoji = pregnancyData[i].babySizeEmoji;
                    return Positioned(
                      left: x - 14,
                      top: _lineY - 54,
                      child: Image.network(
                        _twemojiUrl(emoji),
                        width: 28,
                        height: 28,
                        errorBuilder: (_, __, ___) =>
                            Text(emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }),

                  // Week dots — tappable circles (whole dot area)
                  ...List.generate(journey.totalWeeks, (i) {
                    final week = i + 1;
                    final x = TimelineUtils.xForWeek(week, _weekSpacing);
                    final isPast = week < journey.currentWeek;
                    final isCurrent = week == journey.currentWeek;
                    return Positioned(
                      left: x - 36,
                      top: _lineY - 10,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            AppShell.of(context).openCalendarWeekDetail(week),
                        child: SizedBox(
                          width: 72,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 20), // covers dot area
                              Text(
                                'Week $week',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dancingScript(
                                  fontSize: isCurrent ? 18 : 16,
                                  fontWeight: isCurrent
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isCurrent
                                      ? AppColors.softGold
                                      : isPast
                                          ? AppColors.warmBrown
                                              .withValues(alpha: 0.75)
                                          : AppColors.warmBrown
                                              .withValues(alpha: 0.40),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Milestone pins below week labels
                  ...journey.milestones.asMap().entries.map((e) {
                    final x =
                        TimelineUtils.xForWeek(e.value.week, _weekSpacing);
                    return _MilestonePin(
                      milestone: e.value,
                      left: x - _pinW / 2,
                      top: _lineY + 38,
                      width: _pinW,
                      onTap: () => AppShell.of(context)
                          .openCalendarWeekDetail(e.value.week),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ── Fixed clothesline wire (never scrolls) ──────────────────
          Positioned(
            left: 0,
            right: 0,
            top: _lineY - 1,
            child: IgnorePointer(
              child: Container(height: 2, color: const Color(0xFF3A3A3A)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Private widgets ─────────────────────────────────────────────────────────

class _MilestonePin extends StatelessWidget {
  final Milestone milestone;
  final double left;
  final double top;
  final double width;
  final VoidCallback onTap;

  const _MilestonePin({
    required this.milestone,
    required this.left,
    required this.top,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(milestone.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                milestone.label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: milestone.reached ? AppColors.warmBrown : AppColors.sageMuted,
                  letterSpacing: 0.2,
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


class _JournalColumn extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _JournalColumn({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: AppSpacing.xs),
              Text(title,
                  style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warmBrown, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: AppTypography.label.copyWith(
                      color: AppColors.warmTaupe, fontSize: 10, letterSpacing: 0),
                  maxLines: 2),
              const SizedBox(height: AppSpacing.sm),
              Container(
                height: 2,
                decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusTip extends StatelessWidget {
  final String emoji;
  final String text;

  const _FocusTip({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(text,
              style: AppTypography.bodySmall.copyWith(color: AppColors.darkOlive)),
        ),
      ],
    );
  }
}
