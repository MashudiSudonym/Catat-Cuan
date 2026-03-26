import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/usecases/transaction/transaction_filter_params.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'transaction_filter_provider.dart';
import 'package:catat_cuan/presentation/providers/usecases/transaction_usecase_providers.dart';

part 'transaction_list_provider.g.dart';

/// Provider untuk transaction list
/// Following SRP: Only manages transaction list state and loading
/// Following DIP: Depends on UseCase abstraction, not concrete implementation
/// Uses AsyncNotifier for proper async handling without constructor side effects
@riverpod
class TransactionListNotifier extends _$TransactionListNotifier {
  @override
  Future<List<TransactionEntity>> build() async {
    // No constructor side effects - data loading in build() method

    // Watch filter provider to auto-reload when filter changes
    final filterState = ref.watch(transactionFilterProvider);

    if (filterState.hasActiveFilter) {
      // Load dengan filter
      final getTransactionsByFilterUseCase = ref.read(getTransactionsByFilterUseCaseProvider);
      final result = await getTransactionsByFilterUseCase(TransactionFilterParams(
        startDate: filterState.startDate,
        endDate: filterState.endDate,
        categoryId: filterState.categoryId,
        type: filterState.type,
      ));

      if (result.isFailure) {
        AppLogger.e('Failed to load filtered transactions: ${result.failure?.message}');
        return [];
      }

      return result.data ?? [];
    } else {
      // Load semua transaksi
      final getTransactionsUseCase = ref.read(getTransactionsUseCaseProvider);
      final result = await getTransactionsUseCase(const NoParams());

      if (result.isFailure) {
        AppLogger.e('Failed to load transactions: ${result.failure?.message}');
        return [];
      }

      return result.data ?? [];
    }
  }

  /// Set filter dan reload data
  void setFilters(TransactionFilterState filters) {
    final filterNotifier = ref.read(transactionFilterProvider.notifier);
    filterNotifier.setFilters(
      startDate: filters.startDate,
      endDate: filters.endDate,
      categoryId: filters.categoryId,
      type: filters.type,
    );
    // Auto-reload happens via watch in build()
    ref.invalidateSelf();
  }

  /// Clear semua filter
  void clearFilters() {
    ref.read(transactionFilterProvider.notifier).clearFilters();
    // Auto-reload happens via watch in build()
    ref.invalidateSelf();
  }

  /// Get current filter state (for backward compatibility)
  TransactionFilterState get filterState => ref.read(transactionFilterProvider);

  /// Load transactions (alias for backward compatibility during UI migration)
  /// @deprecated Use refresh() instead
  Future<void> loadTransactions() async {
    await refresh();
  }

  /// Refresh data (pull to refresh)
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
