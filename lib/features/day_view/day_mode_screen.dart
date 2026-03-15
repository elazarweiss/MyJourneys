import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/day_entry_model.dart';
import '../../core/models/mood_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/journey_repository.dart';
import '../../data/mock_data.dart';
import '../../data/pregnancy_data.dart';
import '../../shared/widgets/cream_scaffold.dart';
import '../shell/app_shell.dart';
import '../shell/widgets/mode_switcher.dart';
import 'widgets/day_strip.dart';
import 'widgets/mood_card.dart';
import 'widgets/photo_card.dart';
import 'widgets/stats_pill_row.dart';

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

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _noteController.addListener(() => setState(() {}));
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

  String _formatDate(DateTime date) {
    return '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final shellState = AppShell.of(context);
    final week = shellState.focusedDayWeek;
    final dayIndex = shellState.focusedDayIndex;

    final conceptionDate =
        mockJourney.dueDate.subtract(const Duration(days: 280));
    final dayOfPregnancy =
        DateTime.now().difference(conceptionDate).inDays.clamp(0, 280);

    final info = pregnancyData[(week.clamp(1, 40)) - 1];
    final now = DateTime.now();

    return CreamScaffold(
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: _buildHeader(dayIndex, now),
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

          // ── Stats pill row ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, 0),
              child: StatsPillRow(
                dayOfPregnancy: dayOfPregnancy,
                weekNumber: week,
                babyEmoji: info.babySizeEmoji,
                babySize: info.babySize,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

          // ── Mood card ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: MoodCard(
                selectedMood: _selectedMood,
                onMoodSelected: (mood) => setState(() {
                  _selectedMood = mood;
                  _saved = false;
                }),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

          // ── Journal card ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _buildJournalCard(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

          // ── Photo card ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: const PhotoCard(),
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

  Widget _buildHeader(int dayIndex, DateTime now) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _dayNames[dayIndex],
            style: GoogleFonts.playfairDisplay(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              color: AppColors.warmBrown,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatDate(now),
            style: AppTypography.bodySmall.copyWith(color: AppColors.warmTaupe),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalCard() {
    final charCount = _noteController.text.length;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmBrown.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
            child: Row(
              children: [
                Icon(Icons.menu_book_outlined,
                    size: 14, color: AppColors.sageGreen),
                const SizedBox(width: 6),
                Text(
                  'MY NOTES',
                  style: AppTypography.label.copyWith(
                    color: AppColors.sageGreen,
                    fontSize: 9,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                Text(
                  '$charCount / 200',
                  style: AppTypography.label.copyWith(
                    color: AppColors.warmTaupe.withOpacity(0.6),
                    fontSize: 9,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          // Lined paper text area
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20)),
            child: SizedBox(
              height: 200,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _LinedPaperPainter()),
                  ),
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
                      contentPadding:
                          const EdgeInsets.fromLTRB(40, 14, 16, 12),
                      hintText: 'Write a thought, feeling, or moment\u2026',
                      hintStyle: AppTypography.body.copyWith(
                        color: AppColors.warmTaupe.withOpacity(0.45),
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
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: GestureDetector(
        onTap: _save,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
              horizontal: 40, vertical: AppSpacing.md - 2),
          decoration: BoxDecoration(
            gradient: _saved
                ? null
                : const LinearGradient(
                    colors: [Color(0xFF8FA888), Color(0xFF6E9B67)],
                  ),
            color: _saved
                ? AppColors.sageGreen.withOpacity(0.65)
                : null,
            borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
            boxShadow: _saved
                ? null
                : [
                    BoxShadow(
                      color: AppColors.sageGreen.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_saved)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.check_rounded,
                      color: Colors.white, size: 15),
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
    final linePaint = Paint()
      ..color = const Color(0xFFE8E2D9).withOpacity(0.8)
      ..strokeWidth = 0.75;

    // Vertical margin line at x=32, soft pink
    final marginPaint = Paint()
      ..color = const Color(0xFFE8C4C4).withOpacity(0.50)
      ..strokeWidth = 1.0;

    canvas.drawLine(
        Offset(32, 0), Offset(32, size.height), marginPaint);

    const double firstLine = 40.0;
    const double spacing = 26.7;
    var y = firstLine;
    while (y < size.height) {
      canvas.drawLine(Offset(12, y), Offset(size.width - 12, y), linePaint);
      y += spacing;
    }
  }

  @override
  bool shouldRepaint(_LinedPaperPainter _) => false;
}
