import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/goal_contribution_entity.dart';
import 'package:catat_cuan/domain/usecases/savings_goal/add_contribution_usecase.dart';
import 'package:catat_cuan/domain/usecases/savings_goal/withdraw_from_goal_usecase.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

class SavingsGoalContributionController {
  final AddContributionUseCase _addContributionUseCase;
  final WithdrawFromGoalUseCase _withdrawFromGoalUseCase;

  SavingsGoalContributionController({
    required AddContributionUseCase addContributionUseCase,
    required WithdrawFromGoalUseCase withdrawFromGoalUseCase,
  })  : _addContributionUseCase = addContributionUseCase,
        _withdrawFromGoalUseCase = withdrawFromGoalUseCase;

  Future<Result<ContributionResult>> addContribution({
    required int goalId,
    required double amount,
    String? note,
    DateTime? date,
  }) async {
    AppLogger.d('SavingsGoalContribution: Adding contribution to goal $goalId');
    return await _addContributionUseCase(
      AddContributionParams(
        goalId: goalId,
        amount: amount,
        note: note,
        date: date,
      ),
    );
  }

  Future<Result<GoalContributionEntity>> withdrawFromGoal({
    required int goalId,
    required double amount,
    String? reason,
    DateTime? date,
  }) async {
    AppLogger.d('SavingsGoalContribution: Withdrawing from goal $goalId');
    return await _withdrawFromGoalUseCase(
      WithdrawFromGoalParams(
        goalId: goalId,
        amount: amount,
        reason: reason,
        date: date,
      ),
    );
  }
}
