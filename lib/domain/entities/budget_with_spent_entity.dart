import 'package:catat_cuan/domain/entities/budget_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_with_spent_entity.freezed.dart';

/// Entity combining a budget with its spent amount and progress information
///
/// Used for budget overview displays where we need to show how much of
/// each budget has been used. The spent amount is calculated from
/// expense transactions for the budget's category and month.
@freezed
abstract class BudgetWithSpentEntity with _$BudgetWithSpentEntity {
  const BudgetWithSpentEntity._();

  const factory BudgetWithSpentEntity({
    /// The base budget entity
    required BudgetEntity budget,

    /// Total spent amount for this budget's category in the budget month
    @Default(0.0) double spentAmount,

    /// Progress percentage (spentAmount / budget.amount * 100)
    @Default(0.0) double progressPercent,

    /// Remaining amount (budget.amount - spentAmount, can be negative)
    @Default(0.0) double remainingAmount,
  }) = _BudgetWithSpentEntity;

  /// Color indicator based on spending progress per BUD-03
  ///
  /// Returns:
  /// - 'green' when progress is 0-75%
  /// - 'yellow' when progress is 75-100%
  /// - 'red' when progress is over 100%
  String get progressColor {
    if (progressPercent > 100) return 'red';
    if (progressPercent > 75) return 'yellow';
    return 'green';
  }
}
