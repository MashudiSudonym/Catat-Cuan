import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_export_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Implementation of export data preparation operations for transactions
///
/// This repository follows the Single Responsibility Principle (SRP)
/// by handling only export data operations:
/// - Fetching transactions with category names for CSV export
/// - Supporting the same filters as query operations
///
/// For basic CRUD operations, use BasicTransactionRepositoryImpl.
/// For filtering and pagination, use TransactionQueryRepositoryImpl.
class TransactionExportRepositoryImpl
    implements TransactionExportRepository {
  final DatabaseHelper _dbHelper;

  TransactionExportRepositoryImpl(this._dbHelper);

  @override
  Future<Result<List<Map<String, dynamic>>>> getTransactionsWithCategoryNames({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  }) async {
    AppLogger.d('Fetching transactions with category names for export');

    try {
      final db = await _dbHelper.database;

      String sql = '''
        SELECT
          t.*,
          c.${CategoryFields.name} as category_name
        FROM ${DatabaseHelper.tableTransactions} t
        INNER JOIN ${DatabaseHelper.tableCategories} c
          ON t.category_id = c.${CategoryFields.id}
      ''';

      final List<String> whereConditions = [];
      final List<dynamic> whereArgs = [];

      if (startDate != null) {
        whereConditions.add('date(t.date_time) >= date(?)');
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        whereConditions.add('date(t.date_time) <= date(?)');
        whereArgs.add(endDate.toIso8601String());
      }

      if (categoryId != null) {
        whereConditions.add('t.category_id = ?');
        whereArgs.add(categoryId);
      }

      if (type != null) {
        whereConditions.add('t.type = ?');
        whereArgs.add(type.value);
      }

      final whereClause = whereConditions.isNotEmpty
          ? 'WHERE ${whereConditions.join(' AND ')}'
          : '';

      sql += '''
        $whereClause
        ORDER BY t.date_time DESC
      ''';

      final List<Map<String, dynamic>> maps = await db.rawQuery(
        sql,
        whereArgs.isNotEmpty ? whereArgs : null,
      );

      AppLogger.i('Retrieved ${maps.length} transactions with category names');
      return Result.success(maps);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get transactions with category names', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mengambil transaksi: $e'),
      );
    }
  }
}
