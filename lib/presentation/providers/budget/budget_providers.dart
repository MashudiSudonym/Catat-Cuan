import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/data/repositories/budget/budget_read_repository_impl.dart';
import 'package:catat_cuan/data/repositories/budget/budget_write_repository_impl.dart';
import 'package:catat_cuan/data/repositories/budget/budget_query_repository_impl.dart';
import 'package:catat_cuan/domain/repositories/budget/budget_read_repository.dart';
import 'package:catat_cuan/domain/repositories/budget/budget_write_repository.dart';
import 'package:catat_cuan/domain/repositories/budget/budget_query_repository.dart';
import 'package:catat_cuan/domain/usecases/budget/create_budget_usecase.dart';
import 'package:catat_cuan/domain/usecases/budget/update_budget_usecase.dart';
import 'package:catat_cuan/domain/usecases/budget/delete_budget_usecase.dart';
import 'package:catat_cuan/domain/usecases/budget/get_budgets_for_month_usecase.dart';
import 'package:catat_cuan/domain/usecases/budget/get_budget_with_spent_usecase.dart';
import 'package:catat_cuan/domain/usecases/budget/check_budget_alerts_usecase.dart';
import 'package:catat_cuan/presentation/providers/repositories/repository_providers.dart';

/// ============================================================================
/// Budget Repository Providers (Segregated Interfaces)
/// ============================================================================

/// Provider for BudgetReadRepository (segregated interface)
///
/// Provides read operations for budgets.
final budgetReadRepositoryProvider = Provider<BudgetReadRepository>((ref) {
  return BudgetReadRepositoryImpl(ref.read(localDataSourceProvider));
});

/// Provider for BudgetWriteRepository (segregated interface)
///
/// Provides write operations for budgets including alert status updates.
final budgetWriteRepositoryProvider = Provider<BudgetWriteRepository>((ref) {
  return BudgetWriteRepositoryImpl(ref.read(localDataSourceProvider));
});

/// Provider for BudgetQueryRepository (segregated interface)
///
/// Provides query operations for budget spent calculation.
final budgetQueryRepositoryProvider = Provider<BudgetQueryRepository>((ref) {
  return BudgetQueryRepositoryImpl(ref.read(localDataSourceProvider));
});

/// ============================================================================
/// Budget Use Case Providers
/// ============================================================================

/// Provider for CreateBudgetUseCase
final createBudgetUseCaseProvider = Provider<CreateBudgetUseCase>((ref) {
  return CreateBudgetUseCase(ref.read(budgetWriteRepositoryProvider));
});

/// Provider for UpdateBudgetUseCase
final updateBudgetUseCaseProvider = Provider<UpdateBudgetUseCase>((ref) {
  return UpdateBudgetUseCase(ref.read(budgetWriteRepositoryProvider));
});

/// Provider for DeleteBudgetUseCase
final deleteBudgetUseCaseProvider = Provider<DeleteBudgetUseCase>((ref) {
  return DeleteBudgetUseCase(ref.read(budgetWriteRepositoryProvider));
});

/// Provider for GetBudgetsForMonthUseCase
final getBudgetsForMonthUseCaseProvider =
    Provider<GetBudgetsForMonthUseCase>((ref) {
  return GetBudgetsForMonthUseCase(ref.read(budgetReadRepositoryProvider));
});

/// Provider for GetBudgetWithSpentUseCase
final getBudgetWithSpentUseCaseProvider =
    Provider<GetBudgetWithSpentUseCase>((ref) {
  return GetBudgetWithSpentUseCase(ref.read(budgetQueryRepositoryProvider));
});

/// Provider for CheckBudgetAlertsUseCase
///
/// Per D-03: Alert check triggers after each transaction save.
/// Requires all three repository types (read, query, write).
final checkBudgetAlertsUseCaseProvider =
    Provider<CheckBudgetAlertsUseCase>((ref) {
  return CheckBudgetAlertsUseCase(
    readRepository: ref.read(budgetReadRepositoryProvider),
    queryRepository: ref.read(budgetQueryRepositoryProvider),
    writeRepository: ref.read(budgetWriteRepositoryProvider),
  );
});
