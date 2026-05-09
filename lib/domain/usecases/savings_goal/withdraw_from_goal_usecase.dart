import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/goal_contribution_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_contribution_repository.dart';

class WithdrawFromGoalParams {
  final int goalId;
  final double amount;
  final String? reason;
  final DateTime? date;

  const WithdrawFromGoalParams({
    required this.goalId,
    required this.amount,
    this.reason,
    this.date,
  });
}

class WithdrawFromGoalUseCase extends UseCase<GoalContributionEntity, WithdrawFromGoalParams> {
  final SavingsGoalContributionRepository _repository;

  WithdrawFromGoalUseCase(this._repository);

  @override
  Future<Result<GoalContributionEntity>> call(WithdrawFromGoalParams params) async {
    if (params.amount <= 0) {
      return Result.failure(
        const ValidationFailure('Jumlah harus lebih dari 0'),
      );
    }

    try {
      return await _repository.withdrawFromGoal(
        goalId: params.goalId,
        amount: params.amount,
        note: params.reason,
        date: params.date ?? DateTime.now(),
      );
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal menarik dana dari goal: $e'),
      );
    }
  }
}
