/// Use case for retrieving multi-month transaction summary
///
/// This use case follows the Single Responsibility Principle (SRP)
/// by only handling multi-month summary retrieval operations for trend analysis.
library;

import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_analytics_repository.dart';

/// Parameter untuk mengambil ringkasan multi-bulan
class MultiMonthSummaryParams {
  final String startYearMonth;
  final String endYearMonth;

  const MultiMonthSummaryParams({
    required this.startYearMonth,
    required this.endYearMonth,
  });
}

/// Use case for retrieving multi-month transaction summary
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles multi-month summary retrieval
/// - Dependency Inversion: Depends on TransactionAnalyticsRepository abstraction
class GetMultiMonthSummaryUseCase
    extends UseCase<List<MonthlySummaryEntity>, MultiMonthSummaryParams> {
  final TransactionAnalyticsRepository _repository;

  GetMultiMonthSummaryUseCase(this._repository);

  @override
  Future<Result<List<MonthlySummaryEntity>>> call(
    MultiMonthSummaryParams params,
  ) async {
    try {
      final result = await _repository.getMultiMonthSummary(
        params.startYearMonth,
        params.endYearMonth,
      );

      if (result.isSuccess && result.data != null) {
        return result;
      }

      return Result.success([]);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengambil data multi-bulan: $e'),
      );
    }
  }

  /// Convenience method for getting last N months
  Future<Result<List<MonthlySummaryEntity>>> executeLastNMonths({
    String? referenceYearMonth,
    int monthCount = 6,
  }) async {
    final now = referenceYearMonth != null
        ? DateTime(int.parse(referenceYearMonth.substring(0, 4)), int.parse(referenceYearMonth.substring(5, 7)))
        : DateTime.now();
    final endYearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final startDate = DateTime(now.year, now.month - monthCount + 1);
    final startYearMonth = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}';

    return call(MultiMonthSummaryParams(
      startYearMonth: startYearMonth,
      endYearMonth: endYearMonth,
    ));
  }
}
