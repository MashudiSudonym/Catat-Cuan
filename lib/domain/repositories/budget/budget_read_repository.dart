import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/budget_alert_status_entity.dart';
import 'package:catat_cuan/domain/entities/budget_entity.dart';

/// Repository interface for reading budget data
///
/// Following Interface Segregation Principle (ISP) - only read operations.
/// Clients that only need to read budgets don't depend on write operations.
abstract class BudgetReadRepository {
  /// Retrieves all budgets for a specific month
  ///
  /// Parameters:
  /// - [year]: Year (e.g., 2026)
  /// - [month]: Month (1-12)
  ///
  /// Returns Result with list of budgets for the specified month
  Future<Result<List<BudgetEntity>>> getBudgetsForMonth(int year, int month);

  /// Retrieves a budget by its ID
  ///
  /// Returns Result with the budget if found, NotFoundFailure if not found
  Future<Result<BudgetEntity>> getBudgetById(int id);

  /// Retrieves a budget for a specific category and month
  ///
  /// Returns Result with the budget if found, NotFoundFailure if not found.
  /// Used by alert checking to find the budget for a given transaction's category.
  Future<Result<BudgetEntity>> getBudgetByCategoryAndMonth({
    required int categoryId,
    required int year,
    required int month,
  });

  /// Retrieves the alert status for a budget
  ///
  /// Per D-02: Reads alert_status fields from the budget record.
  /// Returns BudgetAlertStatus with timestamps of shown alerts.
  Future<Result<BudgetAlertStatus>> getAlertStatus(int budgetId);
}
