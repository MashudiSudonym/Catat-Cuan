import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/budget_with_spent_entity.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/presentation/providers/budget/budget_providers.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/widgets/budget/budget_category_card.dart';
import 'package:catat_cuan/domain/usecases/budget/get_budgets_for_month_usecase.dart';

/// Budget vs actual detail screen per D-11/D-12
///
/// Shows all budgets for a month as glass cards. Each card shows:
/// - Category icon/name, budget amount, spent, remaining, progress bar
/// - Tapping a card expands inline to show transaction list per D-12
/// - Ordered by % spent descending per D-13
class BudgetDetailScreen extends ConsumerStatefulWidget {
  const BudgetDetailScreen({
    super.key,
    required this.year,
    required this.month,
  });

  final int year;
  final int month;

  @override
  ConsumerState<BudgetDetailScreen> createState() =>
      _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends ConsumerState<BudgetDetailScreen> {
  int? _expandedCategoryId;
  Future<List<BudgetWithSpentEntity>>? _budgetsFuture;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  void _loadBudgets() {
    _budgetsFuture = ref.read(getBudgetWithSpentUseCaseProvider)(
      MonthParams(year: widget.year, month: widget.month),
    ).then((result) => result.isSuccess ? result.data ?? [] : []);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final monthDate = DateTime(widget.year, widget.month);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppDateFormatter.formatMonthYearDate(monthDate)),
      ),
      body: FutureBuilder<List<BudgetWithSpentEntity>>(
        future: _budgetsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final budgets = snapshot.data ?? [];
          if (budgets.isEmpty) {
            return AppEmptyState(
              icon: Icons.account_balance_wallet,
              title: 'Belum ada anggaran',
              subtitle:
                  'Tidak ada anggaran untuk bulan ${AppDateFormatter.formatMonthYearDate(monthDate)}',
            );
          }

          // Sort by progress percent descending per D-13
          final sortedBudgets = List<BudgetWithSpentEntity>.from(budgets)
            ..sort((a, b) => b.progressPercent.compareTo(a.progressPercent));

          return RefreshIndicator(
            onRefresh: () async => _loadBudgets(),
            child: ListView.builder(
              padding: AppSpacing.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.sm,
                bottom: AppSpacing.xxxl,
              ),
              itemCount: sortedBudgets.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: AppSpacing.only(bottom: AppSpacing.sm),
                  child: _buildBudgetCategoryCard(sortedBudgets[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBudgetCategoryCard(BudgetWithSpentEntity budgetWithSpent) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return categoriesAsync.when(
      data: (categories) {
        final category = categories.firstWhere(
          (c) => c.id == budgetWithSpent.budget.categoryId,
          orElse: () => CategoryEntity(
            id: 0,
            name: 'Lainnya',
            type: CategoryType.expense,
            color: 'FF64748B',
            icon: '📦',
            sortOrder: 0,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        final isExpanded = _expandedCategoryId == category.id;

        return BudgetCategoryCard(
          budgetWithSpent: budgetWithSpent,
          category: category,
          isExpanded: isExpanded,
          year: widget.year,
          month: widget.month,
          onToggle: () {
            setState(() {
              _expandedCategoryId =
                  isExpanded ? null : category.id;
            });
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildErrorState(String error) {
    AppLogger.e('BudgetDetail: Error loading budgets: $error');
    final userMessage = ErrorMessageMapper.getUserMessage(error);

    return Center(
      child: Padding(
        padding: AppSpacing.xxxlAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppGlassContainer.glassPill(
              width: 80,
              height: 80,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const AppSpacingWidget.verticalXL(),
            Text(
              'Terjadi Kesalahan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const AppSpacingWidget.verticalSM(),
            Text(
              userMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
            const AppSpacingWidget.verticalLG(),
            ElevatedButton.icon(
              onPressed: _loadBudgets,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
