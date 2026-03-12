import 'package:flutter/material.dart';
import '../../core/models/day_entry_model.dart';
import '../../core/models/mood_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/journey_repository.dart';
import '../../shared/widgets/cream_scaffold.dart';
import '../../shared/widgets/serif_text.dart';
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
  bool _saved = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shellState = AppShell.of(context);
    final week = shellState.focusedDayWeek;
    final dayIndex = shellState.focusedDayIndex;
    if (week != _loadedWeek || dayIndex != _loadedDayIndex) {
      _loadedWeek = week;
      _loadedDayIndex = dayIndex;
      _saved = false;
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
    FocusScope.of(context).unfocus();
    setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    final shellState = AppShell.of(context);
    final week = shellState.focusedDayWeek;
    final dayIndex = shellState.focusedDayIndex;

    return CreamScaffold(
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: _buildHeader(week, dayIndex),
            ),
          ),
          const SliverToBoxAdapter(child: ModeSwitcher()),
          SliverToBoxAdapter(
            child: DayStrip(
              weekNumber: week,
              selectedDayIndex: dayIndex,
              onDayTap: (i) => shellState.focusDay(week, i),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMoodRow(),
                const SizedBox(height: AppSpacing.md),
                _buildJournalCard(),
                const SizedBox(height: AppSpacing.lg),
                _buildSaveButton(),
                const SizedBox(height: AppSpacing.xxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int week, int dayIndex) {
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
          SerifText(_dayNames[dayIndex], fontSize: 34),
          const SizedBox(height: 2),
          Text(
            'Week $week  ·  Daily Check-In',
            style:
                AppTypography.bodySmall.copyWith(color: AppColors.warmTaupe),
          ),
        ],
      ),
    );
  }

  // ── Compact mood row ──────────────────────────────────────────────────────

  Widget _buildMoodRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOW ARE YOU FEELING?',
          style: AppTypography.label.copyWith(color: AppColors.warmTaupe),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: Mood.values.map((mood) {
            final bool isSelected = _selectedMood == mood;
            return GestureDetector(
              onTap: () => setState(() => _selectedMood = mood),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.sageGreen.withValues(alpha: 0.12)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.sageGreen
                        : AppColors.divider,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(mood.emoji,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 3),
                    Text(
                      mood.label,
                      style: AppTypography.label.copyWith(
                        fontSize: 8.5,
                        letterSpacing: 0,
                        color: isSelected
                            ? AppColors.sageGreen
                            : AppColors.warmTaupe,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Lined-paper journal card ───────────────────────────────────────────────

  Widget _buildJournalCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TODAY\'S NOTE',
          style: AppTypography.label.copyWith(color: AppColors.warmTaupe),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.divider),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            child: Stack(
              children: [
                // Lined paper background
                CustomPaint(
                  painter: _LinedPaperPainter(),
                  child: const SizedBox(width: double.infinity, height: 160),
                ),
                // TextField overlay
                Positioned.fill(
                  child: TextField(
                    controller: _noteController,
                    maxLength: 200,
                    maxLines: null,
                    expands: true,
                    style: AppTypography.body.copyWith(
                      color: AppColors.warmBrown,
                      height: 1.75,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      hintText: 'Write a thought, feeling, or moment…',
                      hintStyle: AppTypography.body.copyWith(
                        color: AppColors.warmTaupe.withValues(alpha: 0.5),
                        fontSize: 15,
                        height: 1.75,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Save button ───────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return Center(
      child: GestureDetector(
        onTap: _save,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md - 2,
          ),
          decoration: BoxDecoration(
            color: _saved
                ? AppColors.sageGreen.withValues(alpha: 0.75)
                : AppColors.sageGreen,
            borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_saved)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.check, color: Colors.white, size: 14),
                ),
              Text(
                _saved ? 'Saved' : 'Save Check-In',
                style: AppTypography.label.copyWith(
                  color: Colors.white,
                  letterSpacing: 0.8,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Lined paper custom painter ───────────────────────────────────────────────

class _LinedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.7)
      ..strokeWidth = 0.8;

    // Draw horizontal lines spaced to match 1.75 line height at fontSize 15
    // ≈ 26.25px per line. Start from first baseline.
    const lineSpacing = 27.0;
    const firstLine = 46.0; // First ruled line position
    var y = firstLine;
    while (y < size.height) {
      canvas.drawLine(
        Offset(16, y),
        Offset(size.width - 16, y),
        paint,
      );
      y += lineSpacing;
    }
  }

  @override
  bool shouldRepaint(_LinedPaperPainter old) => false;
}
