import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Import directly from provider files to avoid circular dependency
import 'package:catat_cuan/presentation/providers/usecases/transaction_usecase_providers.dart';
import 'package:catat_cuan/presentation/providers/services/service_providers.dart';

part 'monthly_summary_provider.g.dart';

// Type alias for backward compatibility
typedef MonthlySummaryState = MonthlySummaryData;

/// Data class untuk menggabungkan monthly summary data
class MonthlySummaryData {
  final String selectedYearMonth;
  final MonthlySummaryEntity summary;
  final List<CategoryBreakdownEntity> categoryBreakdown;
  final List<CategoryBreakdownEntity> incomeBreakdown;
  final List<MonthlySummaryEntity> trendData;
  final List<RecommendationEntity> recommendations;
  final DateTime? firstTransactionDate;

  const MonthlySummaryData({
    required this.selectedYearMonth,
    required this.summary,
    required this.categoryBreakdown,
    required this.incomeBreakdown,
    required this.trendData,
    required this.recommendations,
    this.firstTransactionDate,
  });

  /// Check apakah ada transaksi di bulan ini
  bool get hasTransactions => summary.transactionCount > 0;

  /// Check apakah ada rekomendasi untuk ditampilkan
  bool get hasRecommendations => recommendations.isNotEmpty;

  /// Check apakah ada data income breakdown
  bool get hasIncomeData => incomeBreakdown.isNotEmpty && summary.totalIncome > 0;

  /// Check apakah ada data trend
  bool get hasTrendData => trendData.isNotEmpty;

  /// Check apakah mode "all data" sedang aktif
  bool get isAllData => selectedYearMonth == 'all';

  /// Get tahun dari selectedYearMonth
  int? get year {
    if (isAllData) return null;
    final parts = selectedYearMonth.split('-');
    return int.parse(parts[0]);
  }

  /// Get bulan dari selectedYearMonth
  int? get month {
    if (isAllData) return null;
    final parts = selectedYearMonth.split('-');
    return int.parse(parts[1]);
  }

  /// Check apakah bulan ini sehat (saldo > 20% dari pemasukan)
  bool get isHealthy => summary.isHealthy;

  /// Check apakah ada imbalance (pengeluaran > pemasukan)
  bool get isImbalance => summary.isImbalance;
}

/// Provider untuk monthly summary
/// Following SRP: Only manages monthly summary state and loading
/// Following DIP: Depends on UseCase and Service abstractions
/// Uses AsyncNotifier for proper async handling without constructor side effects
@riverpod
class MonthlySummaryNotifier extends _$MonthlySummaryNotifier {
  /// State untuk menyimpan selectedYearMonth (tidak async)
  String? _selectedYearMonth;

  @override
  Future<MonthlySummaryData> build() async {
    // No constructor side effects - data loading in build() method
    // Get or initialize selected year-month
    _selectedYearMonth ??= _getCurrentYearMonth();

    return _loadSummary(_selectedYearMonth!);
  }

