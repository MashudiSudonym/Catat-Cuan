import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/budget_entity.dart';
import 'package:catat_cuan/domain/usecases/budget/create_budget_usecase.dart';
import 'package:catat_cuan/domain/usecases/budget/delete_budget_usecase.dart';
import 'package:catat_cuan/domain/usecases/budget/update_budget_usecase.dart';
import 'package:catat_cuan/domain/usecases/budget/get_budgets_for_month_usecase.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Controller for budget CRUD form operations
///
/// Manages budget form state (amount, selected category, month/year) and
/// delegates create/update/delete operations to respective use cases.
class BudgetFormController {
  final CreateBudgetUseCase _createBudgetUseCase;
  final UpdateBudgetUseCase _updateBudgetUseCase;
  final DeleteBudgetUseCase _deleteBudgetUseCase;
  final GetBudgetsForMonthUseCase _getBudgetsForMonthUseCase;

  BudgetFormController({
    required CreateBudgetUseCase createBudgetUseCase,
    required UpdateBudgetUseCase updateBudgetUseCase,
    required DeleteBudgetUseCase deleteBudgetUseCase,
    required GetBudgetsForMonthUseCase getBudgetsForMonthUseCase,
  })  : _createBudgetUseCase = createBudgetUseCase,
        _updateBudgetUseCase = updateBudgetUseCase,
        _deleteBudgetUseCase = deleteBudgetUseCase,
        _getBudgetsForMonthUseCase = getBudgetsForMonthUseCase;

  /// Create a new budget
  Future<Result<BudgetEntity>> submitCreate({
    required int categoryId,
    required int year,
    required int month,
    required double amount,
  }) async {
    AppLogger.d('BudgetForm: Creating budget for category $categoryId');
    return await _createBudgetUseCase(
      CreateBudgetParams(
        categoryId: categoryId,
        year: year,
        month: month,
        amount: amount,
      ),
    );
  }

  /// Update an existing budget's amount
  Future<Result<BudgetEntity>> submitUpdate({
    required int id,
    required double amount,
  }) async {
    AppLogger.d('BudgetForm: Updating budget ID $id');
    return await _updateBudgetUseCase(
      UpdateBudgetParams(id: id, amount: amount),
    );
  }

  /// Delete a budget
  Future<Result<void>> submitDelete(int id) async {
    AppLogger.d('BudgetForm: Deleting budget ID $id');
    return await _deleteBudgetUseCase(id);
  }

  /// Get budgets for a specific month
  Future<Result<List<BudgetEntity>>> getBudgetsForMonth(int year, int month) async {
    return await _getBudgetsForMonthUseCase(
      MonthParams(year: year, month: month),
    );
  }
}
