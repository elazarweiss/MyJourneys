import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/mock_data.dart';
import '../../shared/widgets/cream_scaffold.dart';
import '../../shared/widgets/serif_text.dart';
import '../shell/app_shell.dart';
import '../shell/shell_navigation_state.dart';
import '../shell/widgets/mode_switcher.dart';
import 'widgets/month_calendar_content.dart';
import 'widgets/week_detail_content.dart';

class CalendarModeScreen extends StatefulWidget {
  const CalendarModeScreen({super.key});

  @override
  State<CalendarModeScreen> createState() => _CalendarModeScreenState();
}

class _CalendarModeScreenState extends State<CalendarModeScreen> {
  bool _showingWeekDetail = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shellState = AppShell.of(context);
    if (shellState.showCalendarWeekDetail) {
      shellState.clearCalendarWeekDetailRequest();
      _showingWeekDetail = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shellState = AppShell.of(context);

    return CreamScaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(shellState)),
          const SliverToBoxAdapter(child: ModeSwitcher()),
          if (_showingWeekDetail) ...[
            SliverToBoxAdapter(
              child: _WeekDetailHeader(
                weekNumber: shellState.focusedWeek,
                onBack: () => setState(() => _showingWeekDetail = false),
              ),
            ),
            SliverToBoxAdapter(
              child: WeekDetailContent(weekNumber: shellState.focusedWeek),
            ),
          ] else ...[
            SliverToBoxAdapter(
              child: MonthCalendarContent(
                onWeekTap: (week) {
                  shellState.focusWeek(week);
                  setState(() => _showingWeekDetail = true);
                },
                onDayTap: (week, dayIndex) {
                  shellState.focusDay(week, dayIndex);
                  shellState.switchMode(2);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(ShellNavigationState shellState) {
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
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.warmTaupe),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small header shown above the inline week detail in Calendar mode.
class _WeekDetailHeader extends StatelessWidget {
  final int weekNumber;
  final VoidCallback onBack;

  const _WeekDetailHeader({required this.weekNumber, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: AppColors.warmBrown,
            onPressed: onBack,
          ),
          SerifText('Week $weekNumber', fontSize: 22),
        ],
      ),
    );
  }
}
