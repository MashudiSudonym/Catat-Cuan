import 'package:flutter/material.dart';
import 'package:catat_cuan/domain/entities/savings_goal_with_progress_entity.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/widgets/savings/circular_goal_progress.dart';
import 'package:catat_cuan/presentation/widgets/savings/completion_badge.dart';

class SavingsGoalCard extends StatelessWidget {
  const SavingsGoalCard({
    super.key,
    required this.goalWithProgress,
    this.onTap,
  });

  final SavingsGoalWithProgressEntity goalWithProgress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goal = goalWithProgress.goal;

    return AppGlassContainer.glassCard(
      onTap: onTap,
      padding: AppSpacing.lgAll,
      child: Row(
        children: [
          CircularGoalProgress(
            percentage: goalWithProgress.progressPercentage,
            size: 48,
            strokeWidth: 4,
            isDark: isDark,
          ),
          const AppSpacingWidget.horizontalLG(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (goalWithProgress.isCompleted)
                      const CompletionBadge(),
                  ],
                ),
                const AppSpacingWidget.verticalXS(),
                Text(
                  'Rp ${CurrencyInputFormatter.formatRupiah(goal.currentAmount.round())} / Rp ${CurrencyInputFormatter.formatRupiah(goal.targetAmount.round())}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (goal.targetDate != null) ...[
                  const AppSpacingWidget.verticalXS(),
                  Text(
                    goalWithProgress.isOverdue
                        ? 'Lewat ${-goalWithProgress.daysRemaining!} hari'
                        : '${goalWithProgress.daysRemaining} hari lagi',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: goalWithProgress.isOverdue
                              ? AppColors.getExpenseColor(isDark)
                              : (isDark
                                  ? AppColors.textOnDark.withValues(alpha: 0.6)
                                  : AppColors.textSecondary),
                        ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isDark
                ? AppColors.textOnDark.withValues(alpha: 0.4)
                : AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
