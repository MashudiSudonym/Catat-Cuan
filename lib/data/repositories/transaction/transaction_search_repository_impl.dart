import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/models/transaction_model.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_search_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Implementation of search operations for transactions
///
/// This repository follows the Single Responsibility Principle (SRP)
/// by handling only search operations:
/// - Full-text search across transaction notes and category names
/// - Optional filtering by transaction type
/// - Configurable result limits
///
/// For basic CRUD operations, use TransactionReadRepositoryImpl and TransactionWriteRepositoryImpl.
/// For filtering by date range, use TransactionQueryRepositoryImpl.
class TransactionSearchRepositoryImpl
    implements TransactionSearchRepository {
  final DatabaseHelper _dbHelper;

  TransactionSearchRepositoryImpl(this._dbHelper);

  @override
  Future<Result<List<TransactionEntity>>> searchTransactions(
    String query, {
    TransactionType? type,
    int? limit,
  }) async {
    AppLogger.d(
      'Searching transactions: query="$query", type=$type, limit=$limit',
    );

    try {
      final db = await _dbHelper.database;

      final String searchPattern = '%${query.toLowerCase()}%';

      String sql = '''
        SELECT t.*
        FROM ${DatabaseHelper.tableTransactions} t
        INNER JOIN ${DatabaseHelper.tableCategories} c
          ON t.category_id = c.${CategoryFields.id}
        WHERE (
          LOWER(t.note) LIKE ?
          OR LOWER(c.${CategoryFields.name}) LIKE ?
        )
      ''';

      List<dynamic> args = [searchPattern, searchPattern];

      if (type != null) {
        sql += ' AND t.type = ?';
        args.add(type.value);
      }

      sql += ' ORDER BY t.date_time DESC';

      if (limit != null) {
        sql += ' LIMIT ?';
        args.add(limit);
      }

      final List<Map<String, dynamic>> maps = await db.rawQuery(sql, args);

      final transactions = maps
          .map((map) => TransactionModel.fromMap(map).toEntity())
          .toList();

      AppLogger.i('Search completed: ${transactions.length} results found');
      return Result.success(transactions);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to search transactions', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mencari transaksi: $e'),
      );
    }
  }
}
