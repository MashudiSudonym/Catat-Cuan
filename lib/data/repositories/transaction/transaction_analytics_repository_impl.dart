import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/models/category_breakdown_model.dart';
import 'package:catat_cuan/data/models/monthly_summary_model.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/category_breakdown_entity.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_analytics_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Implementation of analytics and summary operations for transactions
///
/// This repository follows the Single Responsibility Principle (SRP)
/// by handling only analytics operations:
/// - Monthly summaries
/// - Category breakdowns
/// - Multi-month trends
/// - All-time summaries
///
/// For basic CRUD operations, use TransactionReadRepositoryImpl and TransactionWriteRepositoryImpl.
/// For filtering and pagination, use TransactionQueryRepositoryImpl.
class TransactionAnalyticsRepositoryImpl
    implements TransactionAnalyticsRepository {
  final DatabaseHelper _dbHelper;

  TransactionAnalyticsRepositoryImpl(this._dbHelper);

  @override
  Future<Result<MonthlySummaryEntity>> getMonthlySummary(
    String yearMonth,
  ) async {
    AppLogger.d('Fetching monthly summary: $yearMonth');

    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT
          strftime('%Y-%m', date_time) as year_month,
          SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as total_income,
          SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as total_expense,
          SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) -
          SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as balance,
          COUNT(*) as transaction_count
        FROM ${DatabaseHelper.tableTransactions}
        WHERE strftime('%Y-%m', date_time) = ?
      ''', [yearMonth]);

      if (maps.isEmpty) {
        AppLogger.i('No transactions found for $yearMonth, returning empty summary');
        return Result.success(
          MonthlySummaryEntity(
            yearMonth: yearMonth,
            totalIncome: 0,
            totalExpense: 0,
            balance: 0,
            transactionCount: 0,
            createdAt: DateTime.now(),
          ),
        );
      }

      final model = MonthlySummaryModel.fromMap(maps.first);
      AppLogger.i('Monthly summary retrieved for $yearMonth');
      return Result.success(model.toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get monthly summary', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mengambil ringkasan bulanan: $e'),
      );
    }
  }

  @override
  Future<Result<MonthlySummaryEntity>> getAllTimeSummary() async {
    AppLogger.d('Fetching all-time summary');

    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT
          'all' as year_month,
          SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as total_income,
          SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as total_expense,
          SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) -
          SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as balance,
          COUNT(*) as transaction_count
        FROM ${DatabaseHelper.tableTransactions}
      ''');

      if (maps.isEmpty) {
        AppLogger.i('No transactions found, returning empty all-time summary');
        return Result.success(
          MonthlySummaryEntity(
            yearMonth: 'all',
            totalIncome: 0,
            totalExpense: 0,
            balance: 0,
            transactionCount: 0,
            createdAt: DateTime.now(),
          ),
        );
      }

      final model = MonthlySummaryModel.fromMap(maps.first);
      AppLogger.i('All-time summary retrieved');
      return Result.success(model.toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get all-time summary', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mengambil ringkasan semua data: $e'),
      );
    }
  }

  @override
  Future<Result<List<CategoryBreakdownEntity>>> getCategoryBreakdown(
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
          SUM(t.amount) as total_amount,
          COUNT(t.id) as transaction_count
        FROM ${DatabaseHelper.tableTransactions} t
        JOIN ${DatabaseHelper.tableCategories} c ON t.category_id = c.${CategoryFields.id}
        WHERE strftime('%Y-%m', t.date_time) = ?
          AND t.type = ?
          AND c.${CategoryFields.isActive} = 1
        GROUP BY c.${CategoryFields.id}
        ORDER BY total_amount DESC
      ''', [yearMonth, type.value]);

      if (maps.isEmpty) {
        AppLogger.i('No category breakdown found for $yearMonth');
        return Result.success([]);
      }

      final totalAmount = maps.fold<double>(
        0,
        (sum, map) => sum + ((map['total_amount'] as num?)?.toDouble() ?? 0),
      );

      final breakdown = maps
          .map((map) => CategoryBreakdownModel.fromMap(map).toEntity(totalAmount))
          .toList();

      AppLogger.i('Retrieved category breakdown: ${breakdown.length} categories');
      return Result.success(breakdown);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get category breakdown', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mengambil breakdown kategori: $e'),
      );
    }
  }

  @override
  Future<Result<List<CategoryBreakdownEntity>>> getAllCategoryBreakdown(
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
          SUM(t.amount) as total_amount,
          COUNT(t.id) as transaction_count
        FROM ${DatabaseHelper.tableTransactions} t
        JOIN ${DatabaseHelper.tableCategories} c ON t.category_id = c.${CategoryFields.id}
        WHERE t.type = ?
          AND c.${CategoryFields.isActive} = 1
        GROUP BY c.${CategoryFields.id}
        ORDER BY total_amount DESC
      ''', [type.value]);

      if (maps.isEmpty) {
        AppLogger.i('No all-time category breakdown found');
        return Result.success([]);
      }

      final totalAmount = maps.fold<double>(
        0,
        (sum, map) => sum + ((map['total_amount'] as num?)?.toDouble() ?? 0),
      );

      final breakdown = maps
          .map((map) => CategoryBreakdownModel.fromMap(map).toEntity(totalAmount))
          .toList();

      AppLogger.i(
        'Retrieved all-time category breakdown: ${breakdown.length} categories',
      );
      return Result.success(breakdown);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get all-time category breakdown', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mengambil breakdown kategori semua data: $e'),
      );
    }
  }

  @override
  Future<Result<List<MonthlySummaryEntity>>> getMultiMonthSummary(
    String startYearMonth,
    String endYearMonth,
  ) async {
    AppLogger.d(
      'Fetching multi-month summary: $startYearMonth to $endYearMonth',
    );

    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT
          strftime('%Y-%m', date_time) as year_month,
          SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as total_income,
          SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as total_expense,
          SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) -
          SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as balance,
          COUNT(*) as transaction_count
        FROM ${DatabaseHelper.tableTransactions}
        WHERE strftime('%Y-%m', date_time) BETWEEN ? AND ?
        GROUP BY strftime('%Y-%m', date_time)
        ORDER BY year_month ASC
      ''', [startYearMonth, endYearMonth]);

      if (maps.isEmpty) {
        AppLogger.i('No multi-month summary found');
        return Result.success([]);
      }

      final summaries = maps
          .map((map) => MonthlySummaryModel.fromMap(map).toEntity())
          .toList();

      AppLogger.i('Retrieved multi-month summary: ${summaries.length} months');
      return Result.success(summaries);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get multi-month summary', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mengambil ringkasan multi-bulan: $e'),
      );
    }
  }
}
