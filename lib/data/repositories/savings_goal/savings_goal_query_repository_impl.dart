import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/models/savings_goal_model.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/savings_goal_with_progress_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_query_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

class SavingsGoalQueryRepositoryImpl implements SavingsGoalQueryRepository {
  final LocalDataSource _dataSource;

  SavingsGoalQueryRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<SavingsGoalWithProgressEntity>>> getGoalsWithProgress() async {
    AppLogger.d('SavingsGoalQuery: Fetching goals with progress');

    try {
      final maps = await _dataSource.query(
        DatabaseHelper.tableSavingsGoals,
        where: '${SavingsGoalFields.status} = ?',
        whereArgs: ['active'],
        orderBy: '${SavingsGoalFields.createdAt} DESC',
      );

      final results = maps.map((map) {
        final goal = SavingsGoalModel.fromMap(map).toEntity();
        return SavingsGoalWithProgressEntity(goal: goal);
      }).toList();

      AppLogger.i('SavingsGoalQuery: Retrieved ${results.length} goals with progress');
      return Result.success(results);
    } catch (e, stackTrace) {
      AppLogger.e('SavingsGoalQuery: Failed to get goals with progress', e, stackTrace);
      return Result.failure(DatabaseFailure('Gagal mengambil data tabungan'));
    }
  }

  @override
  Future<Result<SavingsGoalWithProgressEntity>> getGoalWithProgressById(int id) async {
    AppLogger.d('SavingsGoalQuery: Fetching goal with progress by ID: $id');

    try {
      final maps = await _dataSource.query(
        DatabaseHelper.tableSavingsGoals,
        where: '${SavingsGoalFields.id} = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        AppLogger.w('SavingsGoalQuery: Goal not found: ID $id');
        return Result.failure(NotFoundFailure('Goal dengan ID $id tidak ditemukan'));
      }

      final goal = SavingsGoalModel.fromMap(maps.first).toEntity();
      final progress = SavingsGoalWithProgressEntity(goal: goal);

      return Result.success(progress);
    } catch (e, stackTrace) {
      AppLogger.e('SavingsGoalQuery: Failed to get goal with progress', e, stackTrace);
      return Result.failure(DatabaseFailure('Gagal mengambil data tabungan'));
    }
  }

  @override
  Future<Result<double>> getOverallProgress() async {
    AppLogger.d('SavingsGoalQuery: Calculating overall progress');

    try {
      final result = await _dataSource.rawQuery(
        'SELECT COALESCE(SUM(${SavingsGoalFields.currentAmount}), 0.0) as total_saved, COALESCE(SUM(${SavingsGoalFields.targetAmount}), 0.0) as total_target FROM ${DatabaseHelper.tableSavingsGoals} WHERE ${SavingsGoalFields.status} = ?',
        ['active'],
      );

      final totalSaved = (result.first['total_saved'] as num?)?.toDouble() ?? 0.0;
      final totalTarget = (result.first['total_target'] as num?)?.toDouble() ?? 0.0;

      if (totalTarget == 0.0) {
        return Result.success(0.0);
      }

      final percentage = (totalSaved / totalTarget * 100).clamp(0.0, 100.0);

      AppLogger.i('SavingsGoalQuery: Overall progress: ${percentage.toStringAsFixed(1)}%');
      return Result.success(percentage);
    } catch (e, stackTrace) {
      AppLogger.e('SavingsGoalQuery: Failed to calculate overall progress', e, stackTrace);
      return Result.failure(DatabaseFailure('Gagal menghitung progress tabungan'));
    }
  }
}
