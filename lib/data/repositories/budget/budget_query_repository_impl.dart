import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/models/budget_model.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/budget_with_spent_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/budget/budget_query_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Implementation of BudgetQueryRepository
///
/// Handles budget query operations including spent amount calculation
/// by joining budgets with expense transactions.
class BudgetQueryRepositoryImpl implements BudgetQueryRepository {
  final LocalDataSource _dataSource;

  BudgetQueryRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<BudgetWithSpentEntity>>> getBudgetsWithSpent(
    int year,
    int month,
  ) async {
    AppLogger.d('BudgetQuery: Fetching budgets with spent for $year-$month');

    try {
      // Fetch all budgets for the month
      final budgetMaps = await _dataSource.query(
        DatabaseHelper.tableBudgets,
        where:
            '${BudgetFields.year} = ? AND ${BudgetFields.month} = ?',
        whereArgs: [year, month],
        orderBy: BudgetFields.categoryId,
      );

      if (budgetMaps.isEmpty) {
        AppLogger.i('BudgetQuery: No budgets found for $year-$month');
        return Result.success([]);
      }

      final List<BudgetWithSpentEntity> results = [];

      for (final budgetMap in budgetMaps) {
        final budget = BudgetModel.fromMap(budgetMap).toEntity();

        // Calculate spent amount for this budget's category in this month
        final yearStr = year.toString();
        final monthPadded = month.toString().padLeft(2, '0');

        final spentResult = await _dataSource.rawQuery(
          '''
          SELECT COALESCE(SUM(t.${TransactionFields.amount}), 0.0) as spent
          FROM ${DatabaseHelper.tableTransactions} t
          JOIN ${DatabaseHelper.tableCategories} c ON t.${TransactionFields.categoryId} = c.${CategoryFields.id}
          WHERE c.${CategoryFields.type} = 'expense'
            AND t.${TransactionFields.categoryId} = ?
            AND strftime('%Y', t.${TransactionFields.dateTime}) = ?
            AND strftime('%m', t.${TransactionFields.dateTime}) = ?
          ''',
          [budget.categoryId, yearStr, monthPadded],
        );

        final spentAmount =
            (spentResult.first['spent'] as num?)?.toDouble() ?? 0.0;
        final progressPercent = budget.amount > 0
            ? (spentAmount / budget.amount * 100)
            : 0.0;
        final remainingAmount = budget.amount - spentAmount;

        results.add(
          BudgetWithSpentEntity(
            budget: budget,
            spentAmount: spentAmount,
            progressPercent: progressPercent,
            remainingAmount: remainingAmount,
          ),
        );
      }

      AppLogger.i(
        'BudgetQuery: Retrieved ${results.length} budgets with spent for $year-$month',
      );
      return Result.success(results);
    } catch (e, stackTrace) {
      AppLogger.e('BudgetQuery: Failed to get budgets with spent', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mengambil data anggaran'),
      );
    }
  }

  @override
  Future<Result<double>> getBudgetSpentForCategory({
    required int categoryId,
    required int year,
    required int month,
  }) async {
    AppLogger.d(
      'BudgetQuery: Fetching spent for category $categoryId, $year-$month',
    );

    try {
      final yearStr = year.toString();
      final monthPadded = month.toString().padLeft(2, '0');

      final result = await _dataSource.rawQuery(
        '''
        SELECT COALESCE(SUM(t.${TransactionFields.amount}), 0.0) as spent
        FROM ${DatabaseHelper.tableTransactions} t
        JOIN ${DatabaseHelper.tableCategories} c ON t.${TransactionFields.categoryId} = c.${CategoryFields.id}
        WHERE c.${CategoryFields.type} = 'expense'
          AND t.${TransactionFields.categoryId} = ?
          AND strftime('%Y', t.${TransactionFields.dateTime}) = ?
          AND strftime('%m', t.${TransactionFields.dateTime}) = ?
        ''',
        [categoryId, yearStr, monthPadded],
      );

      final spent = (result.first['spent'] as num?)?.toDouble() ?? 0.0;

      AppLogger.d(
        'BudgetQuery: Spent for category $categoryId in $year-$month: $spent',
      );
      return Result.success(spent);
    } catch (e, stackTrace) {
      AppLogger.e('BudgetQuery: Failed to get spent for category', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal menghitung pengeluaran kategori'),
      );
    }
  }
}
