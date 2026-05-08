import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/budget/budget_write_repository.dart';

/// Use case for deleting a budget by ID
///
/// Delegates to BudgetWriteRepository. No validation needed beyond ID existence.
class DeleteBudgetUseCase extends UseCase<void, int> {
  final BudgetWriteRepository _repository;

  DeleteBudgetUseCase(this._repository);

  @override
  Future<Result<void>> call(int id) async {
    try {
      return await _repository.deleteBudget(id);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal menghapus anggaran: $e'),
      );
    }
  }
}
