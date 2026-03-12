import 'package:flutter/material.dart';
import '../../core/models/day_entry_model.dart';
import '../../core/models/mood_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/journey_repository.dart';
import '../../shared/widgets/cream_scaffold.dart';
import '../../shared/widgets/serif_text.dart';
import '../daily_entry/widgets/mood_selector.dart';
import '../shell/app_shell.dart';
import '../shell/widgets/mode_switcher.dart';
import 'widgets/day_strip.dart';

class DayModeScreen extends StatefulWidget {
  const DayModeScreen({super.key});

  @override
  State<DayModeScreen> createState() => _DayModeScreenState();
}

class _DayModeScreenState extends State<DayModeScreen> {
  late final TextEditingController _noteController;
  Mood? _selectedMood;
  int _loadedWeek = -1;
  int _loadedDayIndex = -1;

  static const _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// Called whenever the InheritedNotifier changes (and before each build).
  /// Reloads the entry data if the focused day has changed.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shellState = AppShell.of(context);
    final week = shellState.focusedDayWeek;
    final dayIndex = shellState.focusedDayIndex;

    if (week != _loadedWeek || dayIndex != _loadedDayIndex) {
      _loadedWeek = week;
      _loadedDayIndex = dayIndex;
      final entry = JourneyRepository.instance.getDayEntry(week, dayIndex);
      _selectedMood = entry?.mood;
      _noteController.text = entry?.quickNote ?? '';
    }
  }

  void _save() {
    final entry = DayEntry(
      week: _loadedWeek,
      dayIndex: _loadedDayIndex,
      date: DateTime.now(),
      mood: _selectedMood,
      quickNote: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    JourneyRepository.instance.saveDayEntry(entry);
    setState(() {}); // Refresh the save button label
  }

  @override
  Widget build(BuildContext context) {
    final shellState = AppShell.of(context);
    final week = shellState.focusedDayWeek;
    final dayIndex = shellState.focusedDayIndex;

    return CreamScaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(week, dayIndex)),
          const SliverToBoxAdapter(child: ModeSwitcher()),
          SliverToBoxAdapter(
            child: DayStrip(
              weekNumber: week,
              selectedDayIndex: dayIndex,
              onDayTap: (i) {
                shellState.focusDay(week, i);
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                MoodSelector(
                  selectedMood: _selectedMood,
                  onMoodSelected: (m) => setState(() => _selectedMood = m),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildNoteField(),
                const SizedBox(height: AppSpacing.lg),
                _buildSaveButton(week, dayIndex),
                const SizedBox(height: AppSpacing.xxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int week, int dayIndex) {
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
            SerifText(_dayNames[dayIndex], fontSize: 30),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Week $week  ·  Daily Check-In',
              style:
                  AppTypography.bodySmall.copyWith(color: AppColors.warmTaupe),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
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
            'A QUICK NOTE',
            style: AppTypography.label.copyWith(color: AppColors.warmTaupe),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _noteController,
            maxLength: 80,
            maxLines: 1,
            style: AppTypography.body.copyWith(color: AppColors.warmBrown),
            decoration: InputDecoration(
              hintText: 'One thought from today…',
              hintStyle: AppTypography.body
                  .copyWith(color: AppColors.warmTaupe.withOpacity(0.6)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              counterStyle: AppTypography.label.copyWith(
                color: AppColors.warmTaupe,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(int week, int dayIndex) {
    final existing =
        JourneyRepository.instance.getDayEntry(week, dayIndex);
    final hasExisting = existing != null;

    return Center(
      child: GestureDetector(
        onTap: _save,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.sageGreen,
            borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
          ),
          child: Text(
            hasExisting ? 'Update Check-In' : 'Save Check-In',
            style: AppTypography.label.copyWith(
              color: Colors.white,
              letterSpacing: 1.0,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
