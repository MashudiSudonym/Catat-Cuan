import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/savings_goal_entity.dart';

abstract class SavingsGoalWriteRepository {
  Future<Result<SavingsGoalEntity>> createGoal({
    required String name,
    required double targetAmount,
    DateTime? targetDate,
    String? icon,
    String? color,
  });

  Future<Result<SavingsGoalEntity>> updateGoal({
    required int id,
    required String name,
    required double targetAmount,
    DateTime? targetDate,
    String? icon,
    String? color,
  });

  Future<Result<void>> softDeleteGoal(int id);
}
