import 'package:flutter/material.dart';
import '../../core/models/mood_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/journey_repository.dart';
import '../../data/mock_data.dart';
import '../../data/pregnancy_data.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/cream_scaffold.dart';
import '../../shared/widgets/serif_text.dart';
import '../shell/app_shell.dart';
import '../shell/widgets/mode_switcher.dart';
import 'widgets/month_calendar_content.dart';

class CalendarModeScreen extends StatefulWidget {
  const CalendarModeScreen({super.key});

  @override
  State<CalendarModeScreen> createState() => _CalendarModeScreenState();
}

class _CalendarModeScreenState extends State<CalendarModeScreen> {
  // Local focused week — updated by tapping in the calendar.
  // Initialised to shellState.focusedWeek in didChangeDependencies.
  int _localFocusedWeek = mockJourney.currentWeek;
  int _localFocusedDay = DateTime.now().weekday - 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shellState = AppShell.of(context);
    // Consume request to open a specific week from the clothesline.
    if (shellState.showCalendarWeekDetail) {
      shellState.clearCalendarWeekDetailRequest();
      _localFocusedWeek = shellState.focusedWeek;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shellState = AppShell.of(context);

    return CreamScaffold(
      body: Column(
        children: [
          // ── Fixed top section ──────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const ModeSwitcher(),
                // Month grid
                MonthCalendarContent(
                  focusedWeek: _localFocusedWeek,
                  onDayTap: (week, dayIndex) {
                    // Update local focus AND shellState — stays in Calendar mode.
                    shellState.focusWeek(week);
                    shellState.focusDay(week, dayIndex);
                    setState(() {
                      _localFocusedWeek = week;
                      _localFocusedDay = dayIndex;
                    });
                  },
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.divider,
                ),
              ],
            ),
          ),

          // ── Scrollable week info panel ─────────────────────────────────
          Expanded(
            child: _WeekInfoPanel(
              weekNumber: _localFocusedWeek,
              focusedDayIndex: _localFocusedDay,
              onDayTap: (dayIndex) {
                shellState.focusDay(_localFocusedWeek, dayIndex);
                shellState.switchMode(2); // Go to Day mode
              },
              onOpenReflection: () async {
                await context.push('/week/$_localFocusedWeek/entry');
                if (mounted) setState(() {});
              },
            ),
          ),
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
      child: Row(
        children: [
          SerifText(mockJourney.name, fontSize: 24),
          const Spacer(),
          Text(
            'Week $_localFocusedWeek',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.warmTaupe,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Week Info Panel ──────────────────────────────────────────────────────────

class _WeekInfoPanel extends StatefulWidget {
  final int weekNumber;
  final int focusedDayIndex;
  final ValueChanged<int> onDayTap;
  final VoidCallback onOpenReflection;

  const _WeekInfoPanel({
    required this.weekNumber,
    required this.focusedDayIndex,
    required this.onDayTap,
    required this.onOpenReflection,
  });

  @override
  State<_WeekInfoPanel> createState() => _WeekInfoPanelState();
}

class _WeekInfoPanelState extends State<_WeekInfoPanel> {
  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static const _moodColors = {
    Mood.joyful: Color(0xFFFFD166),
    Mood.grateful: Color(0xFF8FA888),
    Mood.anxious: Color(0xFFE07A5F),
    Mood.tired: Color(0xFFB5C4B1),
    Mood.peaceful: Color(0xFF81B29A),
  };

  @override
  Widget build(BuildContext context) {
    final info = pregnancyData[widget.weekNumber.clamp(1, 40) - 1];
    final weekEntry =
        JourneyRepository.instance.getWeekEntry(widget.weekNumber);
    final dayEntries =
        JourneyRepository.instance.getDayEntriesForWeek(widget.weekNumber);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baby size card
          _BabySizeCard(info: info, weekNumber: widget.weekNumber),
          const SizedBox(height: AppSpacing.md),

          // Day strip with mood dots
          _buildDayStrip(dayEntries),
          const SizedBox(height: AppSpacing.md),

          // Weekly tip
          _buildWeekTip(info.tip),
          const SizedBox(height: AppSpacing.md),

          // Reflection section
          _buildReflectionSection(weekEntry),
        ],
      ),
    );
  }

  Widget _buildDayStrip(List<dynamic> dayEntries) {
    final todayIndex = DateTime.now().weekday - 1;
    final isCurrentWeek = widget.weekNumber == mockJourney.currentWeek;

    return Container(
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
            'WEEK ${widget.weekNumber}  ·  THIS WEEK',
            style: AppTypography.label
                .copyWith(color: AppColors.warmTaupe, fontSize: 9),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final entry = dayEntries[i];
              final hasMood = entry?.mood != null;
              final dotColor =
                  hasMood ? (_moodColors[entry!.mood!] ?? AppColors.divider) : AppColors.divider;
              final isToday = isCurrentWeek && i == todayIndex;
              final isFocused = i == widget.focusedDayIndex;

              return GestureDetector(
                onTap: () => widget.onDayTap(i),
                child: Column(
                  children: [
                    Text(
                      _dayLabels[i],
                      style: AppTypography.label.copyWith(
                        fontSize: 9,
                        color: isToday
                            ? AppColors.softGold
                            : AppColors.warmTaupe,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: hasMood
                            ? dotColor.withValues(alpha: 0.25)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isToday
                              ? AppColors.softGold
                              : isFocused
                                  ? AppColors.sageGreen
                                  : hasMood
                                      ? dotColor
                                      : AppColors.divider,
                          width: (isToday || isFocused) ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: hasMood
                            ? Text(entry!.mood!.emoji,
                                style: const TextStyle(fontSize: 13))
                            : Icon(
                                Icons.add,
                                size: 11,
                                color: isToday
                                    ? AppColors.softGold
                                    : AppColors.warmTaupe,
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
    );
  }

  Widget _buildWeekTip(String tip) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.sageGreen.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
            color: AppColors.sageGreen.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✨', style: const TextStyle(fontSize: 14)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              tip,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.darkOlive),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionSection(dynamic weekEntry) {
    final hasEntry = weekEntry != null;
    final text = weekEntry?.journalText as String?;
    final mood = weekEntry?.mood as Mood?;

    return GestureDetector(
      onTap: widget.onOpenReflection,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: hasEntry
              ? AppColors.surface
              : AppColors.sageGreen.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: hasEntry
                ? AppColors.divider
                : AppColors.sageGreen.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            if (mood != null)
              Text(mood.emoji, style: const TextStyle(fontSize: 20)),
            if (mood != null) const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasEntry ? 'WEEKLY REFLECTION' : 'WRITE A REFLECTION',
                    style: AppTypography.label.copyWith(
                      color: hasEntry
                          ? AppColors.warmTaupe
                          : AppColors.sageGreen,
                      fontSize: 9,
                    ),
                  ),
                  if (text != null && text.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      text.length > 90 ? '${text.substring(0, 90)}…' : text,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.darkOlive),
                    ),
                  ] else ...[
                    const SizedBox(height: 2),
                    Text(
                      'How was your week? Tap to write…',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.warmTaupe
                              .withValues(alpha: 0.7)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              hasEntry ? Icons.edit_outlined : Icons.add,
              size: 16,
              color:
                  hasEntry ? AppColors.warmTaupe : AppColors.sageGreen,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Baby Size Card ───────────────────────────────────────────────────────────

class _BabySizeCard extends StatelessWidget {
  final dynamic info;
  final int weekNumber;

  const _BabySizeCard({required this.info, required this.weekNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: AppColors.softGold.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(info.babySizeEmoji,
                  style: const TextStyle(fontSize: 28)),
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
                      color: AppColors.warmTaupe, fontSize: 8),
                ),
                const SizedBox(height: 4),
                Text(
                  'The size of a ${info.babySize}',
                  style: AppTypography.body.copyWith(
                    color: AppColors.warmBrown,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
