import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/trimester_utils.dart';
import '../../data/mock_data.dart';
import '../../shared/widgets/cream_scaffold.dart';
import '../../shared/widgets/serif_text.dart';
import '../calendar/widgets/week_detail_content.dart';

class WeekDetailScreen extends StatelessWidget {
  final int weekNumber;

  const WeekDetailScreen({super.key, required this.weekNumber});

  String _dateLabelForWeek() {
    final date = mockJourney.dueDate.subtract(
      Duration(days: (mockJourney.totalWeeks - weekNumber) * 7),
    );
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return CreamScaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: WeekDetailContent(weekNumber: weekNumber)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.lg,
          0,
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppColors.warmBrown,
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/journey');
                }
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SerifText('Week $weekNumber', fontSize: 24),
                  Text(
                    '${TrimesterUtils.labelForTrimester(TrimesterUtils.trimesterForWeek(weekNumber))}  ·  ${_dateLabelForWeek()}',
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
}
