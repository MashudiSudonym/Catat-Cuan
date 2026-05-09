import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/savings_goal_entity.dart';
import 'package:catat_cuan/domain/usecases/savings_goal/create_savings_goal_usecase.dart';
import 'package:catat_cuan/domain/usecases/savings_goal/update_savings_goal_usecase.dart';
import 'package:catat_cuan/domain/usecases/savings_goal/soft_delete_savings_goal_usecase.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

class SavingsGoalFormController {
  final CreateSavingsGoalUseCase _createGoalUseCase;
  final UpdateSavingsGoalUseCase _updateGoalUseCase;
  final SoftDeleteSavingsGoalUseCase _softDeleteGoalUseCase;

  SavingsGoalFormController({
    required CreateSavingsGoalUseCase createGoalUseCase,
    required UpdateSavingsGoalUseCase updateGoalUseCase,
    required SoftDeleteSavingsGoalUseCase softDeleteGoalUseCase,
  })  : _createGoalUseCase = createGoalUseCase,
        _updateGoalUseCase = updateGoalUseCase,
        _softDeleteGoalUseCase = softDeleteGoalUseCase;

  Future<Result<SavingsGoalEntity>> createGoal({
    required String name,
    required double targetAmount,
    DateTime? targetDate,
    String? icon,
    String? color,
  }) async {
    AppLogger.d('SavingsGoalForm: Creating goal "$name"');
    return await _createGoalUseCase(
      CreateSavingsGoalParams(
        name: name,
        targetAmount: targetAmount,
        targetDate: targetDate,
        icon: icon,
        color: color,
      ),
    );
  }

  Future<Result<SavingsGoalEntity>> updateGoal({
    required int id,
    required String name,
    required double targetAmount,
    DateTime? targetDate,
    String? icon,
    String? color,
  }) async {
    AppLogger.d('SavingsGoalForm: Updating goal ID $id');
    return await _updateGoalUseCase(
      UpdateSavingsGoalParams(
        id: id,
        name: name,
        targetAmount: targetAmount,
        targetDate: targetDate,
        icon: icon,
        color: color,
      ),
    );
  }

  Future<Result<void>> deleteGoal(int id) async {
    AppLogger.d('SavingsGoalForm: Deleting goal ID $id');
    return await _softDeleteGoalUseCase(id);
  }
}
