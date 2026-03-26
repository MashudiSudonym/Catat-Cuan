/// Use case for retrieving financial insights and recommendations
///
/// This use case follows the Single Responsibility Principle (SRP)
/// by only handling insight data aggregation operations.
library;

import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
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
/// Following SOLID principles:
/// - Single Responsibility: Only handles insight data aggregation
/// - Dependency Inversion: Depends on other use case abstractions
class GetInsightsUseCase extends UseCase<InsightData, String> {
  final GetMonthlySummaryUseCase _getMonthlySummaryUseCase;
  final GetCategoryBreakdownUseCase _getCategoryBreakdownUseCase;

  GetInsightsUseCase(
    this._getMonthlySummaryUseCase,
    this._getCategoryBreakdownUseCase,
  );

  @override
  Future<Result<InsightData>> call(String yearMonth) async {
    try {
      // Fetch monthly summary and expense breakdown in parallel
      final results = await Future.wait([
        _getMonthlySummaryUseCase(yearMonth),
        _getCategoryBreakdownUseCase(CategoryBreakdownParams(
          yearMonth: yearMonth,
          type: TransactionType.expense,
        )),
      ]);

      final summaryResult = results[0] as Result<MonthlySummaryEntity>;
      final breakdownResult = results[1] as Result<List<CategoryBreakdownEntity>>;

      // Check for errors
      if (summaryResult.isFailure) {
        return Result.failure(summaryResult.failure!);
      }

      if (breakdownResult.isFailure) {
        return Result.failure(breakdownResult.failure!);
      }

      return Result.success(
        InsightData(
          summary: summaryResult.data!,
          expenseBreakdown: breakdownResult.data ?? [],
        ),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure('Gagal mengambil insight: $e'),
      );
    }
  }
}
