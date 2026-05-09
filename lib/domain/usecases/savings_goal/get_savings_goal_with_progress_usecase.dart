import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/savings_goal_with_progress_entity.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_query_repository.dart';

class GetSavingsGoalWithProgressUseCase extends UseCase<List<SavingsGoalWithProgressEntity>, NoParams> {
  final SavingsGoalQueryRepository _repository;

  GetSavingsGoalWithProgressUseCase(this._repository);

  @override
  Future<Result<List<SavingsGoalWithProgressEntity>>> call(NoParams params) async {
    return await _repository.getGoalsWithProgress();
  }
}
