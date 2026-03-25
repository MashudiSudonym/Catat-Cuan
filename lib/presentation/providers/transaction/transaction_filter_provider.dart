import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:catat_cuan/presentation/states/transaction_filter_state.dart';

// Export the state for use in UI
export 'package:catat_cuan/presentation/states/transaction_filter_state.dart';

part 'transaction_filter_provider.g.dart';

/// Provider untuk transaction filter state
/// Following SRP: Only manages filter criteria for transactions
/// Uses code generation for type safety and modern Riverpod patterns
@riverpod
class TransactionFilterNotifier extends _$TransactionFilterNotifier {
  @override
  TransactionFilterState build() {
    // No constructor side effects - initialize state in build()
    return const TransactionFilterState();
  }

  /// Set filter values
  void setFilters({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  }) {
    state = TransactionFilterState(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      type: type,
    );
  }

  /// Clear semua filter
  void clearFilters() {
    state = const TransactionFilterState();
  }
}
