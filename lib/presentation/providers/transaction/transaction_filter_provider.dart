import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

/// Filter state untuk transaction list
/// Following SRP: Only manages filter criteria
class TransactionFilterState {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? categoryId;
  final TransactionType? type;

  const TransactionFilterState({
    this.startDate,
    this.endDate,
    this.categoryId,
    this.type,
  });

  TransactionFilterState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
    bool clearFilters = false,
  }) {
    return TransactionFilterState(
      startDate: clearFilters ? null : (startDate ?? this.startDate),
      endDate: clearFilters ? null : (endDate ?? this.endDate),
      categoryId: clearFilters ? null : (categoryId ?? this.categoryId),
      // Only use the old type if the parameter wasn't provided at all
      // When type is explicitly passed as null, we should set it to null
      type: clearFilters ? null : (type ?? this.type),
      // Fix for null type: check if type parameter was provided
      // This is a workaround - the real fix would be to use a proper optional wrapper
    );
  }

  /// Set only the type filter, clearing it
  TransactionFilterState withType(TransactionType? newType) {
    return TransactionFilterState(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      type: newType,
    );
  }

  /// Set only the category filter
  TransactionFilterState withCategory(int? newCategory) {
    return TransactionFilterState(
      startDate: startDate,
      endDate: endDate,
      categoryId: newCategory,
      type: type,
    );
  }

  /// Set date range filter
  TransactionFilterState withDateRange(DateTime? start, DateTime? end) {
    return TransactionFilterState(
      startDate: start,
      endDate: end,
      categoryId: categoryId,
      type: type,
    );
  }

  /// Clear type filter only
  TransactionFilterState clearType() {
    return TransactionFilterState(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      type: null,
    );
  }

  /// Clear category filter only
  TransactionFilterState clearCategory() {
    return TransactionFilterState(
      startDate: startDate,
      endDate: endDate,
      categoryId: null,
      type: type,
    );
  }

  /// Clear date range filter only
  TransactionFilterState clearDateRange() {
    return TransactionFilterState(
      startDate: null,
      endDate: null,
      categoryId: categoryId,
      type: type,
    );
  }

  /// Check apakah sedang ada filter aktif
  bool get hasActiveFilter =>
      startDate != null || endDate != null || categoryId != null || type != null;

  /// Empty filter (no filters applied)
  static const empty = TransactionFilterState();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionFilterState &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          categoryId == other.categoryId &&
          type == other.type;

  @override
  int get hashCode =>
      startDate.hashCode ^
      endDate.hashCode ^
      categoryId.hashCode ^
      type.hashCode;
}
