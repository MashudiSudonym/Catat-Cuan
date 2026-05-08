import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/models/budget_model.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/budget_alert_status_entity.dart';
import 'package:catat_cuan/domain/entities/budget_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/budget/budget_read_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Implementation of BudgetReadRepository
///
/// Handles reading budget data from SQLite database.
/// Following SRP - only read operations.
/// Following DIP - depends on LocalDataSource abstraction.
class BudgetReadRepositoryImpl implements BudgetReadRepository {
  final LocalDataSource _dataSource;

  BudgetReadRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<BudgetEntity>>> getBudgetsForMonth(
    int year,
    int month,
  ) async {
    AppLogger.d('BudgetRead: Fetching budgets for $year-$month');

    try {
      final List<Map<String, dynamic>> maps = await _dataSource.query(
        DatabaseHelper.tableBudgets,
        where:
            '${BudgetFields.year} = ? AND ${BudgetFields.month} = ?',
        whereArgs: [year, month],
        orderBy: BudgetFields.categoryId,
      );

      final budgets =
          maps.map((map) => BudgetModel.fromMap(map).toEntity()).toList();

      AppLogger.i('BudgetRead: Retrieved ${budgets.length} budgets for $year-$month');
      return Result.success(budgets);
    } catch (e, stackTrace) {
      AppLogger.e('BudgetRead: Failed to get budgets for month', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mengambil anggaran'),
      );
    }
  }

  @override
  Future<Result<BudgetEntity>> getBudgetById(int id) async {
    AppLogger.d('BudgetRead: Fetching budget by ID: $id');

    try {
      final List<Map<String, dynamic>> maps = await _dataSource.query(
        DatabaseHelper.tableBudgets,
        where: '${BudgetFields.id} = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        AppLogger.w('BudgetRead: Budget not found: ID $id');
        return Result.failure(
          NotFoundFailure('Anggaran dengan ID $id tidak ditemukan'),
        );
      }

      return Result.success(BudgetModel.fromMap(maps.first).toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('BudgetRead: Failed to get budget by ID: $id', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mengambil anggaran'),
      );
    }
  }

  @override
  Future<Result<BudgetEntity>> getBudgetByCategoryAndMonth({
    required int categoryId,
    required int year,
    required int month,
  }) async {
    AppLogger.d('BudgetRead: Fetching budget for category $categoryId, $year-$month');

    try {
      final List<Map<String, dynamic>> maps = await _dataSource.query(
        DatabaseHelper.tableBudgets,
        where:
            '${BudgetFields.categoryId} = ? AND ${BudgetFields.year} = ? AND ${BudgetFields.month} = ?',
        whereArgs: [categoryId, year, month],
      );

      if (maps.isEmpty) {
        AppLogger.w('BudgetRead: No budget for category $categoryId, $year-$month');
        return Result.failure(
          NotFoundFailure('Budget tidak ditemukan'),
        );
      }

      return Result.success(BudgetModel.fromMap(maps.first).toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('BudgetRead: Failed to get budget by category+month', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mengambil anggaran'),
      );
    }
  }

  @override
  Future<Result<BudgetAlertStatus>> getAlertStatus(int budgetId) async {
    AppLogger.d('BudgetRead: Fetching alert status for budget $budgetId');

    try {
      final List<Map<String, dynamic>> maps = await _dataSource.query(
        DatabaseHelper.tableBudgets,
        columns: [
          BudgetFields.id,
          BudgetFields.warningShownAt,
          BudgetFields.limitShownAt,
          BudgetFields.overShownAt,
        ],
        where: '${BudgetFields.id} = ?',
        whereArgs: [budgetId],
      );

      if (maps.isEmpty) {
        return Result.failure(
          NotFoundFailure('Budget dengan ID $budgetId tidak ditemukan'),
        );
      }

      final row = maps.first;
      final status = BudgetAlertStatus(
        budgetId: budgetId,
        warningShownAt: _parseDateTime(row[BudgetFields.warningShownAt]),
        limitShownAt: _parseDateTime(row[BudgetFields.limitShownAt]),
        overShownAt: _parseDateTime(row[BudgetFields.overShownAt]),
      );

      return Result.success(status);
    } catch (e, stackTrace) {
      AppLogger.e('BudgetRead: Failed to get alert status', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mengambil status alert'),
      );
    }
  }

  /// Parse nullable datetime string from database
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
