import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/savings_goal_entity.dart';

abstract class SavingsGoalReadRepository {
  Future<Result<List<SavingsGoalEntity>>> getGoals({required String status});

  Future<Result<SavingsGoalEntity>> getGoalById(int id);

  Future<Result<List<SavingsGoalEntity>>> getActiveGoals();
}
