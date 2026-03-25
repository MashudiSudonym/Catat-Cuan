import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_entity.freezed.dart';

/// Entity untuk merepresentasikan transaksi (pemasukan/pengeluaran)
@freezed
abstract class TransactionEntity with _$TransactionEntity {
  const TransactionEntity._();

  const factory TransactionEntity({
    /// Primary key dari database (nullable untuk transaksi baru)
    int? id,

    /// Nominal transaksi
    required double amount,

    /// Tipe transaksi (income/expense)
    required TransactionType type,

    /// Waktu transaksi terjadi
    required DateTime dateTime,

    /// Foreign key ke kategori
    required int categoryId,

    /// Catatan tambahan (opsional)
    String? note,

    /// Waktu pembuatan record
    required DateTime createdAt,

    /// Waktu terakhir update
    required DateTime updatedAt,
  }) = _TransactionEntity;
}

/// Enum untuk tipe transaksi
enum TransactionType {
  income('income'),
  expense('expense');

  const TransactionType(this.value);

  final String value;

  /// Get enum dari string value
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

  /// Get display name dalam Bahasa Indonesia
  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Pemasukan';
      case TransactionType.expense:
        return 'Pengeluaran';
    }
  }
}
