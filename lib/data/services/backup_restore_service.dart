import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/backup/backup_data.dart';
import 'package:catat_cuan/domain/failures/backup_failure.dart';

/// Service for restoring backup data into the local database
///
/// Handles atomic data replacement: deletes all existing data,
/// inserts backup data within a transaction.
/// Per T-04-09: Transaction guarantees atomicity — either all
/// data is restored or none (current data preserved on failure).
/// Per D-13: Replaces all data (destructive restore).
class BackupRestoreService {
  final LocalDataSource _localDataSource;

  BackupRestoreService({required LocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  /// Atomically restores backup data into the database
  ///
  /// Replaces all existing data with backup data in a single
  /// transaction. If any step fails, the entire operation rolls
  /// back and current data is preserved.
  ///
  /// Insertion order respects foreign key constraints:
  /// 1. Delete all (reverse FK order): goal_contributions → savings_goals →
  ///    budgets → transactions → categories
  /// 2. Insert categories (no FK dependency)
  /// 3. Insert transactions (depends on categories)
  /// 4. Insert budgets (depends on categories)
  /// 5. Insert savings_goals
  /// 6. Insert goal_contributions (depends on savings_goals)
  Future<Result<void>> restoreFromData(BackupData data) async {
    try {
      await _localDataSource.transaction(() async {
        // Step 1: Delete all existing data in FK order (children first)
        await _localDataSource.delete(
          DatabaseHelper.tableGoalContributions,
        );
        await _localDataSource.delete(
          DatabaseHelper.tableSavingsGoals,
        );
        await _localDataSource.delete(
          DatabaseHelper.tableBudgets,
        );
        await _localDataSource.delete(
          DatabaseHelper.tableTransactions,
        );
        await _localDataSource.delete(
          DatabaseHelper.tableCategories,
        );

        // Step 2: Insert categories (no FK dependencies)
        for (final category in data.categories) {
          await _localDataSource.insert(DatabaseHelper.tableCategories, category);
        }

        // Step 3: Insert transactions (depends on categories)
        for (final transaction in data.transactions) {
          await _localDataSource.insert(DatabaseHelper.tableTransactions, transaction);
        }

        // Step 4: Insert budgets (depends on categories)
        for (final budget in data.budgets) {
          await _localDataSource.insert(DatabaseHelper.tableBudgets, budget);
        }

        // Step 5: Insert savings goals
        for (final goal in data.savingsGoals) {
          await _localDataSource.insert(DatabaseHelper.tableSavingsGoals, goal);
        }

        // Step 6: Insert goal contributions (depends on savings_goals)
        for (final contribution in data.goalContributions) {
          await _localDataSource.insert(DatabaseHelper.tableGoalContributions, contribution);
        }

        // Note: Settings restoration would be handled separately
        // via SharedPreferencesService as part of the full restore flow
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        BackupFailure.unknown('Gagal memulihkan data: $e'),
      );
    }
  }
}
