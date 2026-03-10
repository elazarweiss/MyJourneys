import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/milestone_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/timeline_utils.dart';
import '../../data/mock_data.dart';
import '../../shared/widgets/cream_scaffold.dart';
import '../../shared/widgets/serif_text.dart';
import 'widgets/clothesline_painter.dart';

class JourneyOverviewScreen extends StatefulWidget {
  const JourneyOverviewScreen({super.key});

  @override
  State<JourneyOverviewScreen> createState() => _JourneyOverviewScreenState();
}

class _JourneyOverviewScreenState extends State<JourneyOverviewScreen> {
  static const double _weekSpacing = 56.0;
  static const double _canvasHeight = 310.0;
  static const double _lineY = 150.0;
  static const double _pinW = 72.0;
  static const double _iconH = 52.0; // emoji(20) + gap(4) + label(~28)
  static const double _dotR = 5.0;
  static const double _currentDotR = 10.0;
  static const double _slotSize = 44.0;

  // Scatter layout per milestone index: (isAbove, extraVerticalOffset)
  // Matches mock_data milestone order: weeks 8, 12, 18, 20, 28, 36, 40
  static const _layouts = [
    (true,  10.0),  // 0: week 8  — above, moderate
    (false,  0.0),  // 1: week 12 — below, close
    (true,  28.0),  // 2: week 18 — above, high
    (false, 22.0),  // 3: week 20 — below, far
    (true,  18.0),  // 4: week 28 — above, mid-high
    (true,   5.0),  // 5: week 36 — above, close (current)
    (false, 12.0),  // 6: week 40 — below, moderate
  ];

