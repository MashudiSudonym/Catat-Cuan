import 'package:catat_cuan/domain/usecases/budget/check_budget_alerts_usecase.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Controller for triggering budget alert checks after transactions
///
/// Per D-03: Alert check triggers after each transaction save.
/// This controller is invoked from the transaction save flow to check
/// if any budget thresholds have been crossed.
///
/// Per T-02-04: Alert check must not block transaction save.
/// All exceptions are caught and result in BudgetAlertType.none.
class BudgetAlertController {
  final CheckBudgetAlertsUseCase _checkBudgetAlertsUseCase;

  BudgetAlertController(this._checkBudgetAlertsUseCase);

  /// Check budget alerts after a transaction is saved
  ///
  /// Call this after each transaction save with the transaction's
  /// category, year, and month. Returns the alert type if a threshold
  /// was crossed (first time), or BudgetAlertType.none if no alert needed.
  ///
  /// The caller can use the result to show a SnackBar or other notification.
  Future<BudgetAlertType> checkAlertsAfterTransaction({
    required int categoryId,
    required int year,
    required int month,
  }) async {
    AppLogger.d('BudgetAlert: Checking alerts for category $categoryId, $year-$month');

    try {
      final result = await _checkBudgetAlertsUseCase(
        BudgetAlertParams(
          categoryId: categoryId,
          year: year,
          month: month,
        ),
      );

      if (result.isSuccess && result.data != null) {
        final alertResult = result.data!;
        if (alertResult.type != BudgetAlertType.none) {
          AppLogger.i(
            'BudgetAlert: ${alertResult.type.name} alert triggered for category $categoryId '
            '(${alertResult.spentAmount} spent)',
          );
        }
        return alertResult.type;
      }

      return BudgetAlertType.none;
    } catch (e, stackTrace) {
      // Per T-02-04: Must not block transaction save
      AppLogger.e('BudgetAlert: Error checking alerts', e, stackTrace);
      return BudgetAlertType.none;
    }
  }
}
