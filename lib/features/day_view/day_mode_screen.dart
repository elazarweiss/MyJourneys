import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/day_entry_model.dart';
import '../../core/models/mood_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/journey_repository.dart';
import '../../data/mock_data.dart';
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

    // Pregnancy day progress (0-280)
    final conceptionDate =
        mockJourney.dueDate.subtract(const Duration(days: 280));
    final dayOfPregnancy =
        DateTime.now().difference(conceptionDate).inDays.clamp(0, 280);

    return CreamScaffold(
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: _buildHeader(week, dayIndex),
            ),
          ),

          const SliverToBoxAdapter(child: ModeSwitcher()),

          // ── Day strip ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: DayStrip(
              weekNumber: week,
              selectedDayIndex: dayIndex,
              onDayTap: (i) => shellState.focusDay(week, i),
            ),
          ),

          // ── Pregnancy progress bar ────────────────────────────────────
          SliverToBoxAdapter(
            child: _buildProgressBar(dayOfPregnancy),
          ),

          // ── Mood prompt + selectors ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
              child: _buildMoodSection(),
            ),
          ),

          // ── Journal card ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
              child: _buildJournalCard(),
            ),
          ),

          // ── Save button ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
              child: _buildSaveButton(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(int week, int dayIndex) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SerifText(_dayNames[dayIndex], fontSize: 36),
          const SizedBox(height: 2),
          Text(
            'Week $week  ·  ${mockJourney.trimesterLabel}',
            style:
                AppTypography.bodySmall.copyWith(color: AppColors.warmTaupe),
          ),
        ],
      ),
    );
  }

  // ── Pregnancy progress bar ─────────────────────────────────────────────────

  Widget _buildProgressBar(int dayOfPregnancy) {
    final progress = dayOfPregnancy / 280.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DAY $dayOfPregnancy',
                style: AppTypography.label.copyWith(
                    color: AppColors.warmTaupe, fontSize: 9),
              ),
              Text(
                'of 280',
                style: AppTypography.label.copyWith(
                    color: AppColors.warmTaupe.withValues(alpha: 0.5),
                    fontSize: 9),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  // Background
                  Container(color: AppColors.divider),
                  // Progress
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF90C48A),
                            Color(0xFFCF9850),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mood section ───────────────────────────────────────────────────────────

  Widget _buildMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What did you feel today?',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: AppColors.warmBrown,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: Mood.values.map((mood) {
            final isSelected = _selectedMood == mood;
            return GestureDetector(
              onTap: () => setState(() => _selectedMood = mood),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 58,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.sageGreen.withValues(alpha: 0.13)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
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
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(
                      mood.label,
                      style: AppTypography.label.copyWith(
                        fontSize: 8.5,
                        letterSpacing: 0,
                        color: isSelected
                            ? AppColors.sageGreen
                            : AppColors.warmTaupe,
                      ),
                      textAlign: TextAlign.center,
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
          'A QUICK NOTE',
          style: AppTypography.label.copyWith(color: AppColors.warmTaupe),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: AppColors.warmBrown.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 180,
              child: Stack(
                children: [
                  // Lined paper background
                  Positioned.fill(
                    child: CustomPaint(painter: _LinedPaperPainter()),
                  ),
                  // Text field
                  TextField(
                    controller: _noteController,
                    maxLength: 200,
                    maxLines: null,
                    expands: true,
                    style: AppTypography.body.copyWith(
                      color: AppColors.warmBrown,
                      height: 1.78,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      hintText: 'Write a thought, feeling, or moment…',
                      hintStyle: AppTypography.body.copyWith(
                        color: AppColors.warmTaupe.withValues(alpha: 0.45),
                        fontSize: 15,
                        height: 1.78,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Save button ────────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return Center(
      child: GestureDetector(
        onTap: _save,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
              horizontal: 36, vertical: AppSpacing.md - 2),
          decoration: BoxDecoration(
            color: _saved
                ? AppColors.sageGreen.withValues(alpha: 0.65)
                : AppColors.sageGreen,
            borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_saved)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child:
                      Icon(Icons.check_rounded, color: Colors.white, size: 15),
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

// ─── Lined paper painter ──────────────────────────────────────────────────────

class _LinedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8E2D9).withValues(alpha: 0.8)
      ..strokeWidth = 0.75;

    // Lines spaced to match TextField line-height: 15px * 1.78 ≈ 26.7px
    // First baseline ≈ top padding (14) + font ascent (~13) = 27px
    const double firstLine = 40.0;
    const double spacing = 26.7;
    var y = firstLine;
    while (y < size.height) {
      canvas.drawLine(Offset(12, y), Offset(size.width - 12, y), paint);
      y += spacing;
    }
  }

  @override
  bool shouldRepaint(_LinedPaperPainter _) => false;
}
