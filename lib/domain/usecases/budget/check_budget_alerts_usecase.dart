import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/budget_alert_status_entity.dart';
import 'package:catat_cuan/domain/entities/budget_entity.dart';
import 'package:catat_cuan/domain/repositories/budget/budget_query_repository.dart';
import 'package:catat_cuan/domain/repositories/budget/budget_read_repository.dart';
import 'package:catat_cuan/domain/repositories/budget/budget_write_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Parameters for checking budget alerts
class BudgetAlertParams {
  final int categoryId;
  final int year;
  final int month;

  const BudgetAlertParams({
    required this.categoryId,
    required this.year,
    required this.month,
  });
}

/// Alert type enum for budget threshold notifications
enum BudgetAlertType {
  /// No alert needed
  none,

  /// Spending reached 75% of budget
  warning,

  /// Spending reached 100% of budget
  limit,

  /// Spending exceeded 100% of budget
  over,
}

/// Result of a budget alert check
class BudgetAlertResult {
  final BudgetAlertType type;
  final BudgetEntity? budget;
  final double spentAmount;

  const BudgetAlertResult({
    required this.type,
    this.budget,
    this.spentAmount = 0.0,
  });
}

/// Use case for checking budget alert thresholds per D-02/D-03
///
/// Per D-02: Alert tracking uses DB fields on budget record.
/// Per D-03: Alert check triggers after each transaction save.
///
/// Logic:
/// 1. Find budget for given category+month
/// 2. Fetch spent amount for that category+month
/// 3. Determine highest threshold crossed (>100% > 100% > 75%)
/// 4. Check if that threshold's alert was already shown
/// 5. If new alert needed: update alert_status field and return alert type
/// 6. Return BudgetAlertResult indicating which alert to show
///
/// Per T-02-04: Alert check must not block transaction save — all exceptions
/// are caught and result in BudgetAlertType.none.
class CheckBudgetAlertsUseCase
    extends UseCase<BudgetAlertResult, BudgetAlertParams> {
  final BudgetReadRepository _readRepository;
  final BudgetQueryRepository _queryRepository;
  final BudgetWriteRepository _writeRepository;

  CheckBudgetAlertsUseCase({
    required BudgetReadRepository readRepository,
    required BudgetQueryRepository queryRepository,
    required BudgetWriteRepository writeRepository,
  })  : _readRepository = readRepository,
        _queryRepository = queryRepository,
        _writeRepository = writeRepository;

  @override
  Future<Result<BudgetAlertResult>> call(BudgetAlertParams params) async {
    try {
      // 1. Find budget for this category+month
      final budgetResult = await _readRepository.getBudgetByCategoryAndMonth(
        categoryId: params.categoryId,
        year: params.year,
        month: params.month,
      );

      if (budgetResult.isFailure || budgetResult.data == null) {
        // No budget exists for this category+month → no alert
        return Result.success(const BudgetAlertResult(type: BudgetAlertType.none));
      }

      final budget = budgetResult.data!;

      // 2. Fetch spent amount
      final spentResult = await _queryRepository.getBudgetSpentForCategory(
        categoryId: params.categoryId,
        year: params.year,
        month: params.month,
      );

      if (spentResult.isFailure) {
        AppLogger.w('CheckBudgetAlerts: Failed to get spent amount');
        return Result.success(BudgetAlertResult(
          type: BudgetAlertType.none,
          budget: budget,
        ));
      }

      final spent = spentResult.data ?? 0.0;
      final progressPercent = budget.amount > 0 ? (spent / budget.amount * 100) : 0.0;

      // 3. Read current alert status
      final alertStatusResult = await _readRepository.getAlertStatus(budget.id!);

      BudgetAlertStatus alertStatus;
      if (alertStatusResult.isSuccess && alertStatusResult.data != null) {
        alertStatus = alertStatusResult.data!;
      } else {
        // Default: no alerts shown yet
        alertStatus = BudgetAlertStatus(budgetId: budget.id!);
      }

      // 4. Determine highest threshold crossed and check if already shown
      final now = DateTime.now();

      if (progressPercent > 100 && alertStatus.overShownAt == null) {
        // >100% threshold crossed, alert not yet shown
        await _writeRepository.updateAlertStatus(
          budgetId: budget.id!,
          overShownAt: now,
        );
        return Result.success(BudgetAlertResult(
          type: BudgetAlertType.over,
          budget: budget,
          spentAmount: spent,
        ));
      }

      if (progressPercent >= 100 && alertStatus.limitShownAt == null) {
        // 100% threshold crossed, alert not yet shown
        await _writeRepository.updateAlertStatus(
          budgetId: budget.id!,
          limitShownAt: now,
        );
        return Result.success(BudgetAlertResult(
          type: BudgetAlertType.limit,
          budget: budget,
          spentAmount: spent,
        ));
      }

      if (progressPercent >= 75 && alertStatus.warningShownAt == null) {
        // 75% threshold crossed, alert not yet shown
        await _writeRepository.updateAlertStatus(
          budgetId: budget.id!,
          warningShownAt: now,
        );
        return Result.success(BudgetAlertResult(
          type: BudgetAlertType.warning,
          budget: budget,
          spentAmount: spent,
        ));
      }

      // No new alert to show
      return Result.success(BudgetAlertResult(
        type: BudgetAlertType.none,
        budget: budget,
        spentAmount: spent,
      ));
    } catch (e, stackTrace) {
      // Per T-02-04: Must not block transaction save — return none on error
      AppLogger.e('CheckBudgetAlerts: Error checking alerts', e, stackTrace);
      return Result.success(const BudgetAlertResult(type: BudgetAlertType.none));
    }
  }
}
