import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/models/budget_model.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/budget_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/budget/budget_write_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Implementation of BudgetWriteRepository
///
/// Handles creating, updating, and deleting budgets.
/// Enforces expense-only constraint per BUD-01 (no budgets for income categories).
/// Handles UNIQUE constraint per BUD-07 (one budget per category per month).
class BudgetWriteRepositoryImpl implements BudgetWriteRepository {
  final LocalDataSource _dataSource;

  BudgetWriteRepositoryImpl(this._dataSource);

  @override
  Future<Result<BudgetEntity>> createBudget({
    required int categoryId,
    required int year,
    required int month,
    required double amount,
  }) async {
    AppLogger.d('BudgetWrite: Creating budget for category $categoryId, $year-$month');

    try {
      // Validate category exists and is expense type (BUD-01 per D-17)
      final categoryResult = await _dataSource.query(
        DatabaseHelper.tableCategories,
        where: '${CategoryFields.id} = ?',
        whereArgs: [categoryId],
      );

      if (categoryResult.isEmpty) {
        AppLogger.w('BudgetWrite: Category not found: ID $categoryId');
        return Result.failure(
          NotFoundFailure('Kategori dengan ID $categoryId tidak ditemukan'),
        );
      }

      final categoryType = categoryResult.first[CategoryFields.type] as String?;
      if (categoryType != 'expense') {
        AppLogger.w('BudgetWrite: Category $categoryId is not expense type ($categoryType)');
        return Result.failure(
          ValidationFailure(
            'Anggaran hanya bisa dibuat untuk kategori pengeluaran',
          ),
        );
      }

      final now = DateTime.now();
      final model = BudgetModel(
        categoryId: categoryId,
        year: year,
        month: month,
        amount: amount,
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      );

      final id = await _dataSource.insert(
        DatabaseHelper.tableBudgets,
        model.toMap(),
      );

      // Fetch the inserted record to return complete entity
      final inserted = await _dataSource.query(
        DatabaseHelper.tableBudgets,
        where: '${BudgetFields.id} = ?',
        whereArgs: [id],
      );

      if (inserted.isEmpty) {
        AppLogger.w('BudgetWrite: Budget inserted but not found in database');
        return Result.failure(DatabaseFailure('Gagal menyimpan anggaran'));
      }

      AppLogger.i('BudgetWrite: Budget created successfully: ID $id');
      return Result.success(BudgetModel.fromMap(inserted.first).toEntity());
    } catch (e, stackTrace) {
      // Check for UNIQUE constraint violation (BUD-07)
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('unique') ||
          errorStr.contains('constraint')) {
        AppLogger.w('BudgetWrite: Duplicate budget for category $categoryId, $year-$month');
        return Result.failure(
          DatabaseFailure(
            'Budget untuk kategori ini sudah ada bulan ini',
          ),
        );
      }

      AppLogger.e('BudgetWrite: Failed to create budget', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal menambahkan anggaran'),
      );
    }
  }

  @override
  Future<Result<BudgetEntity>> updateBudget({
    required int id,
    required double amount,
  }) async {
    AppLogger.d('BudgetWrite: Updating budget ID $id');

    try {
      final now = DateTime.now().toIso8601String();

      final rowsAffected = await _dataSource.update(
        DatabaseHelper.tableBudgets,
        {
          BudgetFields.amount: amount,
          BudgetFields.updatedAt: now,
        },
        where: '${BudgetFields.id} = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        AppLogger.w('BudgetWrite: Budget not found for update: ID $id');
        return Result.failure(
          NotFoundFailure('Anggaran dengan ID $id tidak ditemukan'),
        );
      }

      // Fetch updated record
      final updated = await _dataSource.query(
        DatabaseHelper.tableBudgets,
        where: '${BudgetFields.id} = ?',
        whereArgs: [id],
      );

      AppLogger.i('BudgetWrite: Budget updated successfully: ID $id');
      return Result.success(BudgetModel.fromMap(updated.first).toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('BudgetWrite: Failed to update budget', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mengupdate anggaran'),
      );
    }
  }

  @override
  Future<Result<void>> deleteBudget(int id) async {
    AppLogger.d('BudgetWrite: Deleting budget ID $id');

    try {
      final rowsAffected = await _dataSource.delete(
        DatabaseHelper.tableBudgets,
        where: '${BudgetFields.id} = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        AppLogger.w('BudgetWrite: Budget not found for delete: ID $id');
        return Result.failure(
          NotFoundFailure('Anggaran dengan ID $id tidak ditemukan'),
        );
      }

      AppLogger.i('BudgetWrite: Budget deleted successfully: ID $id');
      return Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.e('BudgetWrite: Failed to delete budget', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal menghapus anggaran'),
      );
    }
  }
}
