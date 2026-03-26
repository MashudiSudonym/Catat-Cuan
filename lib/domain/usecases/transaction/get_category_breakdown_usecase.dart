/// Use case for retrieving category breakdown for transactions
///
/// This use case follows the Single Responsibility Principle (SRP)
/// by only handling category breakdown retrieval operations.
library;

import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_analytics_repository.dart';

/// Parameter untuk mengambil category breakdown
class CategoryBreakdownParams {
  final String yearMonth;
  final TransactionType type;

  const CategoryBreakdownParams({
    required this.yearMonth,
    required this.type,
  });
}

/// Use case for retrieving category breakdown for transactions
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles category breakdown retrieval
/// - Dependency Inversion: Depends on TransactionAnalyticsRepository abstraction
class GetCategoryBreakdownUseCase
    extends UseCase<List<CategoryBreakdownEntity>, CategoryBreakdownParams> {
  final TransactionAnalyticsRepository _repository;

  GetCategoryBreakdownUseCase(this._repository);

  @override
  Future<Result<List<CategoryBreakdownEntity>>> call(
    CategoryBreakdownParams params,
  ) async {
    try {
      final result = await _repository.getCategoryBreakdown(
        params.yearMonth,
        params.type,
      );

      if (result.isSuccess && result.data != null) {
        return result;
      }

      return Result.success([]);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengambil breakdown kategori: $e'),
      );
    }
  }

  /// Convenience method for getting category breakdown by year/month and type
  Future<Result<List<CategoryBreakdownEntity>>> execute(
    String yearMonth,
    TransactionType type,
  ) async {
    return call(CategoryBreakdownParams(
      yearMonth: yearMonth,
      type: type,
    ));
  }

  /// Convenience method for getting all-time category breakdown
  Future<Result<List<CategoryBreakdownEntity>>> executeAll(TransactionType type) async {
    final getAllTimeUseCase = GetAllCategoryBreakdownUseCase(_repository);
    return await getAllTimeUseCase(type);
  }
}

/// Use case for retrieving all-time category breakdown
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles all-time category breakdown retrieval
/// - Dependency Inversion: Depends on TransactionAnalyticsRepository abstraction
class GetAllCategoryBreakdownUseCase
    extends UseCase<List<CategoryBreakdownEntity>, TransactionType> {
  final TransactionAnalyticsRepository _repository;

  GetAllCategoryBreakdownUseCase(this._repository);

  @override
  Future<Result<List<CategoryBreakdownEntity>>> call(TransactionType type) async {
    try {
      final result = await _repository.getAllCategoryBreakdown(type);

      if (result.isSuccess && result.data != null) {
        return result;
      }

      return Result.success([]);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengambil breakdown kategori semua data: $e'),
      );
    }
  }
}
