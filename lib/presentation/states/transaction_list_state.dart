import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// State untuk transaction list
/// Following SRP: Only manages transaction data and loading state
class TransactionListState {
  final List<TransactionEntity> transactions;
  final bool isLoading;
  final String? error;

  const TransactionListState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  TransactionListState copyWith({
    List<TransactionEntity>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return TransactionListState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Loading state
  const TransactionListState.loading()
      : transactions = const [],
        isLoading = true,
        error = null;

  /// Error state
  const TransactionListState.error(String message)
      : transactions = const [],
        isLoading = false,
        error = message;

  /// Data state
  const TransactionListState.data(this.transactions)
      : isLoading = false,
        error = null;
}
