import 'package:sqflite/sqflite.dart';
import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/models/monthly_summary_model.dart';
import 'package:catat_cuan/data/models/transaction_model.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/entities/paginated_result_entity.dart';
import 'package:catat_cuan/domain/entities/pagination_params_entity.dart';
import 'package:catat_cuan/domain/repositories/transaction_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Implementasi TransactionRepository dengan SQLite
///
/// This class implements the legacy monolithic TransactionRepository interface.
///
/// MIGRATION PATH:
/// This implementation returns LegacyResult for backward compatibility.
/// For new code using segregated interfaces (TransactionReadRepository, etc.),
/// use the adapter classes in the transaction/ subdirectory that wrap this
/// implementation and convert LegacyResult to domain Result.
///
/// Eventually, this class will be replaced with specialized implementations:
/// - BasicTransactionRepositoryImpl (CRUD operations)
/// - TransactionQueryRepositoryImpl (filtering and pagination)
/// - TransactionAnalyticsRepositoryImpl (summaries and breakdowns)
/// - TransactionSearchRepositoryImpl (search functionality)
/// - TransactionExportRepositoryImpl (export data preparation)
@Deprecated('Use segregated repository implementations from transaction/ subdirectory')
class TransactionRepositoryImpl implements TransactionRepository {
  final DatabaseHelper _dbHelper;

  TransactionRepositoryImpl(this._dbHelper);