  late final TransformationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerOnCurrentWeek());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _centerOnCurrentWeek() {
    if (!mounted) return;
    final screenW = MediaQuery.of(context).size.width;
    final weekX = TimelineUtils.xForWeek(mockJourney.currentWeek, _weekSpacing);
    _controller.value = Matrix4.identity()..translate(screenW / 2 - weekX, 0.0);
  }

  // y-top of the floating icon group for milestone at [index]
  double _iconTop(int index) {
    final (isAbove, extraH) = _layouts[index];
    final isCurrent = mockJourney.milestones[index].week == mockJourney.currentWeek;
    final dr = isCurrent ? _currentDotR : _dotR;
    return isAbove
        ? _lineY - dr - 6.0 - _iconH - extraH
        : _lineY + dr + 4.0 + extraH;
  }

  // y-top of the photo slot for milestone at [index]
  double _slotTop(int index) {
    final (isAbove, _) = _layouts[index];
    final iconTop = _iconTop(index);
    return isAbove ? iconTop - _slotSize - 5.0 : iconTop + _iconH + 5.0;
  }

  @override
  Widget build(BuildContext context) {
    final journey = mockJourney;
    final double canvasWidth =
        TimelineUtils.xForWeek(journey.totalWeeks, _weekSpacing) + _weekSpacing;

    return CreamScaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildTimeline(canvasWidth)),
          SliverToBoxAdapter(child: _buildScrollHint()),
          SliverToBoxAdapter(child: _buildBabySizeCard()),
          SliverToBoxAdapter(child: _buildJournalColumns()),
          SliverToBoxAdapter(child: _buildWeekFocus()),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }

  Widget _buildTimeline(double canvasWidth) {
    final journey = mockJourney;
    return SizedBox(
      height: _canvasHeight,
      child: InteractiveViewer(
        transformationController: _controller,
        constrained: false,
        minScale: 0.25,
        maxScale: 5.0,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        child: SizedBox(
          width: canvasWidth,
          height: _canvasHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Clothesline: bands + wire + ticks
              CustomPaint(
                size: Size(canvasWidth, _canvasHeight),
                painter: ClotheslinePainter(
                  currentWeek: journey.currentWeek,
                  totalWeeks: journey.totalWeeks,
                  weekSpacing: _weekSpacing,
                  lineY: _lineY,
                ),
              ),

              // 2. Photo slots (behind milestone icons)
              ...journey.milestones.asMap().entries.map((e) {
                final x = TimelineUtils.xForWeek(e.value.week, _weekSpacing);
                return _PhotoSlot(
                  left: x - _slotSize / 2,
                  top: _slotTop(e.key),
                  size: _slotSize,
                  hasEntry: journey.entryForWeek(e.value.week) != null,
                  onTap: () => context.push('/week/${e.value.week}/entry'),
                );
              }),

              // 3. Milestone icons (floating above/below wire)
              ...journey.milestones.asMap().entries.map((e) {
                final x = TimelineUtils.xForWeek(e.value.week, _weekSpacing);
                return _MilestonePin(
                  milestone: e.value,
                  left: x - _pinW / 2,
                  top: _iconTop(e.key),
                  width: _pinW,
                  onTap: () => context.push('/week/${e.value.week}'),
                );
              }),

              // 4. Transparent tap targets over every week dot
              ...List.generate(journey.totalWeeks, (i) {
                final week = i + 1;
                final x = TimelineUtils.xForWeek(week, _weekSpacing);
                return Positioned(
                  left: x - 22,
                  top: _lineY - 22,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.push('/week/$week'),
                    child: const SizedBox(width: 44, height: 44),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SerifText(mockJourney.name, fontSize: 30),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Week ${mockJourney.currentWeek} of ${mockJourney.totalWeeks}  ·  ${mockJourney.trimesterLabel}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.warmTaupe),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollHint() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          const Icon(Icons.pinch_rounded, size: 13, color: AppColors.warmTaupe),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Pinch to zoom · drag to explore',
            style: AppTypography.label.copyWith(
              color: AppColors.warmTaupe,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBabySizeCard() {
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
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.softGold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🍈', style: TextStyle(fontSize: 28)),
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
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warmTaupe,
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

  Widget _buildJournalColumns() {
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
            'TODAY\'S CHECK-IN',
            style: AppTypography.label.copyWith(color: AppColors.warmTaupe),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _JournalColumn(
                emoji: '🤸',
                title: 'Physical',
                subtitle: 'How\'s your body?',
                onTap: () => context.push('/week/${mockJourney.currentWeek}/entry'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _JournalColumn(
                emoji: '💛',
                title: 'Emotional',
                subtitle: 'Mood & thoughts',
                onTap: () => context.push('/week/${mockJourney.currentWeek}/entry'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _JournalColumn(
                emoji: '🩺',
                title: 'Medical',
                subtitle: 'Reminders',
                onTap: () => context.push('/week/${mockJourney.currentWeek}/entry'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekFocus() {
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
            _FocusTip(
              emoji: '🌿',
              text: 'Rest when you can — your body is doing incredible work.',
            ),
            const SizedBox(height: AppSpacing.sm),
            _FocusTip(
              emoji: '💧',
              text: 'Stay hydrated and keep up gentle movement.',
            ),
            const SizedBox(height: AppSpacing.sm),
            _FocusTip(
              emoji: '📋',
              text: 'Review your birth plan and pack your hospital bag.',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Private widgets ────────────────────────────────────────────────────────

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
                  color: milestone.reached
                      ? AppColors.warmBrown
                      : AppColors.sageMuted,
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

class _PhotoSlot extends StatelessWidget {
  final double left;
  final double top;
  final double size;
  final bool hasEntry;
  final VoidCallback onTap;

  const _PhotoSlot({
    required this.left,
    required this.top,
    required this.size,
    required this.hasEntry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: hasEntry
                ? AppColors.softGold.withValues(alpha: 0.15)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasEntry
                  ? AppColors.softGold.withValues(alpha: 0.5)
                  : AppColors.divider,
              width: 1.0,
            ),
          ),
          child: Center(
            child: Text(
              hasEntry ? '🖼️' : '📷',
              style: TextStyle(fontSize: hasEntry ? 18 : 14),
            ),
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
              Text(
                title,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.warmBrown,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.label.copyWith(
                  color: AppColors.warmTaupe,
                  fontSize: 10,
                  letterSpacing: 0,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(1),
                ),
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
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(color: AppColors.darkOlive),
          ),
        ),
      ],
    );
  }
}
