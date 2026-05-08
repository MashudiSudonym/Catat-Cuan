import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/domain/entities/budget_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_model.freezed.dart';

/// Model for mapping budget data between database and domain layer
@freezed
abstract class BudgetModel with _$BudgetModel {
  const BudgetModel._();

  const factory BudgetModel({
    /// Primary key from database (nullable for new budgets)
    int? id,

    /// Category ID this budget applies to
    required int categoryId,

    /// Year of the budget period
    required int year,

    /// Month of the budget period (1-12)
    required int month,

    /// Budget amount limit
    required double amount,

    /// Record creation timestamp as ISO8601 string
    required String createdAt,

    /// Last update timestamp as ISO8601 string
    required String updatedAt,
  }) = _BudgetModel;

  /// Convert from Map (database row) to BudgetModel
  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map[BudgetFields.id] as int?,
      categoryId: map[BudgetFields.categoryId] as int? ?? 0,
      year: map[BudgetFields.year] as int? ?? 2026,
      month: map[BudgetFields.month] as int? ?? 1,
      amount: (map[BudgetFields.amount] as num?)?.toDouble() ?? 0.0,
      createdAt:
          map[BudgetFields.createdAt]?.toString() ??
          DateTime.now().toIso8601String(),
      updatedAt:
          map[BudgetFields.updatedAt]?.toString() ??
          DateTime.now().toIso8601String(),
    );
  }

  /// Convert from BudgetModel to Map (for database insert/update)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) BudgetFields.id: id,
      BudgetFields.categoryId: categoryId,
      BudgetFields.year: year,
      BudgetFields.month: month,
      BudgetFields.amount: amount,
      BudgetFields.createdAt: createdAt,
      BudgetFields.updatedAt: updatedAt,
    };
  }

  /// Convert from BudgetModel to BudgetEntity
  BudgetEntity toEntity() {
    return BudgetEntity(
      id: id,
      categoryId: categoryId,
      year: year,
      month: month,
      amount: amount,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Convert from BudgetEntity to BudgetModel
  factory BudgetModel.fromEntity(BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      categoryId: entity.categoryId,
      year: entity.year,
      month: entity.month,
      amount: entity.amount,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }
}
