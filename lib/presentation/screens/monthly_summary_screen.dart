import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/widgets/summary_metrics_card.dart';
import 'package:catat_cuan/presentation/widgets/category_breakdown_widget.dart';
import 'package:catat_cuan/presentation/widgets/income_breakdown_widget.dart';
import 'package:catat_cuan/presentation/widgets/income_vs_expense_trend_widget.dart';
import 'package:catat_cuan/presentation/widgets/recommendation_card.dart';
import 'package:catat_cuan/presentation/widgets/period_selector.dart';
import 'package:catat_cuan/presentation/utils/app_colors.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';

/// Screen untuk menampilkan ringkasan bulanan transaksi
/// Menggunakan CustomScrollView untuk smooth scrolling
class MonthlySummaryScreen extends ConsumerStatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  ConsumerState<MonthlySummaryScreen> createState() =>
      _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState
    extends ConsumerState<MonthlySummaryScreen> {
  int _previousTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(monthlySummaryNotifierProvider);
    final notifier = ref.read(monthlySummaryNotifierProvider.notifier);
    final currentTabIndex = ref.watch(navigationProvider).selectedIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Detect tab change to summary screen (index 1)
    if (_previousTabIndex != 1 && currentTabIndex == 1) {
      // Schedule refresh after this build cycle
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.refresh();
      });
    }
    _previousTabIndex = currentTabIndex;

    // Setup error listener for AsyncValue
    ref.listen(monthlySummaryNotifierProvider, (previous, next) {
      if (next.hasError && previous?.hasError != next.hasError) {
        _showErrorSnackBar(next.error.toString());
        notifier.clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header with Title and Period Selector
            // Build header based on async state
            summaryAsync.when(
              loading: () => _buildHeader(
                _createPlaceholderData(notifier),
                notifier,
              ),
              error: (error, stack) => _buildHeader(
                _createPlaceholderData(notifier),
                notifier,
              ),
              data: (data) => _buildHeader(data, notifier),
            ),

            // Scrollable Content - using AsyncValue pattern
            Expanded(
              child: summaryAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorState(error.toString(), notifier),
                data: (data) => _buildContent(data, notifier),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build header dengan title dan period selector
  Widget _buildHeader(MonthlySummaryData data, MonthlySummaryNotifier notifier) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;

    return AppGlassNavigation(
      showBottomBorder: true,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Title Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.bar_chart,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Ringkasan Bulanan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                  ),
                  const Spacer(),
                  // Refresh button
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => notifier.refresh(),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),

            // Period Selector
            PeriodSelector(
              selectedYearMonth: data.selectedYearMonth,
              onMonthChanged: (yearMonth) => notifier.changeMonth(yearMonth),
              onPrevious: notifier.previousMonth,
              onNext: notifier.nextMonth,
              firstTransactionDate: data.firstTransactionDate,
            ),
          ],
        ),
      ),
    );
  }

  /// Build scrollable content
  Widget _buildContent(MonthlySummaryData data, MonthlySummaryNotifier notifier) {
    // Jika tidak ada transaksi
    if (!data.hasTransactions) {
      return _buildNoTransactionsState(data);
    }

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: CustomScrollView(
        slivers: [
          // Summary Metrics Card
          SliverToBoxAdapter(
            child: SummaryMetricsCard(summary: data.summary),
          ),

          // Recommendations Widget
          if (data.hasRecommendations)
            SliverToBoxAdapter(
              child: RecommendationCard(
                recommendations: data.recommendations,
              ),
            ),

          // Trend Chart (NEW)
          if (data.hasTrendData)
            SliverToBoxAdapter(
              child: IncomeVsExpenseTrendWidget(summaries: data.trendData),
            ),

          // Expense Breakdown Widget
          if (data.categoryBreakdown.isNotEmpty)
            SliverToBoxAdapter(
              child: CategoryBreakdownWidget(
                breakdown: data.categoryBreakdown,
                totalExpense: data.summary.totalExpense,
              ),
            ),

          // Income Breakdown Widget (NEW)
          if (data.hasIncomeData)
            SliverToBoxAdapter(
              child: IncomeBreakdownWidget(
                breakdown: data.incomeBreakdown,
                totalIncome: data.summary.totalIncome,
              ),
            ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(String error, MonthlySummaryNotifier notifier) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final subTextColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.7) : AppColors.textSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gagal memuat data ringkasan. Silakan coba lagi.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: subTextColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: notifier.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build no transactions state (ada data transaksi tapi tidak di bulan ini)
  Widget _buildNoTransactionsState(MonthlySummaryData data) {
    final isAllData = data.isAllData;
    final monthYear = isAllData ? '' : _formatMonthYear(data.selectedYearMonth);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final secondaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.7) : AppColors.textSecondary;
    final tertiaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.5) : AppColors.textTertiary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: tertiaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ada Transaksi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isAllData
                  ? 'Belum ada transaksi sama sekali.'
                  : 'Belum ada transaksi di bulan $monthYear.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: secondaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isAllData
                  ? 'Mulai catat transaksi baru untuk melihat ringkasan.'
                  : 'Pilih bulan lain atau mulai catat transaksi baru.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tertiaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Show error snack bar
  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Tutup',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Format year-month to display name
  String _formatMonthYear(String yearMonth) {
    if (yearMonth == 'all') {
      return 'Semua Data';
    }

    final parts = yearMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    return '${months[month - 1]} $year';
  }

  /// Create placeholder data for loading/error states
  MonthlySummaryData _createPlaceholderData(MonthlySummaryNotifier notifier) {
    return MonthlySummaryData(
      selectedYearMonth: notifier.selectedYearMonth,
      summary: MonthlySummaryEntity(
        yearMonth: notifier.selectedYearMonth,
        totalIncome: 0,
        totalExpense: 0,
        balance: 0,
        transactionCount: 0,
        createdAt: DateTime.now(),
      ),
      categoryBreakdown: [],
      incomeBreakdown: [],
      trendData: [],
      recommendations: [],
    );
  }
}
