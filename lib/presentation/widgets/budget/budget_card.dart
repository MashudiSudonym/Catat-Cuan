import 'package:flutter/material.dart';
import 'package:catat_cuan/domain/entities/budget_with_spent_entity.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/widgets/budget/budget_progress_bar.dart';

/// Card displaying a single budget item with progress
///
/// Shows: category icon/name, budget amount, spent amount, remaining amount,
/// and a color-coded progress bar per D-11.
class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.budgetWithSpent,
    required this.category,
    this.onTap,
  });

  final BudgetWithSpentEntity budgetWithSpent;
  final CategoryEntity category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final budget = budgetWithSpent.budget;

    return AppGlassContainer.glassCard(
      onTap: onTap,
      padding: AppSpacing.lgAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: category info + amounts
          Row(
            children: [
              // Category icon
              _buildCategoryIcon(isDark),
              const AppSpacingWidget.horizontalMD(),
              // Category name and budget info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const AppSpacingWidget.verticalXS(),
                    Text(
                      'Rp ${CurrencyInputFormatter.formatRupiah(budget.amount.round())} · Terpakai Rp ${CurrencyInputFormatter.formatRupiah(budgetWithSpent.spentAmount.round())}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textOnDark.withValues(alpha: 0.6)
                                : AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              // Remaining amount
              _buildRemainingAmount(context, isDark),
            ],
          ),
          const AppSpacingWidget.verticalMD(),
          // Progress bar
          BudgetProgressBar(
            progressPercent: budgetWithSpent.progressPercent,
          ),
          const AppSpacingWidget.verticalXS(),
          // Progress percentage text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${budgetWithSpent.progressPercent.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getProgressColor(context),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                budgetWithSpent.remainingAmount >= 0
                    ? 'Sisa Rp ${CurrencyInputFormatter.formatRupiah(budgetWithSpent.remainingAmount.round())}'
                    : 'Over Rp ${CurrencyInputFormatter.formatRupiah((-budgetWithSpent.remainingAmount).round())}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: budgetWithSpent.remainingAmount >= 0
                          ? (isDark
                              ? AppColors.textOnDark.withValues(alpha: 0.6)
                              : AppColors.textSecondary)
                          : Colors.red.shade400,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(bool isDark) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.getGlassCard(isDark: isDark),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.getGlassBorder(isDark: isDark),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        category.icon ?? '💰',
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  Widget _buildRemainingAmount(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          budgetWithSpent.remainingAmount >= 0 ? 'Sisa' : 'Over',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: budgetWithSpent.remainingAmount >= 0
                    ? (isDark
                        ? AppColors.textOnDark.withValues(alpha: 0.6)
                        : AppColors.textTertiary)
                    : Colors.red.shade400,
              ),
        ),
        Text(
          budgetWithSpent.remainingAmount >= 0
              ? 'Rp ${CurrencyInputFormatter.formatRupiah(budgetWithSpent.remainingAmount.round())}'
              : 'Rp ${CurrencyInputFormatter.formatRupiah((-budgetWithSpent.remainingAmount).round())}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: budgetWithSpent.remainingAmount >= 0
                    ? AppColors.success
                    : Colors.red.shade400,
              ),
        ),
      ],
    );
  }

  Color _getProgressColor(BuildContext context) {
    if (budgetWithSpent.progressPercent > 100) return Colors.red.shade400;
    if (budgetWithSpent.progressPercent > 75) return Colors.orange.shade400;
    return Colors.green.shade400;
  }
}
