import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/mood_model.dart';
import '../../core/models/week_entry_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/journey_repository.dart';
import '../../data/mock_data.dart';
import '../../shared/widgets/cream_scaffold.dart';
import '../../shared/widgets/serif_text.dart';
import '../daily_entry/widgets/journal_card.dart';
import '../daily_entry/widgets/mood_selector.dart';
import '../daily_entry/widgets/photo_card.dart';

class WeeklyReflectionScreen extends StatefulWidget {
  final int weekNumber;

  const WeeklyReflectionScreen({super.key, required this.weekNumber});

  @override
  State<WeeklyReflectionScreen> createState() =>
      _WeeklyReflectionScreenState();
}

class _WeeklyReflectionScreenState extends State<WeeklyReflectionScreen> {
  late final TextEditingController _journalController;
  Mood? _selectedMood;

  @override
  void initState() {
    super.initState();
    final entry = JourneyRepository.instance.getWeekEntry(widget.weekNumber);
    _journalController = TextEditingController(text: entry?.journalText ?? '');
    if (entry != null) {
      _selectedMood = entry.mood;
    } else {
      // Default to most common daily mood from check-ins this week
      _selectedMood = _dominantDailyMood();
    }
  }

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  /// Returns the most common mood from this week's daily check-ins, or null.
  Mood? _dominantDailyMood() {
    final dayEntries = JourneyRepository.instance
        .getDayEntriesForWeek(widget.weekNumber)
        .where((e) => e?.mood != null)
        .map((e) => e!.mood!)
        .toList();
    if (dayEntries.isEmpty) return null;
    final counts = <Mood, int>{};
    for (final m in dayEntries) {
      counts[m] = (counts[m] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String _headerLabel() {
    final date = mockJourney.dueDate.subtract(
      Duration(days: (mockJourney.totalWeeks - widget.weekNumber) * 7),
    );
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}  ·  Week ${widget.weekNumber}';
  }

  void _save() {
    final entry = WeekEntry(
      week: widget.weekNumber,
      mood: _selectedMood,
      journalText: _journalController.text.trim().isEmpty
          ? null
          : _journalController.text.trim(),
      photoPaths: JourneyRepository.instance
              .getWeekEntry(widget.weekNumber)
              ?.photoPaths ??
          const [],
      updatedAt: DateTime.now(),
    );
    JourneyRepository.instance.saveWeekEntry(entry);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reflection saved ✨')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CreamScaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                PhotoCard(assetPath: null, onTap: () {}),
                const SizedBox(height: AppSpacing.md),
                _buildJournalCard(),
                const SizedBox(height: AppSpacing.lg),
                MoodSelector(
                  selectedMood: _selectedMood,
                  onMoodSelected: (m) => setState(() => _selectedMood = m),
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildSaveButton(),
                const SizedBox(height: AppSpacing.xxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          0,
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppColors.warmBrown,
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SerifText(_headerLabel(), fontSize: 20),
                  Text(
                    'Weekly Reflection',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.warmTaupe),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: JournalCard(controller: _journalController),
    );
  }

  Widget _buildSaveButton() {
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
            'Save Reflection',
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
