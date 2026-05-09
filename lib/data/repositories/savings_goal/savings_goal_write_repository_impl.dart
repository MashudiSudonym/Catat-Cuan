import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/models/savings_goal_model.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/savings_goal_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_write_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

class SavingsGoalWriteRepositoryImpl implements SavingsGoalWriteRepository {
  final LocalDataSource _dataSource;

  SavingsGoalWriteRepositoryImpl(this._dataSource);

  @override
  Future<Result<SavingsGoalEntity>> createGoal({
    required String name,
    required double targetAmount,
    DateTime? targetDate,
    String? icon,
    String? color,
  }) async {
    AppLogger.d('SavingsGoalWrite: Creating goal: $name');

    try {
      final now = DateTime.now();
      final model = SavingsGoalModel(
        name: name,
        targetAmount: targetAmount,
        currentAmount: 0.0,
        targetDate: targetDate?.toIso8601String(),
        icon: icon,
        color: color,
        status: 'active',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      );

      final id = await _dataSource.insert(
        DatabaseHelper.tableSavingsGoals,
        model.toMap(),
      );

      final inserted = await _dataSource.query(
        DatabaseHelper.tableSavingsGoals,
        where: '${SavingsGoalFields.id} = ?',
        whereArgs: [id],
      );

      if (inserted.isEmpty) {
        AppLogger.w('SavingsGoalWrite: Goal inserted but not found');
        return Result.failure(DatabaseFailure('Gagal menyimpan goal'));
      }

      AppLogger.i('SavingsGoalWrite: Goal created successfully: ID $id');
      return Result.success(SavingsGoalModel.fromMap(inserted.first).toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('SavingsGoalWrite: Failed to create goal', e, stackTrace);
      return Result.failure(DatabaseFailure('Gagal menambahkan goal'));
    }
  }

  @override
  Future<Result<SavingsGoalEntity>> updateGoal({
    required int id,
    required String name,
    required double targetAmount,
    DateTime? targetDate,
    String? icon,
    String? color,
  }) async {
    AppLogger.d('SavingsGoalWrite: Updating goal ID $id');

    try {
      final now = DateTime.now().toIso8601String();

      final rowsAffected = await _dataSource.update(
        DatabaseHelper.tableSavingsGoals,
        {
          SavingsGoalFields.name: name,
          SavingsGoalFields.targetAmount: targetAmount,
          SavingsGoalFields.targetDate: targetDate?.toIso8601String(),
          SavingsGoalFields.icon: icon,
          SavingsGoalFields.color: color,
          SavingsGoalFields.updatedAt: now,
        },
        where: '${SavingsGoalFields.id} = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        AppLogger.w('SavingsGoalWrite: Goal not found for update: ID $id');
        return Result.failure(NotFoundFailure('Goal dengan ID $id tidak ditemukan'));
      }

      final updated = await _dataSource.query(
        DatabaseHelper.tableSavingsGoals,
        where: '${SavingsGoalFields.id} = ?',
        whereArgs: [id],
      );

      AppLogger.i('SavingsGoalWrite: Goal updated successfully: ID $id');
      return Result.success(SavingsGoalModel.fromMap(updated.first).toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('SavingsGoalWrite: Failed to update goal', e, stackTrace);
      return Result.failure(DatabaseFailure('Gagal mengupdate goal'));
    }
  }

  @override
  Future<Result<void>> softDeleteGoal(int id) async {
    AppLogger.d('SavingsGoalWrite: Soft deleting goal ID $id');

    try {
      final now = DateTime.now().toIso8601String();

      final rowsAffected = await _dataSource.update(
        DatabaseHelper.tableSavingsGoals,
        {
          SavingsGoalFields.status: 'cancelled',
          SavingsGoalFields.updatedAt: now,
        },
        where: '${SavingsGoalFields.id} = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        AppLogger.w('SavingsGoalWrite: Goal not found for soft delete: ID $id');
        return Result.failure(NotFoundFailure('Goal dengan ID $id tidak ditemukan'));
      }

      AppLogger.i('SavingsGoalWrite: Goal soft deleted successfully: ID $id');
      return Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.e('SavingsGoalWrite: Failed to soft delete goal', e, stackTrace);
      return Result.failure(DatabaseFailure('Gagal membatalkan goal'));
    }
  }
}
