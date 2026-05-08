import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_entity.freezed.dart';

/// Entity representing a monthly budget for an expense category
///
/// Each budget tracks a spending limit for a specific category in a specific
/// month. One budget per category per month is enforced via UNIQUE constraint
/// at the database level.
@freezed
abstract class BudgetEntity with _$BudgetEntity {
  const BudgetEntity._();

  const factory BudgetEntity({
    /// Primary key from database (nullable for new budgets)
    int? id,

    /// Category ID this budget applies to (must be expense type)
    required int categoryId,

    /// Year of the budget period (e.g., 2026)
    required int year,

    /// Month of the budget period (1-12)
    required int month,

    /// Budget amount limit
    required double amount,

    /// Record creation timestamp
    required DateTime createdAt,

    /// Last update timestamp
    required DateTime updatedAt,
  }) = _BudgetEntity;
}
