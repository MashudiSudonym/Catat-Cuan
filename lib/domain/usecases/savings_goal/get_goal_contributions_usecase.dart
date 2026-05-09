import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/goal_contribution_entity.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_contribution_repository.dart';

class GetGoalContributionsParams {
  final int goalId;

  const GetGoalContributionsParams({required this.goalId});
}

class GetGoalContributionsUseCase extends UseCase<List<GoalContributionEntity>, GetGoalContributionsParams> {
  final SavingsGoalContributionRepository _repository;

  GetGoalContributionsUseCase(this._repository);

  @override
  Future<Result<List<GoalContributionEntity>>> call(GetGoalContributionsParams params) async {
    return await _repository.getContributionsForGoal(params.goalId);
  }
}
