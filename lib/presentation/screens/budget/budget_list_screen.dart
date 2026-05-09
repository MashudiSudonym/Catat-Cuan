import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:catat_cuan/domain/entities/budget_with_spent_entity.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/presentation/providers/budget/budget_providers.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/widgets/budget/budget_card.dart';
import 'package:catat_cuan/presentation/navigation/routes/app_routes.dart';
import 'package:catat_cuan/domain/usecases/budget/get_budgets_for_month_usecase.dart';

/// Main Anggaran tab screen with month navigation and budget list
///
/// Per D-04/D-05:
/// - AppBar with month/year label and arrow buttons for month navigation
/// - Swipe + arrow buttons for month navigation
/// - Empty state with "Tambah Anggaran" prompt when no budgets
/// - ListView of BudgetCard widgets
class BudgetListScreen extends ConsumerStatefulWidget {
  const BudgetListScreen({super.key});

  @override
  ConsumerState<BudgetListScreen> createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends ConsumerState<BudgetListScreen> {
  late DateTime _currentMonth;
  Future<List<BudgetWithSpentEntity>>? _budgetsFuture;
  int _lastSeenTabIndex = 1;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _loadBudgets();
  }

  void _loadBudgets() {
    _budgetsFuture = ref.read(getBudgetWithSpentUseCaseProvider)(
      MonthParams(year: _currentMonth.year, month: _currentMonth.month),
    ).then((result) => result.isSuccess ? result.data ?? [] : []);
    setState(() {});
  }

  void _goToPreviousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    _loadBudgets();
  }

  void _goToNextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    _loadBudgets();
  }

  void _goToCurrentMonth() {
    _currentMonth = DateTime.now();
    _loadBudgets();
  }

  @override
  Widget build(BuildContext context) {
    final activeTabIndex = ref.watch(activeTabIndexProvider);
    if (activeTabIndex == 1 && _lastSeenTabIndex != 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadBudgets();
      });
    }
    _lastSeenTabIndex = activeTabIndex;

    return FutureBuilder<List<BudgetWithSpentEntity>>(
      future: _budgetsFuture,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: _buildMonthSelector(),
            actions: [
              if (snapshot.hasData && (snapshot.data?.isNotEmpty ?? false))
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Tambah Anggaran',
                  onPressed: () async {
                    final result = await context.push<bool>(
                      '${AppRoutes.budgets}/form?year=${_currentMonth.year}&month=${_currentMonth.month}',
                    );
                    if (result == true) _loadBudgets();
                  },
                ),
              if (!_isCurrentMonth())
                TextButton(
                  onPressed: _goToCurrentMonth,
                  child: const Text('Hari Ini'),
                ),
            ],
          ),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : snapshot.hasError
                  ? _buildErrorState(snapshot.error.toString())
                  : _buildContent(snapshot.data ?? []),
          floatingActionButton: null, // FAB is handled by HomeNavigationShell
        );
      },
    );
  }

  bool _isCurrentMonth() {
    final now = DateTime.now();
    return _currentMonth.year == now.year && _currentMonth.month == now.month;
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _goToPreviousMonth,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        GestureDetector(
          onTap: () {
            // Could show month picker in the future
          },
          child: Text(
            AppDateFormatter.formatMonthYearDate(_currentMonth),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _goToNextMonth,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ],
    );
  }

  Widget _buildContent(List<BudgetWithSpentEntity> budgets) {
    if (budgets.isEmpty) {
      return _buildEmptyState();
    }

    // Sort by progress percent descending per D-13
    final sortedBudgets = List<BudgetWithSpentEntity>.from(budgets)
      ..sort((a, b) => b.progressPercent.compareTo(a.progressPercent));

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -300) {
          _goToNextMonth(); // Swipe left → next month
        } else if (details.primaryVelocity! > 300) {
          _goToPreviousMonth(); // Swipe right → previous month
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          _loadBudgets();
        },
        child: ListView.builder(
          padding: AppSpacing.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.sm,
            bottom: AppSpacing.xxxl,
          ),
          itemCount: sortedBudgets.length,
          itemBuilder: (context, index) {
            final budgetWithSpent = sortedBudgets[index];
            return Padding(
              padding: AppSpacing.only(bottom: AppSpacing.sm),
              child: _buildBudgetCard(budgetWithSpent),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBudgetCard(BudgetWithSpentEntity budgetWithSpent) {
    // Get category for this budget
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

        return BudgetCard(
          budgetWithSpent: budgetWithSpent,
          category: category,
          onTap: () async {
            // Navigate to budget detail and refresh on return
            await context.push<bool>(
              '${AppRoutes.budgets}/detail?year=${_currentMonth.year}&month=${_currentMonth.month}',
            );
            _loadBudgets();
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => BudgetCard(
        budgetWithSpent: budgetWithSpent,
        category: CategoryEntity(
          id: 0,
          name: 'Kategori',
          type: CategoryType.expense,
          color: 'FF64748B',
          icon: '📦',
          sortOrder: 0,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return AppEmptyState(
      icon: Icons.account_balance_wallet,
      title: 'Belum ada anggaran',
      subtitle:
          'Atur anggaran bulanan per kategori untuk mengontrol pengeluaran Anda',
      actionLabel: 'Tambah Anggaran',
      onAction: () async {
        final result = await context.push<bool>(
          '${AppRoutes.budgets}/form?year=${_currentMonth.year}&month=${_currentMonth.month}',
        );
        if (result == true) _loadBudgets();
      },
    );
  }

  Widget _buildErrorState(String error) {
    AppLogger.e('BudgetList: Error loading budgets: $error');
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
