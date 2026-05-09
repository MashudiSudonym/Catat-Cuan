import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/savings_goal_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_write_repository.dart';

class UpdateSavingsGoalParams {
  final int id;
  final String name;
  final double targetAmount;
  final DateTime? targetDate;
  final String? icon;
  final String? color;

  const UpdateSavingsGoalParams({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.targetDate,
    this.icon,
    this.color,
  });
}

class UpdateSavingsGoalUseCase extends UseCase<SavingsGoalEntity, UpdateSavingsGoalParams> {
  final SavingsGoalWriteRepository _repository;

  UpdateSavingsGoalUseCase(this._repository);

  @override
  Future<Result<SavingsGoalEntity>> call(UpdateSavingsGoalParams params) async {
    if (params.name.trim().isEmpty) {
      return Result.failure(
        const ValidationFailure('Nama goal tidak boleh kosong'),
      );
    }

    if (params.targetAmount <= 0) {
      return Result.failure(
        const ValidationFailure('Target tabungan harus lebih dari 0'),
      );
    }

    try {
      return await _repository.updateGoal(
        id: params.id,
        name: params.name,
        targetAmount: params.targetAmount,
        targetDate: params.targetDate,
        icon: params.icon,
        color: params.color,
      );
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal memperbarui goal tabungan: $e'),
      );
    }
  }
}
