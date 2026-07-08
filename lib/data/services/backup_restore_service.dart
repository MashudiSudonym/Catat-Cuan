import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/backup/backup_data.dart';
import 'package:catat_cuan/domain/failures/backup_failure.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

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
      await _localDataSource.transaction((txn) async {
        // Step 1: Delete all existing data in FK order (children first)
        await txn.delete(DatabaseHelper.tableGoalContributions);
        await txn.delete(DatabaseHelper.tableSavingsGoals);
        await txn.delete(DatabaseHelper.tableBudgets);
        await txn.delete(DatabaseHelper.tableTransactions);
        await txn.delete(DatabaseHelper.tableCategories);

        // Steps 2-6: bulk-insert each table via the txn-bound batch (FK
        // order). ponytail: one sqflite batch round-trip per table instead
        // of N per-row inserts, all inside the txn so there is no lock
        // contention with the outer database.
        await _insertIfAny(txn, DatabaseHelper.tableCategories, data.categories);
        await _insertIfAny(
          txn,
          DatabaseHelper.tableTransactions,
          data.transactions,
        );
        await _insertIfAny(txn, DatabaseHelper.tableBudgets, data.budgets);
        await _insertIfAny(
          txn,
          DatabaseHelper.tableSavingsGoals,
          data.savingsGoals,
        );
        await _insertIfAny(
          txn,
          DatabaseHelper.tableGoalContributions,
          data.goalContributions,
        );
      });

      return Result.success(null);
    } catch (e, stackTrace) {
      // Per AGENTS.md Rule 4: never interpolate raw exception text into a
      // user-facing message — log it and return a static Indonesian message.
      AppLogger.e('Restore failed', e, stackTrace);
      return Result.failure(BackupFailure.unknown('Gagal memulihkan data'));
    }
  }

  /// Inserts [rows] into [table] via the txn-bound batch, skipping empty lists.
  Future<void> _insertIfAny(
    LocalDataSource txn,
    String table,
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) return;
    await txn.batchInsert(table, rows);
  }
}
