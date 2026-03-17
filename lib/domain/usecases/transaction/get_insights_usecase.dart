/// Use case for retrieving financial insights and recommendations
///
/// This use case follows the Single Responsibility Principle (SRP)
/// by only handling insight data aggregation operations.
library;

import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/usecases/transaction/get_category_breakdown_usecase.dart';
import 'package:catat_cuan/domain/usecases/transaction/get_monthly_summary_usecase.dart';

/// Data class combining summary and category breakdown
///
/// This represents the complete insight data for a specific month,
/// including both the monthly summary and expense breakdown by category.
class InsightData {
  final MonthlySummaryEntity summary;
  final List<CategoryBreakdownEntity> expenseBreakdown;

  const InsightData({
    required this.summary,
    required this.expenseBreakdown,
  });

  /// Creates a copy with modified fields
  InsightData copyWith({
    MonthlySummaryEntity? summary,
    List<CategoryBreakdownEntity>? expenseBreakdown,
  }) {
    return InsightData(
      summary: summary ?? this.summary,
      expenseBreakdown: expenseBreakdown ?? this.expenseBreakdown,
    );
  }

  @override
  String toString() =>
      'InsightData{summary: $summary, expenseBreakdown: $expenseBreakdown}';
}

/// Use case for retrieving financial insights and recommendations
///
/// This use case combines monthly summary and category breakdown
/// to provide comprehensive financial insights.
class GetInsightsUseCase {
  final GetMonthlySummaryUseCase _getMonthlySummaryUseCase;
  final GetCategoryBreakdownUseCase _getCategoryBreakdownUseCase;

  GetInsightsUseCase(
    this._getMonthlySummaryUseCase,
    this._getCategoryBreakdownUseCase,
  );

  /// Retrieves complete insight data for the specified month
  ///
  /// Parameters:
  /// - [yearMonth]: Format "YYYY-MM" (e.g., "2024-03")
  ///
  /// Returns [InsightData] containing:
  /// - Monthly summary (income, expense, balance, transaction count)
  /// - Expense breakdown by category (sorted by amount)
  ///
  /// Throws [Exception] if retrieval fails
  Future<InsightData> execute(String yearMonth) async {
    try {
      // Fetch monthly summary and expense breakdown in parallel
      final results = await Future.wait([
        _getMonthlySummaryUseCase.execute(yearMonth),
        _getCategoryBreakdownUseCase.execute(yearMonth, TransactionType.expense),
      ]);

      final summary = results[0] as MonthlySummaryEntity;
      final breakdown = results[1] as List<CategoryBreakdownEntity>;

      return InsightData(
        summary: summary,
        expenseBreakdown: breakdown,
      );
    } catch (e) {
      throw Exception('Gagal mengambil insight: ${e.toString()}');
    }
  }
}
