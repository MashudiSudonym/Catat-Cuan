import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/goal_contribution_entity.dart';

abstract class SavingsGoalContributionRepository {
  Future<Result<GoalContributionEntity>> addContribution({
    required int goalId,
    required double amount,
    String? note,
    required DateTime date,
  });

  Future<Result<GoalContributionEntity>> withdrawFromGoal({
    required int goalId,
    required double amount,
    String? note,
    required DateTime date,
  });

  Future<Result<List<GoalContributionEntity>>> getContributionsForGoal(int goalId);
}
