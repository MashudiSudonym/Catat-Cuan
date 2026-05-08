/// Controller providers for SRP refactoring
///
/// Following SRP: Each controller handles a specific set of operations
/// Following DIP: Controllers depend on repository/use case abstractions
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/presentation/controllers/transaction_delete_controller.dart';
import 'package:catat_cuan/presentation/controllers/category_management_controller.dart';
import 'package:catat_cuan/presentation/controllers/budget/budget_form_controller.dart';
import 'package:catat_cuan/presentation/controllers/budget/budget_alert_controller.dart';
import 'package:catat_cuan/presentation/providers/usecases/transaction_usecase_providers.dart';
import 'package:catat_cuan/presentation/providers/repositories/repository_providers.dart';
import 'package:catat_cuan/presentation/providers/budget/budget_providers.dart';
export 'package:catat_cuan/presentation/controllers/receipt_scanning_controller.dart'
    show ReceiptScanningController;

// ============================================================================
// Transaction Delete Controller Provider
// ============================================================================

/// Provider for TransactionDeleteController
///
/// Handles single and batch transaction deletion operations
final transactionDeleteControllerProvider =
    Provider<TransactionDeleteController>((ref) {
  final deleteTransactionUseCase = ref.watch(deleteTransactionUseCaseProvider);
  final deleteMultipleTransactionsUseCase =
      ref.watch(deleteMultipleTransactionsUseCaseProvider);

  return TransactionDeleteController(
    deleteTransactionUseCase,
    deleteMultipleTransactionsUseCase,
  );
});

// ============================================================================
// Category Management Controller Provider
// ============================================================================

/// Provider for CategoryManagementController
///
/// Handles category reorder and deactivation operations
final categoryManagementControllerProvider =
    Provider<CategoryManagementController>((ref) {
  final managementRepository = ref.watch(categoryManagementRepositoryProvider);
  final readRepository = ref.watch(categoryReadRepositoryProvider);
  final writeRepository = ref.watch(categoryWriteRepositoryProvider);

  return CategoryManagementController(
    managementRepository,
    readRepository,
    writeRepository,
  );
});

// ============================================================================
// Budget Controller Providers
// ============================================================================

/// Provider for BudgetFormController
///
/// Manages budget CRUD form operations
final budgetFormControllerProvider = Provider<BudgetFormController>((ref) {
  return BudgetFormController(
    createBudgetUseCase: ref.read(createBudgetUseCaseProvider),
    updateBudgetUseCase: ref.read(updateBudgetUseCaseProvider),
    deleteBudgetUseCase: ref.read(deleteBudgetUseCaseProvider),
    getBudgetsForMonthUseCase: ref.read(getBudgetsForMonthUseCaseProvider),
  );
});

/// Provider for BudgetAlertController
///
/// Per D-03: Alert check triggers after each transaction save
final budgetAlertControllerProvider = Provider<BudgetAlertController>((ref) {
  return BudgetAlertController(
    ref.read(checkBudgetAlertsUseCaseProvider),
  );
});
