import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/models/goal_contribution_model.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/goal_contribution_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_contribution_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

class SavingsGoalContributionRepositoryImpl
    implements SavingsGoalContributionRepository {
  final LocalDataSource _dataSource;

  SavingsGoalContributionRepositoryImpl(this._dataSource);

  @override
  Future<Result<GoalContributionEntity>> addContribution({
    required int goalId,
    required double amount,
    String? note,
    required DateTime date,
  }) async {
    AppLogger.d('SavingsGoalContribution: Adding contribution to goal $goalId');

    try {
      final balanceResult = await _dataSource.rawQuery(
        'SELECT COALESCE(MAX(${GoalContributionFields.runningBalance}), 0.0) + ? as new_balance FROM ${DatabaseHelper.tableGoalContributions} WHERE ${GoalContributionFields.goalId} = ?',
        [amount, goalId],
      );
      final newBalance = (balanceResult.first['new_balance'] as num?)?.toDouble() ?? amount;

      final now = DateTime.now().toIso8601String();
      await _dataSource.insert(
        DatabaseHelper.tableGoalContributions,
        {
          GoalContributionFields.goalId: goalId,
          GoalContributionFields.amount: amount,
          GoalContributionFields.runningBalance: newBalance,
          GoalContributionFields.note: note,
          GoalContributionFields.date: date.toIso8601String(),
          GoalContributionFields.createdAt: now,
        },
      );

      await _dataSource.rawQuery(
        'UPDATE ${DatabaseHelper.tableSavingsGoals} SET ${SavingsGoalFields.currentAmount} = ${SavingsGoalFields.currentAmount} + ?, ${SavingsGoalFields.updatedAt} = ? WHERE ${SavingsGoalFields.id} = ?',
        [amount, now, goalId],
      );

      final inserted = await _dataSource.rawQuery(
        'SELECT * FROM ${DatabaseHelper.tableGoalContributions} WHERE ${GoalContributionFields.goalId} = ? ORDER BY ${GoalContributionFields.createdAt} DESC LIMIT 1',
        [goalId],
      );

      if (inserted.isEmpty) {
        return Result.failure(DatabaseFailure('Gagal menambahkan setoran'));
      }

      AppLogger.i('SavingsGoalContribution: Contribution added to goal $goalId');
      return Result.success(GoalContributionModel.fromMap(inserted.first).toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('SavingsGoalContribution: Failed to add contribution', e, stackTrace);
      return Result.failure(DatabaseFailure('Gagal menambahkan setoran'));
    }
  }

  @override
  Future<Result<GoalContributionEntity>> withdrawFromGoal({
    required int goalId,
    required double amount,
    String? note,
    required DateTime date,
  }) async {
    AppLogger.d('SavingsGoalContribution: Withdrawing from goal $goalId');

    try {
      final goalResult = await _dataSource.query(
        DatabaseHelper.tableSavingsGoals,
        where: '${SavingsGoalFields.id} = ?',
        whereArgs: [goalId],
      );

      if (goalResult.isEmpty) {
        return Result.failure(NotFoundFailure('Goal tidak ditemukan'));
      }

      final currentAmount = (goalResult.first[SavingsGoalFields.currentAmount] as num?)?.toDouble() ?? 0.0;

      if (amount > currentAmount) {
        AppLogger.w('SavingsGoalContribution: Withdrawal $amount exceeds current $currentAmount');
        return Result.failure(ValidationFailure('Jumlah penarikan melebihi saldo goal'));
      }

      final balanceResult = await _dataSource.rawQuery(
        'SELECT COALESCE(MAX(${GoalContributionFields.runningBalance}), 0.0) - ? as new_balance FROM ${DatabaseHelper.tableGoalContributions} WHERE ${GoalContributionFields.goalId} = ?',
        [amount, goalId],
      );
      final newBalance = (balanceResult.first['new_balance'] as num?)?.toDouble() ?? (currentAmount - amount);

      final now = DateTime.now().toIso8601String();
      await _dataSource.insert(
        DatabaseHelper.tableGoalContributions,
        {
          GoalContributionFields.goalId: goalId,
          GoalContributionFields.amount: -amount,
          GoalContributionFields.runningBalance: newBalance,
          GoalContributionFields.note: note,
          GoalContributionFields.date: date.toIso8601String(),
          GoalContributionFields.createdAt: now,
        },
      );

      await _dataSource.rawQuery(
        'UPDATE ${DatabaseHelper.tableSavingsGoals} SET ${SavingsGoalFields.currentAmount} = ${SavingsGoalFields.currentAmount} - ?, ${SavingsGoalFields.updatedAt} = ? WHERE ${SavingsGoalFields.id} = ?',
        [amount, now, goalId],
      );

      final inserted = await _dataSource.rawQuery(
        'SELECT * FROM ${DatabaseHelper.tableGoalContributions} WHERE ${GoalContributionFields.goalId} = ? ORDER BY ${GoalContributionFields.createdAt} DESC LIMIT 1',
        [goalId],
      );

      if (inserted.isEmpty) {
        return Result.failure(DatabaseFailure('Gagal melakukan penarikan'));
      }

      AppLogger.i('SavingsGoalContribution: Withdrawal from goal $goalId');
      return Result.success(GoalContributionModel.fromMap(inserted.first).toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('SavingsGoalContribution: Failed to withdraw', e, stackTrace);
      return Result.failure(DatabaseFailure('Gagal melakukan penarikan'));
    }
  }

  @override
  Future<Result<List<GoalContributionEntity>>> getContributionsForGoal(
    int goalId,
  ) async {
    AppLogger.d('SavingsGoalContribution: Fetching contributions for goal $goalId');

    try {
      final maps = await _dataSource.query(
        DatabaseHelper.tableGoalContributions,
        where: '${GoalContributionFields.goalId} = ?',
        whereArgs: [goalId],
        orderBy: '${GoalContributionFields.date} DESC, ${GoalContributionFields.createdAt} DESC',
      );

      final contributions = maps.map((map) => GoalContributionModel.fromMap(map).toEntity()).toList();

      AppLogger.i('SavingsGoalContribution: Retrieved ${contributions.length} contributions for goal $goalId');
      return Result.success(contributions);
    } catch (e, stackTrace) {
      AppLogger.e('SavingsGoalContribution: Failed to get contributions', e, stackTrace);
      return Result.failure(DatabaseFailure('Gagal mengambil riwayat setoran'));
    }
  }
}
