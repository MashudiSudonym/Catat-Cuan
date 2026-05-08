import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/budget_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/budget/budget_write_repository.dart';

/// Parameters for creating a budget
class CreateBudgetParams {
  final int categoryId;
  final int year;
  final int month;
  final double amount;

  const CreateBudgetParams({
    required this.categoryId,
    required this.year,
    required this.month,
    required this.amount,
  });
}

/// Use case for creating a new budget for an expense category
///
/// Validates input parameters before delegating to BudgetWriteRepository.
/// Following SRP - only handles budget creation with validation.
class CreateBudgetUseCase extends UseCase<BudgetEntity, CreateBudgetParams> {
  final BudgetWriteRepository _repository;

  CreateBudgetUseCase(this._repository);

  @override
  Future<Result<BudgetEntity>> call(CreateBudgetParams params) async {
    // Validate amount
    if (params.amount <= 0) {
      return Result.failure(
        const ValidationFailure('Jumlah anggaran harus lebih dari 0'),
      );
    }

    // Validate month
    if (params.month < 1 || params.month > 12) {
      return Result.failure(
        const ValidationFailure('Bulan harus antara 1 dan 12'),
      );
    }

    // Validate year
    if (params.year < 2020) {
      return Result.failure(
        const ValidationFailure('Tahun tidak valid'),
      );
    }

    try {
      return await _repository.createBudget(
        categoryId: params.categoryId,
        year: params.year,
        month: params.month,
        amount: params.amount,
      );
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal membuat anggaran: $e'),
      );
    }
  }
}
