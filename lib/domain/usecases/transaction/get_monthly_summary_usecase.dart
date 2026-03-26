/// Use case for retrieving monthly transaction summary
///
/// This use case follows the Single Responsibility Principle (SRP)
/// by only handling monthly summary retrieval operations.
library;

import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_analytics_repository.dart';

/// Use case for retrieving monthly transaction summary
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles monthly summary retrieval
/// - Dependency Inversion: Depends on TransactionAnalyticsRepository abstraction
class GetMonthlySummaryUseCase
    extends UseCase<MonthlySummaryEntity, String> {
  final TransactionAnalyticsRepository _repository;

  GetMonthlySummaryUseCase(this._repository);

  @override
  Future<Result<MonthlySummaryEntity>> call(String yearMonth) async {
    try {
      final result = await _repository.getMonthlySummary(yearMonth);

      if (result.isSuccess && result.data != null) {
        return result;
      }

      // Return empty summary if not found
      return Result.success(
        MonthlySummaryEntity(
          yearMonth: yearMonth,
          totalIncome: 0,
          totalExpense: 0,
          balance: 0,
          transactionCount: 0,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengambil ringkasan bulanan: $e'),
      );
    }
  }

  /// Convenience method for getting monthly summary by year/month
  Future<Result<MonthlySummaryEntity>> execute(String yearMonth) async {
    return call(yearMonth);
  }

  /// Convenience method for getting all-time summary
  Future<Result<MonthlySummaryEntity>> executeAll() async {
    final getAllTimeUseCase = GetAllTimeSummaryUseCase(_repository);
    return await getAllTimeUseCase(const NoParams());
  }
}

/// Use case for retrieving all-time summary
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles all-time summary retrieval
/// - Dependency Inversion: Depends on TransactionAnalyticsRepository abstraction
class GetAllTimeSummaryUseCase
    extends UseCase<MonthlySummaryEntity, NoParams> {
  final TransactionAnalyticsRepository _repository;

  GetAllTimeSummaryUseCase(this._repository);

  @override
  Future<Result<MonthlySummaryEntity>> call(NoParams params) async {
    try {
      final result = await _repository.getAllTimeSummary();

      if (result.isSuccess && result.data != null) {
        return result;
      }

      // Return empty summary if not found
      return Result.success(
        MonthlySummaryEntity(
          yearMonth: 'all',
          totalIncome: 0,
          totalExpense: 0,
          balance: 0,
          transactionCount: 0,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengambil ringkasan semua data: $e'),
      );
    }
  }
}
