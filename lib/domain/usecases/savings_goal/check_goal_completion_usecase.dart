import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_read_repository.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_write_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

class CheckGoalCompletionUseCase extends UseCase<bool, int> {
  final SavingsGoalReadRepository _readRepository;
  final SavingsGoalWriteRepository _writeRepository;

  CheckGoalCompletionUseCase({
    required SavingsGoalReadRepository readRepository,
    required SavingsGoalWriteRepository writeRepository,
  })  : _readRepository = readRepository,
        _writeRepository = writeRepository;

  @override
  Future<Result<bool>> call(int goalId) async {
    try {
      final goalResult = await _readRepository.getGoalById(goalId);

      if (goalResult.isFailure || goalResult.data == null) {
        return Result.success(false);
      }

      final goal = goalResult.data!;

      if (goal.status == 'completed') {
        return Result.success(false);
      }

      if (goal.currentAmount >= goal.targetAmount) {
        await _writeRepository.updateGoal(
          id: goal.id!,
          name: goal.name,
          targetAmount: goal.targetAmount,
          targetDate: goal.targetDate,
          icon: goal.icon,
          color: goal.color,
        );
        return Result.success(true);
      }

      return Result.success(false);
    } catch (e, stackTrace) {
      AppLogger.e('CheckGoalCompletion: Error', e, stackTrace);
      return Result.success(false);
    }
  }
}
