/// Entity untuk merepresentasikan transaksi (pemasukan/pengeluaran)
class TransactionEntity {
  final int? id;
  final double amount;
  final TransactionType type;
  final DateTime dateTime;
  final int categoryId;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionEntity({
    this.id,
    required this.amount,
    required this.type,
    required this.dateTime,
    required this.categoryId,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  /// CopyWith method untuk immutable updates
  TransactionEntity copyWith({
    int? id,
    double? amount,
    TransactionType? type,
    DateTime? dateTime,
    int? categoryId,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          amount == other.amount &&
          type == other.type &&
          dateTime == other.dateTime &&
          categoryId == other.categoryId &&
          note == other.note &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      amount.hashCode ^
      type.hashCode ^
      dateTime.hashCode ^
      categoryId.hashCode ^
      note.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'TransactionEntity{id: $id, amount: $amount, type: $type, dateTime: $dateTime, categoryId: $categoryId, note: $note, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
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