  @override
  Future<LegacyResult<TransactionEntity>> addTransaction(
      TransactionEntity transaction) async {
    AppLogger.d('Adding transaction: ${transaction.type} - ${transaction.amount}');

    try {
      final db = await _dbHelper.database;

      // Convert entity ke model
      final model = TransactionModel.fromEntity(transaction);

      // Insert ke database
      final id = await db.insert(
        DatabaseHelper.tableTransactions,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      // Ambil transaksi yang baru diinsert
      final inserted = await db.query(
        DatabaseHelper.tableTransactions,
        where: '${TransactionFields.id} = ?',
        whereArgs: [id],
      );

      if (inserted.isEmpty) {
        AppLogger.w('Transaction inserted but not found in database');
        return LegacyResult.failure('Gagal menyimpan transaksi');
      }

      final insertedModel = TransactionModel.fromMap(inserted.first);
      AppLogger.i('Transaction added successfully: ID $id');
      return LegacyResult.success(insertedModel.toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('Failed to add transaction', e, stackTrace);
      return LegacyResult.failure('Gagal menyimpan transaksi');
    }
  }

  @override
  Future<LegacyResult<List<TransactionEntity>>> getTransactions() async {
    AppLogger.d('Fetching all transactions');

    try {
      final db = await _dbHelper.database;

      // Query dengan sorting by date descending (AC-LOG-005.2)
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTransactions,
        orderBy: '${TransactionFields.dateTime} DESC',
      );

      final transactions = maps
          .map((map) => TransactionModel.fromMap(map).toEntity())
          .toList();

      AppLogger.i('Retrieved ${transactions.length} transactions');
      return LegacyResult.success(transactions);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get transactions', e, stackTrace);
      return LegacyResult.failure('Gagal mengambil transaksi');
    }
  }

  @override
  Future<LegacyResult<TransactionEntity>> getTransactionById(int id) async {
    AppLogger.d('Fetching transaction by ID: $id');

    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTransactions,
        where: '${TransactionFields.id} = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        AppLogger.w('Transaction not found: ID $id');
        return LegacyResult.failure('Transaksi dengan ID $id tidak ditemukan');
      }

      final transaction = TransactionModel.fromMap(maps.first).toEntity();
      return LegacyResult.success(transaction);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get transaction by ID: $id', e, stackTrace);
      return LegacyResult.failure('Gagal mengambil transaksi');
    }
  }

  @override
  Future<LegacyResult<TransactionEntity>> updateTransaction(
      TransactionEntity transaction) async {
    AppLogger.d('Updating transaction: ID ${transaction.id}');

    try {
      if (transaction.id == null) {
        AppLogger.w('Update attempted without transaction ID');
        return LegacyResult.failure('ID transaksi wajib diisi untuk update');
      }

      final db = await _dbHelper.database;

      // Convert entity ke model
      final model = TransactionModel.fromEntity(transaction);

      // Update ke database
      final rowsAffected = await db.update(
        DatabaseHelper.tableTransactions,
        model.toMap(),
        where: '${TransactionFields.id} = ?',
        whereArgs: [transaction.id],
      );

      if (rowsAffected == 0) {
        AppLogger.w('Transaction not found for update: ID ${transaction.id}');
        return LegacyResult.failure(
            'Transaksi dengan ID ${transaction.id} tidak ditemukan');
      }

      // Ambil transaksi yang sudah diupdate
      final updated = await db.query(
        DatabaseHelper.tableTransactions,
        where: '${TransactionFields.id} = ?',
        whereArgs: [transaction.id],
      );

      if (updated.isEmpty) {
        AppLogger.w('Updated transaction not found: ID ${transaction.id}');
        return LegacyResult.failure('Gagal mengambil transaksi yang diupdate');
      }

      final updatedModel = TransactionModel.fromMap(updated.first);
      AppLogger.i('Transaction updated successfully: ID ${transaction.id}');
      return LegacyResult.success(updatedModel.toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('Failed to update transaction', e, stackTrace);
      return LegacyResult.failure('Gagal mengubah transaksi');
    }
  }

  @override
  Future<LegacyResult<void>> deleteTransaction(int id) async {
    AppLogger.d('Deleting transaction: ID $id');

    try {
      final db = await _dbHelper.database;

      final rowsAffected = await db.delete(
        DatabaseHelper.tableTransactions,
        where: '${TransactionFields.id} = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        AppLogger.w('Transaction not found for deletion: ID $id');
        return LegacyResult.failure('Transaksi dengan ID $id tidak ditemukan');
      }

      AppLogger.i('Transaction deleted successfully: ID $id');
      return LegacyResult.success(null);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to delete transaction: $id', e, stackTrace);
      return LegacyResult.failure('Gagal menghapus transaksi');
    }
  }

  @override
  Future<LegacyResult<void>> deleteAllTransactions() async {
    AppLogger.d('Deleting all transactions');

    try {
      final db = await _dbHelper.database;
      await db.delete(DatabaseHelper.tableTransactions);
      AppLogger.i('All transactions deleted successfully');
      return LegacyResult.success(null);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to delete all transactions', e, stackTrace);
      return LegacyResult.failure('Gagal menghapus semua transaksi');
    }
  }

  @override
  Future<LegacyResult<void>> deleteMultipleTransactions(List<int> ids) async {
    AppLogger.d('Deleting ${ids.length} transactions: ${ids.take(10).join(', ')}${ids.length > 10 ? '...' : ''}');

    try {
      if (ids.isEmpty) {
        AppLogger.w('Cannot delete empty list of transactions');
        return LegacyResult.failure('Daftar transaksi tidak boleh kosong');
      }

      final db = await _dbHelper.database;

      // Use batch delete for efficiency
      final batchSize = ids.length;
      var deletedCount = 0;

      // Delete in a single transaction using IN clause
      final inList = ids.map((id) => '?').join(',');
      final rowsAffected = await db.delete(
        DatabaseHelper.tableTransactions,
        where: '${TransactionFields.id} IN ($inList)',
        whereArgs: ids,
      );

      deletedCount = rowsAffected;

      if (deletedCount == 0) {
        AppLogger.w('No transactions found for deletion');
        return LegacyResult.failure('Tidak ada transaksi yang ditemukan');
      }

      AppLogger.i('Successfully deleted $deletedCount of $batchSize transactions');
      return LegacyResult.success(null);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to delete multiple transactions', e, stackTrace);
      return LegacyResult.failure('Gagal menghapus transaksi');
    }
  }

  @override
  Future<LegacyResult<List<TransactionEntity>>> getTransactionsByFilter({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  }) async {
    AppLogger.d('Fetching transactions with filter: '
        'startDate=$startDate, endDate=$endDate, categoryId=$categoryId, type=$type');

    try {
      final db = await _dbHelper.database;

      // Build WHERE clause dinamis sesuai AC-LOG-005.3
      final List<String> whereConditions = [];
      final List<dynamic> whereArgs = [];

      if (startDate != null) {
        whereConditions
            .add('date(${TransactionFields.dateTime}) >= date(?)');
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        whereConditions
            .add('date(${TransactionFields.dateTime}) <= date(?)');
        whereArgs.add(endDate.toIso8601String());
      }

      if (categoryId != null) {
        whereConditions.add('${TransactionFields.categoryId} = ?');
        whereArgs.add(categoryId);
      }

      if (type != null) {
        whereConditions.add('${TransactionFields.type} = ?');
        whereArgs.add(type.value);
      }

      final whereClause = whereConditions.isNotEmpty
          ? whereConditions.join(' AND ')
          : null;

      // Query dengan filter dan sorting by date descending
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTransactions,
        where: whereClause,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: '${TransactionFields.dateTime} DESC',
      );

      final transactions = maps
          .map((map) => TransactionModel.fromMap(map).toEntity())
          .toList();

      AppLogger.i('Retrieved ${transactions.length} filtered transactions');
      return LegacyResult.success(transactions);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get filtered transactions', e, stackTrace);
      return LegacyResult.failure('Gagal mengambil transaksi');
    }
  }

  @override
  Future<LegacyResult<MonthlySummaryEntity>> getMonthlySummary(
      String yearMonth) async {
    AppLogger.d('Fetching monthly summary: $yearMonth');

    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT
          strftime('%Y-%m', ${TransactionFields.dateTime}) as year_month,
          SUM(CASE WHEN ${TransactionFields.type} = 'income' THEN ${TransactionFields.amount} ELSE 0 END) as total_income,
          SUM(CASE WHEN ${TransactionFields.type} = 'expense' THEN ${TransactionFields.amount} ELSE 0 END) as total_expense,
          SUM(CASE WHEN ${TransactionFields.type} = 'income' THEN ${TransactionFields.amount} ELSE 0 END) -
          SUM(CASE WHEN ${TransactionFields.type} = 'expense' THEN ${TransactionFields.amount} ELSE 0 END) as balance,
          COUNT(*) as transaction_count
        FROM ${DatabaseHelper.tableTransactions}
        WHERE strftime('%Y-%m', ${TransactionFields.dateTime}) = ?
      ''', [yearMonth]);

      if (maps.isEmpty) {
        // Return empty summary jika tidak ada transaksi
        AppLogger.i('No transactions found for $yearMonth, returning empty summary');
        return LegacyResult.success(MonthlySummaryEntity(
          yearMonth: yearMonth,
          totalIncome: 0,
          totalExpense: 0,
          balance: 0,
          transactionCount: 0,
          createdAt: DateTime.now(),
        ));
      }

      final model = MonthlySummaryModel.fromMap(maps.first);
      AppLogger.i('Monthly summary retrieved for $yearMonth');
      return LegacyResult.success(model.toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get monthly summary', e, stackTrace);
      return LegacyResult.failure('Gagal mengambil ringkasan bulanan');
    }
  }

  @override
  Future<LegacyResult<MonthlySummaryEntity>> getAllTimeSummary() async {
    AppLogger.d('Fetching all-time summary');

    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT
          'all' as year_month,
          SUM(CASE WHEN ${TransactionFields.type} = 'income' THEN ${TransactionFields.amount} ELSE 0 END) as total_income,
          SUM(CASE WHEN ${TransactionFields.type} = 'expense' THEN ${TransactionFields.amount} ELSE 0 END) as total_expense,
          SUM(CASE WHEN ${TransactionFields.type} = 'income' THEN ${TransactionFields.amount} ELSE 0 END) -
          SUM(CASE WHEN ${TransactionFields.type} = 'expense' THEN ${TransactionFields.amount} ELSE 0 END) as balance,
          COUNT(*) as transaction_count
        FROM ${DatabaseHelper.tableTransactions}
      ''');

      if (maps.isEmpty) {
        // Return empty summary jika tidak ada transaksi
        AppLogger.i('No transactions found, returning empty all-time summary');
        return LegacyResult.success(MonthlySummaryEntity(
          yearMonth: 'all',
          totalIncome: 0,
          totalExpense: 0,
          balance: 0,
          transactionCount: 0,
          createdAt: DateTime.now(),
        ));
      }

      final model = MonthlySummaryModel.fromMap(maps.first);
      AppLogger.i('All-time summary retrieved');
      return LegacyResult.success(model.toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get all-time summary', e, stackTrace);
      return LegacyResult.failure('Gagal mengambil ringkasan semua data');
    }
  }

  @override
  Future<LegacyResult<List<CategoryBreakdownEntity>>> getCategoryBreakdown(
    String yearMonth,
    TransactionType type,
  ) async {
    AppLogger.d('Fetching category breakdown: $yearMonth, type=${type.value}');

    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT
          c.${CategoryFields.id},
          c.${CategoryFields.name},
          c.${CategoryFields.icon},
          c.${CategoryFields.color},
          SUM(t.${TransactionFields.amount}) as total_amount,
          COUNT(t.${TransactionFields.id}) as transaction_count
        FROM ${DatabaseHelper.tableTransactions} t
        JOIN ${DatabaseHelper.tableCategories} c ON t.${TransactionFields.categoryId} = c.${CategoryFields.id}
        WHERE strftime('%Y-%m', t.${TransactionFields.dateTime}) = ?
          AND t.${TransactionFields.type} = ?
          AND c.${CategoryFields.isActive} = 1
        GROUP BY c.${CategoryFields.id}
        ORDER BY total_amount DESC
      ''', [yearMonth, type.value]);

      if (maps.isEmpty) {
        AppLogger.i('No category breakdown found for $yearMonth');
        return LegacyResult.success([]);
      }

      // Hitung total amount untuk persentase
      final totalAmount = maps.fold<double>(
        0,
        (sum, map) => sum + ((map['total_amount'] as num?)?.toDouble() ?? 0),
      );

      final breakdown = maps
          .map((map) => CategoryBreakdownModel.fromMap(map).toEntity(totalAmount))
          .toList();

      AppLogger.i('Retrieved category breakdown: ${breakdown.length} categories');
      return LegacyResult.success(breakdown);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get category breakdown', e, stackTrace);
      return LegacyResult.failure('Gagal mengambil breakdown kategori');
    }
  }

  @override
  Future<LegacyResult<List<CategoryBreakdownEntity>>> getAllCategoryBreakdown(
    TransactionType type,
  ) async {
    AppLogger.d('Fetching all-time category breakdown: type=${type.value}');

    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT
          c.${CategoryFields.id},
          c.${CategoryFields.name},
          c.${CategoryFields.icon},
          c.${CategoryFields.color},
          SUM(t.${TransactionFields.amount}) as total_amount,
          COUNT(t.${TransactionFields.id}) as transaction_count
        FROM ${DatabaseHelper.tableTransactions} t
        JOIN ${DatabaseHelper.tableCategories} c ON t.${TransactionFields.categoryId} = c.${CategoryFields.id}
        WHERE t.${TransactionFields.type} = ?
          AND c.${CategoryFields.isActive} = 1
        GROUP BY c.${CategoryFields.id}
        ORDER BY total_amount DESC
      ''', [type.value]);

      if (maps.isEmpty) {
        AppLogger.i('No all-time category breakdown found');
        return LegacyResult.success([]);
      }

      // Hitung total amount untuk persentase
      final totalAmount = maps.fold<double>(
        0,
        (sum, map) => sum + ((map['total_amount'] as num?)?.toDouble() ?? 0),
      );

      final breakdown = maps
          .map((map) => CategoryBreakdownModel.fromMap(map).toEntity(totalAmount))
          .toList();

      AppLogger.i('Retrieved all-time category breakdown: ${breakdown.length} categories');
      return LegacyResult.success(breakdown);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get all-time category breakdown', e, stackTrace);
      return LegacyResult.failure('Gagal mengambil breakdown kategori semua data');
    }
  }

  @override
  Future<LegacyResult<List<MonthlySummaryEntity>>> getMultiMonthSummary(
    String startYearMonth,
    String endYearMonth,
  ) async {
    AppLogger.d('Fetching multi-month summary: $startYearMonth to $endYearMonth');

    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT
          strftime('%Y-%m', ${TransactionFields.dateTime}) as year_month,
          SUM(CASE WHEN ${TransactionFields.type} = 'income' THEN ${TransactionFields.amount} ELSE 0 END) as total_income,
          SUM(CASE WHEN ${TransactionFields.type} = 'expense' THEN ${TransactionFields.amount} ELSE 0 END) as total_expense,
          SUM(CASE WHEN ${TransactionFields.type} = 'income' THEN ${TransactionFields.amount} ELSE 0 END) -
          SUM(CASE WHEN ${TransactionFields.type} = 'expense' THEN ${TransactionFields.amount} ELSE 0 END) as balance,
          COUNT(*) as transaction_count
        FROM ${DatabaseHelper.tableTransactions}
        WHERE strftime('%Y-%m', ${TransactionFields.dateTime}) BETWEEN ? AND ?
        GROUP BY strftime('%Y-%m', ${TransactionFields.dateTime})
        ORDER BY year_month ASC
      ''', [startYearMonth, endYearMonth]);

      if (maps.isEmpty) {
        AppLogger.i('No multi-month summary found');
        return LegacyResult.success([]);
      }

      final summaries = maps
          .map((map) => MonthlySummaryModel.fromMap(map).toEntity())
          .toList();

      AppLogger.i('Retrieved multi-month summary: ${summaries.length} months');
      return LegacyResult.success(summaries);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get multi-month summary', e, stackTrace);
      return LegacyResult.failure('Gagal mengambil ringkasan multi-bulan');
    }
  }

  @override
  Future<LegacyResult<List<TransactionEntity>>> searchTransactions(
    String query, {
    TransactionType? type,
    int? limit,
  }) async {
    AppLogger.d('Searching transactions: query="$query", type=$type, limit=$limit');

    try {
      final db = await _dbHelper.database;

      // Search in note and category name (using JOIN)
      final String searchPattern = '%${query.toLowerCase()}%';

      String sql = '''
        SELECT t.*
        FROM ${DatabaseHelper.tableTransactions} t
        INNER JOIN ${DatabaseHelper.tableCategories} c
          ON t.${TransactionFields.categoryId} = c.${CategoryFields.id}
        WHERE (
          LOWER(t.${TransactionFields.note}) LIKE ?
          OR LOWER(c.${CategoryFields.name}) LIKE ?
        )
      ''';

      List<dynamic> args = [searchPattern, searchPattern];

      if (type != null) {
        sql += ' AND t.${TransactionFields.type} = ?';
        args.add(type.value);
      }

      sql += ' ORDER BY t.${TransactionFields.dateTime} DESC';

      if (limit != null) {
        sql += ' LIMIT ?';
        args.add(limit);
      }

      final List<Map<String, dynamic>> maps = await db.rawQuery(sql, args);

      final transactions = maps
          .map((map) => TransactionModel.fromMap(map).toEntity())
          .toList();

      AppLogger.i('Search completed: ${transactions.length} results found');
      return LegacyResult.success(transactions);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to search transactions', e, stackTrace);
      return LegacyResult.failure('Gagal mencari transaksi');
    }
  }

  /// Get transactions with category names for export
  /// Returns list of maps containing transaction data plus category name
  @override
  Future<LegacyResult<List<Map<String, dynamic>>>> getTransactionsWithCategoryNames({
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
          ON t.${TransactionFields.categoryId} = c.${CategoryFields.id}
      ''';

      // Build WHERE clause dinamis
      final List<String> whereConditions = [];
      final List<dynamic> whereArgs = [];

      if (startDate != null) {
        whereConditions.add('date(${TransactionFields.dateTime}) >= date(?)');
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        whereConditions.add('date(${TransactionFields.dateTime}) <= date(?)');
        whereArgs.add(endDate.toIso8601String());
      }

      if (categoryId != null) {
        whereConditions.add('t.${TransactionFields.categoryId} = ?');
        whereArgs.add(categoryId);
      }

      if (type != null) {
        whereConditions.add('t.${TransactionFields.type} = ?');
        whereArgs.add(type.value);
      }

      final whereClause = whereConditions.isNotEmpty
          ? 'WHERE ${whereConditions.join(' AND ')}'
          : '';

      sql += '''
        $whereClause
        ORDER BY t.${TransactionFields.dateTime} DESC
      ''';

      final List<Map<String, dynamic>> maps = await db.rawQuery(
        sql,
        whereArgs.isNotEmpty ? whereArgs : null,
      );

      AppLogger.i('Retrieved ${maps.length} transactions with category names');
      return LegacyResult.success(maps);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get transactions with category names', e, stackTrace);
      return LegacyResult.failure('Gagal mengambil transaksi');
    }
  }

  @override
  Future<PaginatedResultEntity<TransactionEntity>> getTransactionsPaginated(
    PaginationParamsEntity pagination, {
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  }) async {
    AppLogger.d('Fetching paginated transactions: page=${pagination.page}, '
        'limit=${pagination.limit}, offset=${pagination.offset}');

    try {
      final db = await _dbHelper.database;

      // Build WHERE clause dinamis
      final List<String> whereConditions = [];
      final List<dynamic> whereArgs = [];

      if (startDate != null) {
        whereConditions.add('date(${TransactionFields.dateTime}) >= date(?)');
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        whereConditions.add('date(${TransactionFields.dateTime}) <= date(?)');
        whereArgs.add(endDate.toIso8601String());
      }

      if (categoryId != null) {
        whereConditions.add('${TransactionFields.categoryId} = ?');
        whereArgs.add(categoryId);
      }

      if (type != null) {
        whereConditions.add('${TransactionFields.type} = ?');
        whereArgs.add(type.value);
      }

      final whereClause = whereConditions.isNotEmpty
          ? 'WHERE ${whereConditions.join(' AND ')}'
          : null;

      // Get total count with filter
      final countQuery = '''
        SELECT COUNT(*) FROM ${DatabaseHelper.tableTransactions}
        ${whereClause ?? ''}
      ''';

      final countResult = await db.rawQuery(
        countQuery,
        whereArgs.isNotEmpty ? whereArgs : null,
      );
      final totalItems = Sqflite.firstIntValue(countResult) ?? 0;

      // Query with pagination
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTransactions,
        where: whereClause?.replaceFirst('WHERE ', ''),
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: '${TransactionFields.dateTime} DESC',
        limit: pagination.limit,
        offset: pagination.offset,
      );

      final transactions = maps
          .map((map) => TransactionModel.fromMap(map).toEntity())
          .toList();

      AppLogger.i('Retrieved ${transactions.length} of $totalItems transactions '
          '(page ${pagination.page})');

      return PaginatedResultEntity.create(
        data: transactions,
        page: pagination.page,
        limit: pagination.limit,
        totalItems: totalItems,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get paginated transactions', e, stackTrace);
      // Return empty paginated result on error
      return PaginatedResultEntity.empty(
        page: pagination.page,
        limit: pagination.limit,
      );
    }
  }
}
