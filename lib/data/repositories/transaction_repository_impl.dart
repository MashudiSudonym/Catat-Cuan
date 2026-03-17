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

/// Implementasi TransactionRepository dengan SQLite
class TransactionRepositoryImpl implements TransactionRepository {
  final DatabaseHelper _dbHelper;

  TransactionRepositoryImpl(this._dbHelper);

  @override
  Future<Result<TransactionEntity>> addTransaction(
      TransactionEntity transaction) async {
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
        return Result.failure('Gagal menyimpan transaksi');
      }

      final insertedModel = TransactionModel.fromMap(inserted.first);
      return Result.success(insertedModel.toEntity());
    } catch (e) {
      return Result.failure('Error saat menyimpan transaksi: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<TransactionEntity>>> getTransactions() async {
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

      return Result.success(transactions);
    } catch (e) {
      return Result.failure(
          'Error saat mengambil transaksi: ${e.toString()}');
    }
  }

  @override
  Future<Result<TransactionEntity>> getTransactionById(int id) async {
    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTransactions,
        where: '${TransactionFields.id} = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        return Result.failure('Transaksi dengan ID $id tidak ditemukan');
      }

      final transaction = TransactionModel.fromMap(maps.first).toEntity();
      return Result.success(transaction);
    } catch (e) {
      return Result.failure(
          'Error saat mengambil transaksi: ${e.toString()}');
    }
  }

  @override
  Future<Result<TransactionEntity>> updateTransaction(
      TransactionEntity transaction) async {
    try {
      if (transaction.id == null) {
        return Result.failure('ID transaksi wajib diisi untuk update');
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
        return Result.failure(
            'Transaksi dengan ID ${transaction.id} tidak ditemukan');
      }

      // Ambil transaksi yang sudah diupdate
      final updated = await db.query(
        DatabaseHelper.tableTransactions,
        where: '${TransactionFields.id} = ?',
        whereArgs: [transaction.id],
      );

      if (updated.isEmpty) {
        return Result.failure('Gagal mengambil transaksi yang diupdate');
      }

      final updatedModel = TransactionModel.fromMap(updated.first);
      return Result.success(updatedModel.toEntity());
    } catch (e) {
      return Result.failure(
          'Error saat mengupdate transaksi: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteTransaction(int id) async {
    try {
      final db = await _dbHelper.database;

      final rowsAffected = await db.delete(
        DatabaseHelper.tableTransactions,
        where: '${TransactionFields.id} = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        return Result.failure('Transaksi dengan ID $id tidak ditemukan');
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure(
          'Error saat menghapus transaksi: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteAllTransactions() async {
    try {
      final db = await _dbHelper.database;
      await db.delete(DatabaseHelper.tableTransactions);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Error saat menghapus semua transaksi: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<TransactionEntity>>> getTransactionsByFilter({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  }) async {
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

      return Result.success(transactions);
    } catch (e) {
      return Result.failure(
          'Error saat mengambil transaksi: ${e.toString()}');
    }
  }

  @override
  Future<Result<MonthlySummaryEntity>> getMonthlySummary(
      String yearMonth) async {
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
        return Result.success(MonthlySummaryEntity(
          yearMonth: yearMonth,
          totalIncome: 0,
          totalExpense: 0,
          balance: 0,
          transactionCount: 0,
          createdAt: DateTime.now(),
        ));
      }

      final model = MonthlySummaryModel.fromMap(maps.first);
      return Result.success(model.toEntity());
    } catch (e) {
      return Result.failure(
          'Error saat mengambil ringkasan bulanan: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<CategoryBreakdownEntity>>> getCategoryBreakdown(
    String yearMonth,
    TransactionType type,
  ) async {
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
        return Result.success([]);
      }

      // Hitung total amount untuk persentase
      final totalAmount = maps.fold<double>(
        0,
        (sum, map) => sum + ((map['total_amount'] as num?)?.toDouble() ?? 0),
      );

      final breakdown = maps
          .map((map) => CategoryBreakdownModel.fromMap(map).toEntity(totalAmount))
          .toList();

      return Result.success(breakdown);
    } catch (e) {
      return Result.failure(
          'Error saat mengambil breakdown kategori: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<MonthlySummaryEntity>>> getMultiMonthSummary(
    String startYearMonth,
    String endYearMonth,
  ) async {
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
        return Result.success([]);
      }

      final summaries = maps
          .map((map) => MonthlySummaryModel.fromMap(map).toEntity())
          .toList();

      return Result.success(summaries);
    } catch (e) {
      return Result.failure(
          'Error saat mengambil ringkasan multi-bulan: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<TransactionEntity>>> searchTransactions(
    String query, {
    TransactionType? type,
    int? limit,
  }) async {
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

      return Result.success(transactions);
    } catch (e) {
      return Result.failure('Error saat mencari transaksi: ${e.toString()}');
    }
  }

  /// Get transactions with category names for export
  /// Returns list of maps containing transaction data plus category name
  @override
  Future<Result<List<Map<String, dynamic>>>> getTransactionsWithCategoryNames({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  }) async {
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

      return Result.success(maps);
    } catch (e) {
      return Result.failure('Error saat mengambil transaksi: ${e.toString()}');
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

      return PaginatedResultEntity.create(
        data: transactions,
        page: pagination.page,
        limit: pagination.limit,
        totalItems: totalItems,
      );
    } catch (e) {
      // Return empty paginated result on error
      return PaginatedResultEntity.empty(
        page: pagination.page,
        limit: pagination.limit,
      );
    }
  }
}
