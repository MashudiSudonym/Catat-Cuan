import 'package:catat_cuan/domain/core/result.dart';
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
}
