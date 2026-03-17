/// Use case for retrieving category breakdown for transactions
///
/// This use case follows the Single Responsibility Principle (SRP)
/// by only handling category breakdown retrieval operations.
library;

import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/repositories/transaction_repository.dart';

/// Use case for retrieving category breakdown for transactions
///
/// This use case aggregates transaction amounts by category
/// for a specific month and transaction type.
class GetCategoryBreakdownUseCase {
  final TransactionRepository _repository;

  GetCategoryBreakdownUseCase(this._repository);

  /// Retrieves category breakdown for the specified parameters
  ///
  /// Parameters:
  /// - [yearMonth]: Format "YYYY-MM" (e.g., "2024-03")
  /// - [type]: Filter by transaction type (income/expense)
  ///
  /// Returns a list of [CategoryBreakdownEntity] sorted by total amount (descending)
  /// Throws [Exception] if retrieval fails
  Future<List<CategoryBreakdownEntity>> execute(
    String yearMonth,
    TransactionType type,
  ) async {
    final result = await _repository.getCategoryBreakdown(yearMonth, type);

    if (result.isFailure) {
      throw Exception(result.error ?? 'Gagal mengambil breakdown kategori');
    }

    return result.data ?? [];
  }

  /// Retrieves expense category breakdown for the current month
  Future<List<CategoryBreakdownEntity>> executeExpenseCurrentMonth() async {
    final now = DateTime.now();
    final yearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return execute(yearMonth, TransactionType.expense);
  }

  /// Retrieves expense category breakdown for a specific month
  Future<List<CategoryBreakdownEntity>> executeExpenseByMonth(
    String yearMonth,
  ) async {
    return execute(yearMonth, TransactionType.expense);
  }

  /// Retrieves income category breakdown for a specific month
  Future<List<CategoryBreakdownEntity>> executeIncomeByMonth(
    String yearMonth,
  ) async {
    return execute(yearMonth, TransactionType.income);
  }
}
