/// Use case for retrieving multi-month transaction summary
///
/// This use case follows the Single Responsibility Principle (SRP)
/// by only handling multi-month summary retrieval operations for trend analysis.
library;

import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/repositories/transaction_repository.dart';

/// Use case for retrieving multi-month transaction summary
///
/// This use case aggregates transaction data across multiple months,
/// providing trend data for income vs expense visualization.
class GetMultiMonthSummaryUseCase {
  final TransactionRepository _repository;

  GetMultiMonthSummaryUseCase(this._repository);

  /// Retrieves monthly summaries for a range of months
  ///
  /// Parameters:
  /// - [startYearMonth]: Format "YYYY-MM" (e.g., "2024-03") - start of range (inclusive)
  /// - [endYearMonth]: Format "YYYY-MM" (e.g., "2024-08") - end of range (inclusive)
  ///
  /// Returns list of [MonthlySummaryEntity] ordered by year_month ascending
  /// Throws [Exception] if retrieval fails
  Future<List<MonthlySummaryEntity>> execute({
    required String startYearMonth,
    required String endYearMonth,
  }) async {
    final result = await _repository.getMultiMonthSummary(
      startYearMonth,
      endYearMonth,
    );

    if (result.isFailure) {
      throw Exception(result.error ?? 'Gagal mengambil data multi-bulan');
    }

    return result.data ?? [];
  }

  /// Retrieves summaries for the last 6 months from a reference date
  ///
  /// Parameters:
  /// - [referenceYearMonth]: Format "YYYY-MM" (e.g., "2024-03") - reference month
  /// - [monthCount]: Number of months to retrieve (default: 6)
  ///
  /// Returns list of [MonthlySummaryEntity] ordered by year_month ascending
  Future<List<MonthlySummaryEntity>> executeLastNMonths({
    required String referenceYearMonth,
    int monthCount = 6,
  }) async {
    final parts = referenceYearMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    // Calculate start date (N months before reference)
    final startDate = DateTime(year, month - (monthCount - 1));
    final startYearMonth = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}';

    return execute(
      startYearMonth: startYearMonth,
      endYearMonth: referenceYearMonth,
    );
  }
}
