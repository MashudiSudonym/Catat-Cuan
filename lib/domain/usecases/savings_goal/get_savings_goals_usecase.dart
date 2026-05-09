import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/savings_goal_entity.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_read_repository.dart';

class GetSavingsGoalsUseCase extends UseCase<List<SavingsGoalEntity>, NoParams> {
  final SavingsGoalReadRepository _repository;

  GetSavingsGoalsUseCase(this._repository);

  @override
  Future<Result<List<SavingsGoalEntity>>> call(NoParams params) async {
    return await _repository.getActiveGoals();
  }
}
