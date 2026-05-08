import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/navigation/routes/app_routes.dart';

/// Summary data for budget overview
class BudgetSummary {
  final double totalBudget;
  final double totalSpent;
  final double remainingAmount;
  final int overspendingCount;
  final bool hasBudgets;
  final int year;
  final int month;

  const BudgetSummary({
    this.totalBudget = 0.0,
    this.totalSpent = 0.0,
    this.remainingAmount = 0.0,
    this.overspendingCount = 0,
    this.hasBudgets = false,
    this.year = 0,
    this.month = 0,
  });
}

/// Compact card showing budget summary for current month per D-08
///
/// Shows: total budget, total spent, remaining amount, overspending count.
/// Per D-09: Tapping navigates to Anggaran tab.
/// Per D-10: Only shown when budgets exist for current month.
class BudgetOverviewCard extends ConsumerWidget {
  const BudgetOverviewCard({
    super.key,
    required this.summary,
  });

  final BudgetSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthDate = DateTime(summary.year, summary.month);

    return AppGlassContainer.glassCard(
      onTap: () {
        // Per D-09: Tap navigates to Anggaran tab
        context.go(AppRoutes.budgets);
      },
      padding: AppSpacing.lgAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const AppSpacingWidget.horizontalSM(),
                  Text(
                    'Anggaran',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              Text(
                AppDateFormatter.formatMonthYearDate(monthDate),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textOnDark.withValues(alpha: 0.6)
                          : AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const AppSpacingWidget.verticalMD(),

          // Amounts row
          Row(
            children: [
              // Total budget
              Expanded(
                child: _buildAmountColumn(
                  context,
                  isDark,
                  label: 'Anggaran',
                  amount: summary.totalBudget,
                  color: isDark
                      ? AppColors.textOnDark.withValues(alpha: 0.8)
                      : AppColors.textPrimary,
                ),
              ),
              // Spent
              Expanded(
                child: _buildAmountColumn(
                  context,
                  isDark,
                  label: 'Terpakai',
                  amount: summary.totalSpent,
                  color: summary.totalSpent > summary.totalBudget
                      ? Colors.red.shade400
                      : AppColors.expense,
                ),
              ),
              // Remaining
              Expanded(
                child: _buildAmountColumn(
                  context,
                  isDark,
                  label: 'Sisa',
                  amount: summary.remainingAmount.abs(),
                  color: summary.remainingAmount >= 0
                      ? AppColors.success
                      : Colors.red.shade400,
                ),
              ),
            ],
          ),

          // Overspending badge per D-08
          if (summary.overspendingCount > 0) ...[
            const AppSpacingWidget.verticalSM(),
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: Colors.red.shade400,
                ),
                const AppSpacingWidget.horizontalXS(),
                Text(
                  '${summary.overspendingCount} kategori overbudget',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountColumn(
    BuildContext context,
    bool isDark, {
    required String label,
    required double amount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isDark
                    ? AppColors.textOnDark.withValues(alpha: 0.5)
                    : AppColors.textTertiary,
              ),
        ),
        const AppSpacingWidget.verticalXS(),
        Text(
          'Rp ${CurrencyInputFormatter.formatRupiah(amount.round())}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
        ),
      ],
    );
  }
}
