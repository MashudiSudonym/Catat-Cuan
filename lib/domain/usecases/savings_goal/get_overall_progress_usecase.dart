import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_query_repository.dart';

class GetOverallProgressUseCase extends UseCase<double, NoParams> {
  final SavingsGoalQueryRepository _repository;

  GetOverallProgressUseCase(this._repository);

  @override
  Future<Result<double>> call(NoParams params) async {
    return await _repository.getOverallProgress();
  }
}
