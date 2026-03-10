import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/mood_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/mock_data.dart';
import '../../shared/widgets/cream_scaffold.dart';
import '../../shared/widgets/serif_text.dart';
import 'widgets/journal_card.dart';
import 'widgets/mood_selector.dart';
import 'widgets/photo_card.dart';

class DailyEntryScreen extends StatefulWidget {
  final int weekNumber;

  const DailyEntryScreen({super.key, required this.weekNumber});

  @override
  State<DailyEntryScreen> createState() => _DailyEntryScreenState();
}

class _DailyEntryScreenState extends State<DailyEntryScreen> {
  late final TextEditingController _journalController;
  Mood? _selectedMood;

  @override
  void initState() {
    super.initState();
    final entry = mockJourney.entryForWeek(widget.weekNumber);
    _journalController = TextEditingController(text: entry?.journalText ?? '');
    _selectedMood = entry?.mood;
  }

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  String _dateHeader() {
    final entry = mockJourney.entryForWeek(widget.weekNumber);
    final date = entry?.date ?? mockJourney.dueDate.subtract(
      Duration(days: (mockJourney.totalWeeks - widget.weekNumber) * 7),
    );
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}  ·  Week ${widget.weekNumber}';
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry saved ✨')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = mockJourney.entryForWeek(widget.weekNumber);

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
                PhotoCard(
                  assetPath: entry?.photoAssetPath,
                  onTap: () {},
                ),
                const SizedBox(height: AppSpacing.md),
                JournalCard(controller: _journalController),
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
              child: SerifText(_dateHeader(), fontSize: 20),
            ),
          ],
        ),
      ),
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
            'Save Entry',
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
