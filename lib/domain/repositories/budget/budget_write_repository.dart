import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/budget_entity.dart';

/// Repository interface for writing budget data (CRUD operations)
///
/// Following Interface Segregation Principle (ISP) - only write operations.
/// Enforces expense-only constraint (no budgets for income categories).
abstract class BudgetWriteRepository {
  /// Creates a new budget for an expense category
  ///
  /// Parameters:
  /// - [categoryId]: Must reference an existing expense category
  /// - [year]: Year of budget period
  /// - [month]: Month of budget period (1-12)
  /// - [amount]: Budget limit amount (must be > 0)
  ///
  /// Returns Result with the created BudgetEntity on success.
  /// Returns DatabaseFailure if:
  /// - Category is income type (expense-only validation per BUD-01)
  /// - Budget already exists for this category+year+month (BUD-07 UNIQUE)
  Future<Result<BudgetEntity>> createBudget({
    required int categoryId,
    required int year,
    required int month,
    required double amount,
  });

  /// Updates a budget's amount
  ///
  /// Parameters:
  /// - [id]: Budget ID to update
  /// - [amount]: New budget limit amount
  ///
  /// Returns Result with the updated BudgetEntity
  Future<Result<BudgetEntity>> updateBudget({
    required int id,
    required double amount,
  });

  /// Deletes a budget by ID
  ///
  /// Returns Result with void on success
  Future<Result<void>> deleteBudget(int id);

  /// Updates alert status fields on a budget record
  ///
  /// Per D-02: Persists alert tracking timestamps on the budget record.
  /// Only non-null fields are updated (partial update).
  Future<Result<void>> updateAlertStatus({
    required int budgetId,
    DateTime? warningShownAt,
    DateTime? limitShownAt,
    DateTime? overShownAt,
  });
}
