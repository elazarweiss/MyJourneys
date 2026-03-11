import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/day_entry_model.dart';
import '../../core/models/mood_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/journey_repository.dart';
import '../../shared/widgets/cream_scaffold.dart';
import '../../shared/widgets/serif_text.dart';
import '../daily_entry/widgets/mood_selector.dart';

class DailyCheckInScreen extends StatefulWidget {
  final int weekNumber;
  final int dayIndex; // 0=Mon … 6=Sun

  const DailyCheckInScreen({
    super.key,
    required this.weekNumber,
    required this.dayIndex,
  });

  @override
  State<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends State<DailyCheckInScreen> {
  late final TextEditingController _noteController;
  Mood? _selectedMood;

  static const _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    final existing = JourneyRepository.instance
        .getDayEntry(widget.weekNumber, widget.dayIndex);
    _selectedMood = existing?.mood;
    _noteController =
        TextEditingController(text: existing?.quickNote ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final entry = DayEntry(
      week: widget.weekNumber,
      dayIndex: widget.dayIndex,
      date: DateTime.now(),
      mood: _selectedMood,
      quickNote:
          _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );
    JourneyRepository.instance.saveDayEntry(entry);
    if (mounted) context.pop();
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
                MoodSelector(
                  selectedMood: _selectedMood,
                  onMoodSelected: (m) => setState(() => _selectedMood = m),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildNoteField(),
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
                  SerifText(
                    _dayNames[widget.dayIndex],
                    fontSize: 22,
                  ),
                  Text(
                    'Week ${widget.weekNumber}  ·  Daily Check-In',
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
              hintStyle: AppTypography.body.copyWith(
                color: AppColors.warmTaupe.withOpacity(0.6),
              ),
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
            'Save Check-In',
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
