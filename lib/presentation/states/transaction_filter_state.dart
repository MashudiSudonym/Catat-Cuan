import 'package:catat_cuan/domain/entities/transaction_entity.dart';

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
      type: clearFilters ? null : (type ?? this.type),
    );
  }

  /// Check apakah sedang ada filter aktif
  bool get hasActiveFilter =>
      startDate != null || endDate != null || categoryId != null || type != null;

  /// Empty filter (no filters applied)
  static const empty = TransactionFilterState();
}
