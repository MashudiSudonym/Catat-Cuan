import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/budget_with_spent_entity.dart';

/// Repository interface for budget query operations (spent calculation)
///
/// Following Interface Segregation Principle (ISP) - only query/analytics
/// operations related to budget spending tracking.
abstract class BudgetQueryRepository {
  /// Retrieves all budgets for a month with their spent amounts
  ///
  /// Joins budgets with expense transactions to calculate how much
  /// has been spent against each budget in the specified month.
  ///
  /// Parameters:
  /// - [year]: Year of budget period
  /// - [month]: Month of budget period (1-12)
  ///
  /// Returns Result with list of BudgetWithSpentEntity containing
  /// budget + spentAmount + progressPercent + remainingAmount
  Future<Result<List<BudgetWithSpentEntity>>> getBudgetsWithSpent(
    int year,
    int month,
  );

  /// Gets the total spent amount for a specific category in a month
  ///
  /// Sums all expense transactions for the given category in the
  /// specified year/month period.
  ///
  /// Parameters:
  /// - [categoryId]: Category to calculate spending for
  /// - [year]: Year
  /// - [month]: Month (1-12)
  ///
  /// Returns Result with the total spent amount (0.0 if no transactions)
  Future<Result<double>> getBudgetSpentForCategory({
    required int categoryId,
    required int year,
    required int month,
  });
}
