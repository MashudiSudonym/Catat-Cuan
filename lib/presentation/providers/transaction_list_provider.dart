import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/usecases/get_transactions.dart';

// Export state class for use in UI
export 'transaction_list_provider.dart' show TransactionListState;

/// State untuk transaction list
class TransactionListState {
  final List<TransactionEntity> transactions;
  final bool isLoading;
  final String? error;

  // Filter state (AC-LOG-005.3)
  final DateTime? startDate;
  final DateTime? endDate;
  final int? categoryId;
  final TransactionType? type;

  const TransactionListState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
    this.startDate,
    this.endDate,
    this.categoryId,
    this.type,
  });

  TransactionListState copyWith({
    List<TransactionEntity>? transactions,
    bool? isLoading,
    String? error,
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
    bool clearFilters = false,
  }) {
    return TransactionListState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      startDate: clearFilters ? null : (startDate ?? this.startDate),
      endDate: clearFilters ? null : (endDate ?? this.endDate),
      categoryId: clearFilters ? null : (categoryId ?? this.categoryId),
      type: clearFilters ? null : (type ?? this.type),
    );
  }

  /// Check apakah sedang ada filter aktif
  bool get hasActiveFilter =>
      startDate != null || endDate != null || categoryId != null || type != null;
}

/// Notifier untuk transaction list
class TransactionListNotifier extends StateNotifier<TransactionListState> {
  final GetTransactionsUseCase _getTransactionsUseCase;

  TransactionListNotifier(this._getTransactionsUseCase)
      : super(const TransactionListState()) {
    loadTransactions();
  }

  /// Load transaksi (dengan atau tanpa filter)
  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      List<TransactionEntity> transactions;

      if (state.hasActiveFilter) {
        // Load dengan filter
        transactions = await _getTransactionsUseCase.executeWithFilter(
          startDate: state.startDate,
          endDate: state.endDate,
          categoryId: state.categoryId,
          type: state.type,
        );
      } else {
        // Load semua transaksi
        transactions = await _getTransactionsUseCase.execute();
      }

      state = state.copyWith(
        transactions: transactions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        transactions: [],
      );
    }
  }

  /// Set filter tanggal
  void setDateFilter(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
    loadTransactions();
  }

  /// Set filter kategori
  void setCategoryFilter(int? categoryId) {
    state = state.copyWith(categoryId: categoryId);
    loadTransactions();
  }

  /// Set filter tipe
  void setTypeFilter(TransactionType? type) {
    state = state.copyWith(type: type);
    loadTransactions();
  }

  /// Set semua filter sekaligus
  void setFilters({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  }) {
    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      type: type,
    );
    loadTransactions();
  }

  /// Clear semua filter
  void clearFilters() {
    state = state.copyWith(clearFilters: true);
    loadTransactions();
  }

  /// Refresh data (pull to refresh)
  Future<void> refresh() async {
    await loadTransactions();
  }
}

/// Provider untuk TransactionListNotifier
/// Note: Will be properly initialized with dependency injection in main.dart
final transactionListProvider =
    StateNotifierProvider<TransactionListNotifier, TransactionListState>((ref) {
  // TODO: Initialize with proper use case dependency
  throw UnimplementedError('TransactionListProvider not initialized - add DI setup');
});
