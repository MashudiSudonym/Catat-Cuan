import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_write_repository.dart';

class SoftDeleteSavingsGoalUseCase extends UseCase<void, int> {
  final SavingsGoalWriteRepository _repository;

  SoftDeleteSavingsGoalUseCase(this._repository);

  @override
  Future<Result<void>> call(int params) async {
    try {
      return await _repository.softDeleteGoal(params);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal menghapus goal tabungan: $e'),
      );
    }
  }
}
