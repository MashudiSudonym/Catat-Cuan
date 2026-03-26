/// Controller providers for SRP refactoring
///
/// Following SRP: Each controller handles a specific set of operations
/// Following DIP: Controllers depend on repository/use case abstractions
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/presentation/controllers/transaction_delete_controller.dart';
import 'package:catat_cuan/presentation/controllers/category_management_controller.dart';
import 'package:catat_cuan/presentation/providers/usecases/transaction_usecase_providers.dart';
import 'package:catat_cuan/presentation/providers/repositories/repository_providers.dart';
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
