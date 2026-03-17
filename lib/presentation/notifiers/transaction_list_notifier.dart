import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/usecases/get_transactions.dart';
import 'package:catat_cuan/presentation/states/transaction_list_state.dart';
import 'package:catat_cuan/presentation/states/transaction_filter_state.dart';

/// Notifier untuk transaction list
/// Following SRP: Only manages transaction list state and loading
/// Following DIP: Depends on UseCase abstraction, not concrete implementation
class TransactionListNotifier extends StateNotifier<TransactionListState> {
  final GetTransactionsUseCase _getTransactionsUseCase;

  TransactionFilterState _filterState = const TransactionFilterState();

  TransactionListNotifier(this._getTransactionsUseCase)
      : super(const TransactionListState()) {
    loadTransactions();
  }

  /// Get current filter state (read-only)
  TransactionFilterState get filterState => _filterState;

  /// Load transaksi (dengan atau tanpa filter)
  Future<void> loadTransactions() async {
    state = const TransactionListState.loading();

    try {
      List<TransactionEntity> transactions;

      if (_filterState.hasActiveFilter) {
        // Load dengan filter
        transactions = await _getTransactionsUseCase.executeWithFilter(
          startDate: _filterState.startDate,
          endDate: _filterState.endDate,
          categoryId: _filterState.categoryId,
          type: _filterState.type,
        );
      } else {
        // Load semua transaksi
        transactions = await _getTransactionsUseCase.execute();
      }

      state = TransactionListState.data(transactions);
    } catch (e) {
      state = TransactionListState.error(e.toString());
    }
  }

  /// Set filter dan reload data
  void setFilters(TransactionFilterState filters) {
    _filterState = filters;
    loadTransactions();
  }

  /// Clear semua filter
  void clearFilters() {
    _filterState = const TransactionFilterState();
    loadTransactions();
  }

  /// Refresh data (pull to refresh)
  Future<void> refresh() async {
    await loadTransactions();
  }
}
