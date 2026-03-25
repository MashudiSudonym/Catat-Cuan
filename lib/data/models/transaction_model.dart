import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';

/// Model untuk mapping transaksi dari/to database
@freezed
abstract class TransactionModel with _$TransactionModel {
  const TransactionModel._();

  const factory TransactionModel({
    /// Primary key dari database (nullable untuk transaksi baru)
    int? id,

    /// Nominal transaksi
    required double amount,

    /// Tipe transaksi sebagai string (income/expense) untuk database
    required String type,

    /// Waktu transaksi sebagai ISO8601 string untuk database
    required String dateTime,

    /// Foreign key ke kategori
    required int categoryId,

    /// Catatan tambahan (opsional)
    String? note,

    /// Waktu pembuatan record sebagai ISO8601 string untuk database
    required String createdAt,

    /// Waktu terakhir update sebagai ISO8601 string untuk database
    required String updatedAt,
  }) = _TransactionModel;

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
}
