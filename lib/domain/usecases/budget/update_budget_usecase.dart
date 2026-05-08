import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/budget_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/budget/budget_write_repository.dart';

/// Parameters for updating a budget
class UpdateBudgetParams {
  final int id;
  final double amount;

  const UpdateBudgetParams({
    required this.id,
    required this.amount,
  });
}

/// Use case for updating a budget's amount
///
/// Validates amount > 0 before delegating to BudgetWriteRepository.
class UpdateBudgetUseCase extends UseCase<BudgetEntity, UpdateBudgetParams> {
  final BudgetWriteRepository _repository;

  UpdateBudgetUseCase(this._repository);

  @override
  Future<Result<BudgetEntity>> call(UpdateBudgetParams params) async {
    if (params.amount <= 0) {
      return Result.failure(
        const ValidationFailure('Jumlah anggaran harus lebih dari 0'),
      );
    }

    try {
      return await _repository.updateBudget(
        id: params.id,
        amount: params.amount,
      );
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengupdate anggaran: $e'),
      );
    }
  }
}
