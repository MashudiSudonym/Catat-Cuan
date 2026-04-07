import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_entity.freezed.dart';

/// Entity representing a transaction (income/expense)
@freezed
abstract class TransactionEntity with _$TransactionEntity {
  const TransactionEntity._();

  const factory TransactionEntity({
    /// Primary key from database (nullable for new transactions)
    int? id,

    /// Transaction amount
    required double amount,

    /// Transaction type (income/expense)
    required TransactionType type,

    /// Transaction timestamp
    required DateTime dateTime,

    /// Foreign key to category
    required int categoryId,

    /// Additional note (optional)
    String? note,

    /// Record creation timestamp
    required DateTime createdAt,

    /// Last update timestamp
    required DateTime updatedAt,
  }) = _TransactionEntity;
}

/// Enum for transaction type
enum TransactionType {
  income('income'),
  expense('expense');

  const TransactionType(this.value);

  final String value;

  /// Get enum from string value
  /// Supports both English ('income', 'expense') and Indonesian ('pemasukan', 'pengeluaran') values
  static TransactionType fromString(String value) {
    // Try exact match first (for English values from database)
    try {
      return TransactionType.values.firstWhere(
        (type) => type.value == value,
      );
    } catch (_) {
      // Fallback to Indonesian values for backward compatibility
      return switch (value.toLowerCase()) {
        'pemasukan' || 'income' => TransactionType.income,
        'pengeluaran' || 'expense' => TransactionType.expense,
        _ => TransactionType.expense,
      };
    }
  }

  /// Get display name in Indonesian
  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Pemasukan';
      case TransactionType.expense:
        return 'Pengeluaran';
    }
  }
}
