import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_filter_state.freezed.dart';

/// Filter state untuk transaction list
/// Following SRP: Only manages filter criteria
@freezed
abstract class TransactionFilterState with _$TransactionFilterState {
  const TransactionFilterState._();

  const factory TransactionFilterState({
    /// Start date filter
    DateTime? startDate,

    /// End date filter
    DateTime? endDate,

    /// Category ID filter
    int? categoryId,

    /// Transaction type filter
    TransactionType? type,
  }) = _TransactionFilterState;

  /// Empty filter (no filters applied)
  static const empty = TransactionFilterState();

  /// Set only the type filter
  TransactionFilterState withType(TransactionType? newType) {
    return copyWith(type: newType);
  }

  /// Set only the category filter
  TransactionFilterState withCategory(int? newCategory) {
    return copyWith(categoryId: newCategory);
  }

  /// Set date range filter
  TransactionFilterState withDateRange(DateTime? start, DateTime? end) {
    return copyWith(startDate: start, endDate: end);
  }

  /// Clear type filter only
  TransactionFilterState clearType() {
    return copyWith(type: null);
  }

  /// Clear category filter only
  TransactionFilterState clearCategory() {
    return copyWith(categoryId: null);
  }

  /// Clear date range filter only
  TransactionFilterState clearDateRange() {
    return copyWith(startDate: null, endDate: null);
  }

  /// Check apakah sedang ada filter aktif
  bool get hasActiveFilter =>
      startDate != null || endDate != null || categoryId != null || type != null;
}
