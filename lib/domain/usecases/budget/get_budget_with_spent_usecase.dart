import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/budget_with_spent_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/budget/budget_query_repository.dart';
import 'package:catat_cuan/domain/usecases/budget/get_budgets_for_month_usecase.dart';

/// Use case for retrieving budgets with spent amounts for a month
///
/// Returns BudgetWithSpentEntity list containing budget + spent + progress info.
class GetBudgetWithSpentUseCase
    extends UseCase<List<BudgetWithSpentEntity>, MonthParams> {
  final BudgetQueryRepository _repository;

  GetBudgetWithSpentUseCase(this._repository);

  @override
  Future<Result<List<BudgetWithSpentEntity>>> call(MonthParams params) async {
    try {
      return await _repository.getBudgetsWithSpent(params.year, params.month);
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengambil data anggaran: $e'),
      );
    }
  }
}
