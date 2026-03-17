import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// Model untuk mapping transaksi dari/to database
class TransactionModel {
  final int? id;
  final double amount;
  final String type;
  final String dateTime;
  final int categoryId;
  final String? note;
  final String createdAt;
  final String updatedAt;

  const TransactionModel({
    this.id,
    required this.amount,
    required this.type,
    required this.dateTime,
    required this.categoryId,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert dari Map (database row) ke TransactionModel
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map[TransactionFields.id] as int?,
      amount: (map[TransactionFields.amount] as num?)?.toDouble() ?? 0.0,
      type: map[TransactionFields.type]?.toString() ?? 'expense',
      dateTime: map[TransactionFields.dateTime]?.toString() ?? DateTime.now().toIso8601String(),
      categoryId: map[TransactionFields.categoryId] as int? ?? 0,
      note: map[TransactionFields.note]?.toString(),
      createdAt: map[TransactionFields.createdAt]?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: map[TransactionFields.updatedAt]?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  /// Convert dari TransactionModel ke Map (untuk database insert/update)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) TransactionFields.id: id,
      TransactionFields.amount: amount,
      TransactionFields.type: type,
      TransactionFields.dateTime: dateTime,
      TransactionFields.categoryId: categoryId,
      TransactionFields.note: note,
      TransactionFields.createdAt: createdAt,
      TransactionFields.updatedAt: updatedAt,
    };
  }

  /// Convert dari TransactionModel ke TransactionEntity
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      amount: amount,
      type: TransactionType.fromString(type),
      dateTime: DateTime.parse(dateTime),
      categoryId: categoryId,
      note: note,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Convert dari TransactionEntity ke TransactionModel
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      amount: entity.amount,
      type: entity.type.value,
      dateTime: entity.dateTime.toIso8601String(),
      categoryId: entity.categoryId,
      note: entity.note,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  /// CopyWith method untuk immutable updates
  TransactionModel copyWith({
    int? id,
    double? amount,
    String? type,
    String? dateTime,
    int? categoryId,
    String? note,
    String? createdAt,
    String? updatedAt,
  }) {
    return TransactionModel(
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
  String toString() {
    return 'TransactionModel{id: $id, amount: $amount, type: $type, dateTime: $dateTime, categoryId: $categoryId, note: $note, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel &&
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
}
