import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/mood_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/journey_repository.dart';
import '../../data/mock_data.dart';
import '../../data/pregnancy_data.dart';
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
  int _localFocusedWeek = mockJourney.currentWeek;
  int _localFocusedDay = DateTime.now().weekday - 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shellState = AppShell.of(context);
    if (shellState.showCalendarWeekDetail) {
      shellState.clearCalendarWeekDetailRequest();
      _localFocusedWeek = shellState.focusedWeek;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shellState = AppShell.of(context);
    final info = pregnancyData[_localFocusedWeek.clamp(1, 40) - 1];
    final weekEntry =
        JourneyRepository.instance.getWeekEntry(_localFocusedWeek);
    final dayEntries =
        JourneyRepository.instance.getDayEntriesForWeek(_localFocusedWeek);

    return CreamScaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // ── Centered header ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                    child: Center(
                      child: Column(
                        children: [
                          SerifText(
                            '$_localFocusedWeek Weeks',
                            fontSize: 32,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            mockJourney.trimesterLabel,
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.warmTaupe),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const ModeSwitcher(),
                ],
              ),
            ),
          ),

          // ── Centred calendar card ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.divider),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.warmBrown.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: MonthCalendarContent(
                    focusedWeek: _localFocusedWeek,
                    onDayTap: (week, dayIndex) {
                      shellState.focusWeek(week);
                      shellState.focusDay(week, dayIndex);
                      setState(() {
                        _localFocusedWeek = week;
                        _localFocusedDay = dayIndex;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),

          // ── Baby size card ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
              child: _BabySizeCard(info: info),
            ),
          ),

          // ── Day strip ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
              child: _DayStripCard(
                weekNumber: _localFocusedWeek,
                focusedDayIndex: _localFocusedDay,
                dayEntries: dayEntries,
                onDayTap: (i) {
                  shellState.focusDay(_localFocusedWeek, i);
                  shellState.switchMode(2); // Go to Day mode
                },
              ),
            ),
          ),

          // ── Reflection card ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
              child: _ReflectionCard(
                weekEntry: weekEntry,
                onTap: () async {
                  await context.push('/week/$_localFocusedWeek/entry');
                  if (mounted) setState(() {});
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }
}

// ─── Baby Size Card ───────────────────────────────────────────────────────────

class _BabySizeCard extends StatelessWidget {
  final dynamic info;
  const _BabySizeCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.softGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.softGold.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.softGold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(info.babySizeEmoji,
                  style: const TextStyle(fontSize: 26)),
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
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  info.tip,
                  style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warmTaupe, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Day Strip Card ───────────────────────────────────────────────────────────

class _DayStripCard extends StatelessWidget {
  final int weekNumber;
  final int focusedDayIndex;
  final List dayEntries;
  final ValueChanged<int> onDayTap;

  const _DayStripCard({
    required this.weekNumber,
    required this.focusedDayIndex,
    required this.dayEntries,
    required this.onDayTap,
  });

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
    final todayIndex = DateTime.now().weekday - 1;
    final isCurrentWeek = weekNumber == mockJourney.currentWeek;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEK $weekNumber  ·  DAILY CHECK-INS',
            style: AppTypography.label
                .copyWith(color: AppColors.warmTaupe, fontSize: 9),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final entry = dayEntries[i];
              final hasMood = entry?.mood != null;
              final dotColor = hasMood
                  ? (_moodColors[entry!.mood!] ?? AppColors.divider)
                  : AppColors.divider;
              final isToday = isCurrentWeek && i == todayIndex;

              return GestureDetector(
                onTap: () => onDayTap(i),
                child: Column(
                  children: [
                    Text(
                      _dayLabels[i],
                      style: AppTypography.label.copyWith(
                        fontSize: 9,
                        color:
                            isToday ? AppColors.softGold : AppColors.warmTaupe,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: hasMood
                            ? dotColor.withValues(alpha: 0.22)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isToday
                              ? AppColors.softGold
                              : hasMood
                                  ? dotColor
                                  : AppColors.divider,
                          width: isToday ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: hasMood
                            ? Text(entry!.mood!.emoji,
                                style: const TextStyle(fontSize: 14))
                            : Icon(Icons.add,
                                size: 12,
                                color: isToday
                                    ? AppColors.softGold
                                    : AppColors.warmTaupe),
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
}

// ─── Reflection Card ──────────────────────────────────────────────────────────

class _ReflectionCard extends StatelessWidget {
  final dynamic weekEntry;
  final VoidCallback onTap;

  const _ReflectionCard({required this.weekEntry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasEntry = weekEntry != null;
    final text = weekEntry?.journalText as String?;
    final mood = weekEntry?.mood as Mood?;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: hasEntry
              ? AppColors.surface
              : AppColors.sageGreen.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasEntry
                ? AppColors.divider
                : AppColors.sageGreen.withValues(alpha: 0.4),
          ),
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
                    hasEntry ? 'WEEKLY REFLECTION' : 'WRITE A REFLECTION',
                    style: AppTypography.label.copyWith(
                      color: hasEntry
                          ? AppColors.warmTaupe
                          : AppColors.sageGreen,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (text != null && text.isNotEmpty)
                        ? (text.length > 90
                            ? '${text.substring(0, 90)}…'
                            : text)
                        : 'How was your week? Tap to write…',
                    style: AppTypography.bodySmall.copyWith(
                      color: (text != null && text.isNotEmpty)
                          ? AppColors.darkOlive
                          : AppColors.warmTaupe.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              hasEntry ? Icons.edit_outlined : Icons.add,
              size: 16,
              color: hasEntry ? AppColors.warmTaupe : AppColors.sageGreen,
            ),
          ],
        ),
      ),
    );
  }
}
