import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/models/savings_goal_model.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/savings_goal_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_read_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

class SavingsGoalReadRepositoryImpl implements SavingsGoalReadRepository {
  final LocalDataSource _dataSource;

  SavingsGoalReadRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<SavingsGoalEntity>>> getGoals({required String status}) async {
    AppLogger.d('SavingsGoalRead: Fetching goals with status: $status');

    try {
      final List<Map<String, dynamic>> maps = await _dataSource.query(
        DatabaseHelper.tableSavingsGoals,
        where: '${SavingsGoalFields.status} = ?',
        whereArgs: [status],
        orderBy: '${SavingsGoalFields.createdAt} DESC',
      );

      final goals = maps.map((map) => SavingsGoalModel.fromMap(map).toEntity()).toList();

      AppLogger.i('SavingsGoalRead: Retrieved ${goals.length} goals with status: $status');
      return Result.success(goals);
    } catch (e, stackTrace) {
      AppLogger.e('SavingsGoalRead: Failed to get goals', e, stackTrace);
      return Result.failure(DatabaseFailure('Gagal mengambil data tabungan'));
    }
  }

  @override
  Future<Result<SavingsGoalEntity>> getGoalById(int id) async {
    AppLogger.d('SavingsGoalRead: Fetching goal by ID: $id');

    try {
      final List<Map<String, dynamic>> maps = await _dataSource.query(
        DatabaseHelper.tableSavingsGoals,
        where: '${SavingsGoalFields.id} = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        AppLogger.w('SavingsGoalRead: Goal not found: ID $id');
        return Result.failure(NotFoundFailure('Goal dengan ID $id tidak ditemukan'));
      }

      return Result.success(SavingsGoalModel.fromMap(maps.first).toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('SavingsGoalRead: Failed to get goal by ID: $id', e, stackTrace);
      return Result.failure(DatabaseFailure('Gagal mengambil data tabungan'));
    }
  }

  @override
  Future<Result<List<SavingsGoalEntity>>> getActiveGoals() async {
    return getGoals(status: 'active');
  }
}
