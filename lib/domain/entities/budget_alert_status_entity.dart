import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_alert_status_entity.freezed.dart';

/// Entity tracking which budget alerts have been shown to the user
///
/// Per D-02: Alert tracking uses DB fields on the budget record.
/// Persists across sessions, survives app restart.
/// Each alert type (75% warning, 100% limit, >100% over) tracks
/// when it was last shown.
@freezed
abstract class BudgetAlertStatus with _$BudgetAlertStatus {
  const BudgetAlertStatus._();

  const factory BudgetAlertStatus({
    /// Budget ID this alert status belongs to
    required int budgetId,

    /// When the 75% warning alert was shown (null = not shown yet)
    DateTime? warningShownAt,

    /// When the 100% limit alert was shown (null = not shown yet)
    DateTime? limitShownAt,

    /// When the >100% over-budget alert was shown (null = not shown yet)
    DateTime? overShownAt,
  }) = _BudgetAlertStatus;
}