  /// Load ringkasan bulanan
  Future<MonthlySummaryData> _loadSummary(String yearMonth) async {
    final getMonthlySummaryUseCase = ref.read(getMonthlySummaryUseCaseProvider);
    final getCategoryBreakdownUseCase = ref.read(getCategoryBreakdownUseCaseProvider);
    final getMultiMonthSummaryUseCase = ref.read(getMultiMonthSummaryUseCaseProvider);
    final insightService = ref.read(insightServiceProvider);

    // Check if "all data" mode
    final isAllData = yearMonth == 'all';

    // Load trend data (last 6 months including current month)
    // Skip trend data for "all" mode
    final trendData = isAllData
        ? <MonthlySummaryEntity>[]
        : await getMultiMonthSummaryUseCase.executeLastNMonths(
            referenceYearMonth: yearMonth,
            monthCount: 6,
          );

    // Load summary dan breakdown secara parallel
    MonthlySummaryEntity summary;
    List<CategoryBreakdownEntity> expenseBreakdown;
    List<CategoryBreakdownEntity> incomeBreakdown;
    DateTime? firstTransactionDate;

    if (isAllData) {
      // Get all-time summary and breakdown
      final results = await Future.wait<dynamic>([
        getMonthlySummaryUseCase.executeAll(),
        getCategoryBreakdownUseCase.executeAll(TransactionType.expense),
        getCategoryBreakdownUseCase.executeAll(TransactionType.income),
      ]);

      summary = results[0] as MonthlySummaryEntity;
      expenseBreakdown = results[1] as List<CategoryBreakdownEntity>;
      incomeBreakdown = results[2] as List<CategoryBreakdownEntity>;

      // Get first transaction date for month picker
      final getTransactionsUseCase = ref.read(getTransactionsUseCaseProvider);
      final transactions = await getTransactionsUseCase.execute();
      if (transactions.isNotEmpty) {
        firstTransactionDate = transactions
            .map((t) => t.dateTime)
            .reduce((a, b) => a.isBefore(b) ? a : b);
      }
    } else {
      // Load specific month data
      final results = await Future.wait<dynamic>([
        getMonthlySummaryUseCase.execute(yearMonth),
        getCategoryBreakdownUseCase.execute(yearMonth, TransactionType.expense),
        getCategoryBreakdownUseCase.execute(yearMonth, TransactionType.income),
      ]);

      summary = results[0] as MonthlySummaryEntity;
      expenseBreakdown = results[1] as List<CategoryBreakdownEntity>;
      incomeBreakdown = results[2] as List<CategoryBreakdownEntity>;

      // Get first transaction date for month picker
      final getTransactionsUseCase = ref.read(getTransactionsUseCaseProvider);
      final transactions = await getTransactionsUseCase.execute();
      if (transactions.isNotEmpty) {
        firstTransactionDate = transactions
            .map((t) => t.dateTime)
            .reduce((a, b) => a.isBefore(b) ? a : b);
      }
    }

    // Generate recommendations (skip for "all" mode)
    final recommendations = isAllData
        ? <RecommendationEntity>[]
        : insightService.generateInsights(summary, expenseBreakdown);

    return MonthlySummaryData(
      selectedYearMonth: yearMonth,
      summary: summary,
      categoryBreakdown: expenseBreakdown,
      incomeBreakdown: incomeBreakdown,
      trendData: trendData,
      recommendations: recommendations,
      firstTransactionDate: firstTransactionDate,
    );
  }

  /// Ganti bulan yang dilihat
  void changeMonth(String yearMonth) {
    if (_selectedYearMonth != yearMonth) {
      _selectedYearMonth = yearMonth;
      ref.invalidateSelf();
    }
  }

  /// Navigasi ke bulan sebelumnya
  void previousMonth() {
    final current = _selectedYearMonth ?? _getCurrentYearMonth();

    // If currently in "all" mode, go to current month
    if (current == 'all') {
      goToCurrentMonth();
      return;
    }

    final parts = current.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final previous = DateTime(year, month - 1);
    final newYearMonth = '${previous.year}-${previous.month.toString().padLeft(2, '0')}';
    changeMonth(newYearMonth);
  }

  /// Navigasi ke bulan selanjutnya
  void nextMonth() {
    final current = _selectedYearMonth ?? _getCurrentYearMonth();

    // If currently in "all" mode, go to current month
    if (current == 'all') {
      goToCurrentMonth();
      return;
    }

    final parts = current.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final next = DateTime(year, month + 1);
    final newYearMonth = '${next.year}-${next.month.toString().padLeft(2, '0')}';
    changeMonth(newYearMonth);
  }

  /// Kembali ke bulan berjalan
  void goToCurrentMonth() {
    final currentYearMonth = _getCurrentYearMonth();
    changeMonth(currentYearMonth);
  }

  /// Refresh data (pull to refresh atau manual refresh)
  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// Clear error state
  void clearError() {
    // AsyncNotifier doesn't have error state in the same way
    // This is a no-op for compatibility - errors are handled via AsyncValue
  }

  /// Get current year-month in format "YYYY-MM"
  static String _getCurrentYearMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  /// Get current selected year-month
  String get selectedYearMonth => _selectedYearMonth ?? _getCurrentYearMonth();
}
