import 'package:flutter/material.dart';
import 'package:catat_cuan/domain/entities/goal_contribution_entity.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';

class ContributionListItem extends StatelessWidget {
  const ContributionListItem({
    super.key,
    required this.contribution,
  });

  final GoalContributionEntity contribution;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isContribution = contribution.isContribution;

    return AppGlassContainer.glassCard(
      padding: AppSpacing.all(AppSpacing.md),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppDateFormatter.formatDayMonthYearDate(contribution.date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textOnDark.withValues(alpha: 0.6)
                          : AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const AppSpacingWidget.horizontalMD(),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isContribution
                  ? AppColors.getIncomeColor(isDark).withValues(alpha: 0.15)
                  : AppColors.getExpenseColor(isDark).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isContribution ? Icons.trending_up : Icons.trending_down,
              size: 16,
              color: isContribution
                  ? AppColors.getIncomeColor(isDark)
                  : AppColors.getExpenseColor(isDark),
            ),
          ),
          const AppSpacingWidget.horizontalSM(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isContribution ? 'Setoran' : 'Penarikan',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (contribution.note != null && contribution.note!.isNotEmpty)
                  Text(
                    contribution.note!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textOnDark.withValues(alpha: 0.4)
                              : AppColors.textTertiary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isContribution ? '+' : '-'}Rp ${CurrencyInputFormatter.formatRupiah(contribution.amount.abs().round())}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isContribution
                          ? AppColors.getIncomeColor(isDark)
                          : AppColors.getExpenseColor(isDark),
                    ),
              ),
              Text(
                'Rp ${CurrencyInputFormatter.formatRupiah(contribution.runningBalance.round())}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textOnDark.withValues(alpha: 0.6)
                          : AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
