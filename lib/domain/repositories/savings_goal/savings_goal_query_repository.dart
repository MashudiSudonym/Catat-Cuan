import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/savings_goal_with_progress_entity.dart';

abstract class SavingsGoalQueryRepository {
  Future<Result<List<SavingsGoalWithProgressEntity>>> getGoalsWithProgress();

  Future<Result<SavingsGoalWithProgressEntity>> getGoalWithProgressById(int id);

  Future<Result<double>> getOverallProgress();
}
