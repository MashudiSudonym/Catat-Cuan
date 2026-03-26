import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/models/transaction_model.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/paginated_result_entity.dart';
import 'package:catat_cuan/domain/entities/pagination_params_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_query_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:sqflite/sqflite.dart';

/// Implementation of query and filtering operations for transactions
///
/// This repository follows the Single Responsibility Principle (SRP)
/// by handling only query operations:
/// - Filtering by date range, category, type
/// - Pagination with configurable page size
///
/// For basic CRUD operations, use TransactionReadRepositoryImpl and TransactionWriteRepositoryImpl.
/// For search operations, use TransactionSearchRepositoryImpl.
/// For analytics, use TransactionAnalyticsRepositoryImpl.
class TransactionQueryRepositoryImpl implements TransactionQueryRepository {
  final DatabaseHelper _dbHelper;

  TransactionQueryRepositoryImpl(this._dbHelper);

  @override
  Future<Result<List<TransactionEntity>>> getTransactionsByFilter({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  }) async {
    AppLogger.d(
      'Fetching transactions with filter: '
      'startDate=$startDate, endDate=$endDate, categoryId=$categoryId, type=$type',
    );

    try {
      final db = await _dbHelper.database;

      final List<String> whereConditions = [];
      final List<dynamic> whereArgs = [];

      if (startDate != null) {
        whereConditions.add('date(date_time) >= date(?)');
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        whereConditions.add('date(date_time) <= date(?)');
        whereArgs.add(endDate.toIso8601String());
      }

      if (categoryId != null) {
        whereConditions.add('category_id = ?');
        whereArgs.add(categoryId);
      }

      if (type != null) {
        whereConditions.add('type = ?');
        whereArgs.add(type.value);
      }

      final whereClause = whereConditions.isNotEmpty
          ? whereConditions.join(' AND ')
          : null;

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTransactions,
        where: whereClause,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'date_time DESC',
      );

      final transactions = maps
          .map((map) => TransactionModel.fromMap(map).toEntity())
          .toList();

      AppLogger.i('Retrieved ${transactions.length} filtered transactions');
      return Result.success(transactions);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get filtered transactions', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mengambil transaksi: $e'),
      );
    }
  }

  @override
  Future<Result<PaginatedResultEntity<TransactionEntity>>>
      getTransactionsPaginated(
    PaginationParamsEntity pagination, {
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  }) async {
    AppLogger.d(
      'Fetching paginated transactions: page=${pagination.page}, '
      'limit=${pagination.limit}, offset=${pagination.offset}',
    );

    try {
      final db = await _dbHelper.database;

      final List<String> whereConditions = [];
      final List<dynamic> whereArgs = [];

      if (startDate != null) {
        whereConditions.add('date(date_time) >= date(?)');
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        whereConditions.add('date(date_time) <= date(?)');
        whereArgs.add(endDate.toIso8601String());
      }

      if (categoryId != null) {
        whereConditions.add('category_id = ?');
        whereArgs.add(categoryId);
      }

      if (type != null) {
        whereConditions.add('type = ?');
        whereArgs.add(type.value);
      }

      final whereClause = whereConditions.isNotEmpty
          ? whereConditions.join(' AND ')
          : null;

      final countQuery = '''
        SELECT COUNT(*) FROM ${DatabaseHelper.tableTransactions}
        ${whereClause != null ? 'WHERE $whereClause' : ''}
      ''';

      final countResult = await db.rawQuery(
        countQuery,
        whereArgs.isNotEmpty ? whereArgs : null,
      );
      final totalItems = Sqflite.firstIntValue(countResult) ?? 0;

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTransactions,
        where: whereClause?.replaceFirst('WHERE ', ''),
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'date_time DESC',
        limit: pagination.limit,
        offset: pagination.offset,
      );

      final transactions = maps
          .map((map) => TransactionModel.fromMap(map).toEntity())
          .toList();

      AppLogger.i(
        'Retrieved ${transactions.length} of $totalItems transactions '
        '(page ${pagination.page})',
      );

      return Result.success(
        PaginatedResultEntity.create(
          data: transactions,
          page: pagination.page,
          limit: pagination.limit,
          totalItems: totalItems,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get paginated transactions', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mengambil transaksi: $e'),
      );
    }
  }
}
