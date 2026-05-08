import 'package:flutter/material.dart';
import 'package:catat_cuan/domain/entities/budget_with_spent_entity.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/widgets/budget/budget_progress_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// Expandable glass card showing budget vs actual per category
///
/// Per D-11: Shows category icon, name, budget amount, spent, remaining, progress bar
/// Per D-12: Tapping expands inline to show transaction list
class BudgetCategoryCard extends ConsumerWidget {
  const BudgetCategoryCard({
    super.key,
    required this.budgetWithSpent,
    required this.category,
    required this.isExpanded,
    required this.year,
    required this.month,
    this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  final BudgetWithSpentEntity budgetWithSpent;
  final CategoryEntity category;
  final bool isExpanded;
  final int year;
  final int month;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final budget = budgetWithSpent.budget;

    return AppGlassContainer.glassCard(
      onTap: onToggle,
      padding: AppSpacing.lgAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              _buildCategoryIcon(isDark),
              const AppSpacingWidget.horizontalMD(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const AppSpacingWidget.verticalXS(),
                    Text(
                      'Anggaran: Rp ${CurrencyInputFormatter.formatRupiah(budget.amount.round())}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textOnDark.withValues(alpha: 0.6)
                                : AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              // Spent amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp ${CurrencyInputFormatter.formatRupiah(budgetWithSpent.spentAmount.round())}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _getProgressColor(),
                        ),
                  ),
                  Text(
                    '${budgetWithSpent.progressPercent.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getProgressColor(),
                        ),
                  ),
                ],
              ),
              // Edit action
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  visualDensity: VisualDensity.compact,
                ),
              // Delete action
              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 18,
                    color: AppColors.error,
                  ),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  visualDensity: VisualDensity.compact,
                ),
              // Expand/collapse icon
              AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: isExpanded ? 0.5 : 0,
                child: Icon(
                  Icons.expand_more,
                  size: 20,
                  color: isDark
                      ? AppColors.textOnDark.withValues(alpha: 0.5)
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const AppSpacingWidget.verticalSM(),
          // Progress bar
          BudgetProgressBar(
            progressPercent: budgetWithSpent.progressPercent,
          ),
          const AppSpacingWidget.verticalXS(),
          // Remaining
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                budgetWithSpent.remainingAmount >= 0
                    ? 'Sisa: Rp ${CurrencyInputFormatter.formatRupiah(budgetWithSpent.remainingAmount.round())}'
                    : 'Over: Rp ${CurrencyInputFormatter.formatRupiah((-budgetWithSpent.remainingAmount).round())}',
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

          // Expanded section: transaction list per D-12
          if (isExpanded) ...[
            const AppSpacingWidget.verticalMD(),
            const Divider(height: 1),
            const AppSpacingWidget.verticalSM(),
            _buildTransactionList(context, ref, isDark),
          ],
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

  Widget _buildTransactionList(
      BuildContext context, WidgetRef ref, bool isDark) {
    // Get transactions for this category in this month
    final transactionsAsync = ref.watch(transactionListProvider);

    return transactionsAsync.when(
      data: (allTransactions) {
        // Filter transactions for this category and month
        final filteredTransactions = allTransactions.where((t) {
          if (t.categoryId != category.id) return false;
          final tDate = t.dateTime;
          return tDate.year == year && tDate.month == month;
        }).toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

        if (filteredTransactions.isEmpty) {
          return Padding(
            padding: AppSpacing.mdAll,
            child: Text(
              'Belum ada transaksi di kategori ini',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textOnDark.withValues(alpha: 0.5)
                        : AppColors.textTertiary,
                  ),
              textAlign: TextAlign.center,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: AppSpacing.symmetric(horizontal: AppSpacing.xs),
              child: Text(
                '${filteredTransactions.length} transaksi',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppColors.textOnDark.withValues(alpha: 0.5)
                          : AppColors.textTertiary,
                    ),
              ),
            ),
            const AppSpacingWidget.verticalXS(),
            ...filteredTransactions.map((t) => _buildTransactionItem(
                  context,
                  t,
                  isDark,
                )),
          ],
        );
      },
      loading: () => const Padding(
        padding: AppSpacing.mdAll,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    TransactionEntity transaction,
    bool isDark,
  ) {
    return Padding(
      padding: AppSpacing.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.note ?? 'Tanpa catatan',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  AppDateFormatter.formatDayMonthYearDate(transaction.dateTime),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppColors.textOnDark.withValues(alpha: 0.5)
                            : AppColors.textTertiary,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '- Rp ${CurrencyInputFormatter.formatRupiah(transaction.amount.round())}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.expense,
                ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor() {
    if (budgetWithSpent.progressPercent > 100) return Colors.red.shade400;
    if (budgetWithSpent.progressPercent > 75) return Colors.orange.shade400;
    return Colors.green.shade400;
  }
}
