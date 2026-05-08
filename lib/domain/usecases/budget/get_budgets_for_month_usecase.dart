import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/budget_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/budget/budget_read_repository.dart';

/// Parameters for month-based queries
class MonthParams {
  final int year;
  final int month;

  const MonthParams({
    required this.year,
    required this.month,
  });
}

/// Use case for retrieving all budgets for a specific month
///
/// Delegates to BudgetReadRepository.
class GetBudgetsForMonthUseCase
    extends UseCase<List<BudgetEntity>, MonthParams> {
  final BudgetReadRepository _repository;

  GetBudgetsForMonthUseCase(this._repository);

  @override
  Future<Result<List<BudgetEntity>>> call(MonthParams params) async {
    try {
      return await _repository.getBudgetsForMonth(params.year, params.month);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengambil anggaran: $e'),
      );
    }
  }
}
