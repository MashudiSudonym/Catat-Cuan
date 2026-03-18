/// Use case for retrieving monthly transaction summary
///
/// This use case follows the Single Responsibility Principle (SRP)
/// by only handling monthly summary retrieval operations.
library;

import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/repositories/transaction_repository.dart';

/// Use case for retrieving monthly transaction summary
///
/// This use case aggregates transaction data for a specific month,
/// providing totals for income, expenses, and balance.
class GetMonthlySummaryUseCase {
  final TransactionRepository _repository;

  GetMonthlySummaryUseCase(this._repository);

  /// Retrieves monthly summary for the specified year-month
  ///
  /// Parameters:
  /// - [yearMonth]: Format "YYYY-MM" (e.g., "2024-03")
  ///
  /// Returns [MonthlySummaryEntity] with the summary data
  /// Throws [Exception] if retrieval fails
  Future<MonthlySummaryEntity> execute(String yearMonth) async {
    final result = await _repository.getMonthlySummary(yearMonth);

    if (result.isFailure) {
      throw Exception(result.error ?? 'Gagal mengambil ringkasan bulanan');
    }

    return result.data ?? MonthlySummaryEntity(
      yearMonth: yearMonth,
      totalIncome: 0,
      totalExpense: 0,
      balance: 0,
      transactionCount: 0,
      createdAt: DateTime.now(),
    );
  }

  /// Retrieves summary for all transactions (all-time)
  ///
  /// Returns [MonthlySummaryEntity] with the summary data
  /// Throws [Exception] if retrieval fails
  Future<MonthlySummaryEntity> executeAll() async {
    final result = await _repository.getAllTimeSummary();

    if (result.isFailure) {
      throw Exception(result.error ?? 'Gagal mengambil ringkasan semua data');
    }

    return result.data ?? MonthlySummaryEntity(
      yearMonth: 'all',
      totalIncome: 0,
      totalExpense: 0,
      balance: 0,
      transactionCount: 0,
      createdAt: DateTime.now(),
    );
  }

  /// Retrieves monthly summary for the current month
  Future<MonthlySummaryEntity> executeCurrentMonth() async {
    final now = DateTime.now();
    final yearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return execute(yearMonth);
  }

  /// Retrieves monthly summary for the previous month
  Future<MonthlySummaryEntity> executeLastMonth() async {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    final yearMonth = '${lastMonth.year}-${lastMonth.month.toString().padLeft(2, '0')}';
    return execute(yearMonth);
  }
}
