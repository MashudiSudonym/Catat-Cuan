import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
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
///
/// Following DIP: Depends on LocalDataSource abstraction, not concrete DatabaseHelper.
class TransactionAnalyticsRepositoryImpl
    implements TransactionAnalyticsRepository {
  final LocalDataSource _dataSource;

  TransactionAnalyticsRepositoryImpl(this._dataSource);

  @override
  Future<Result<MonthlySummaryEntity>> getMonthlySummary(
    String yearMonth,
  ) async {
    AppLogger.d('TransactionAnalytics: Fetching monthly summary for $yearMonth');

    try {
      AppLogger.d('TransactionAnalytics: Database acquired, executing query...');

      final List<Map<String, dynamic>> maps = await _dataSource.rawQuery('''
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

      AppLogger.d('TransactionAnalytics: Query returned ${maps.length} rows');

      if (maps.isEmpty) {
        AppLogger.i('TransactionAnalytics: No transactions found for $yearMonth, returning empty summary');
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
      AppLogger.i('TransactionAnalytics: Monthly summary retrieved successfully for $yearMonth');
      return Result.success(model.toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('TransactionAnalytics: Failed to get monthly summary', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mengambil ringkasan bulanan: $e'),
      );
    }
  }

  @override
  Future<Result<MonthlySummaryEntity>> getAllTimeSummary() async {
    AppLogger.d('TransactionAnalytics: Fetching all-time summary');

    try {
      AppLogger.d('TransactionAnalytics: Database acquired for all-time summary, executing query...');

      final List<Map<String, dynamic>> maps = await _dataSource.rawQuery('''
        SELECT
          'all' as year_month,
          SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as total_income,
          SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as total_expense,
          SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) -
          SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as balance,
          COUNT(*) as transaction_count
        FROM ${DatabaseHelper.tableTransactions}
      ''', null);

      AppLogger.d('TransactionAnalytics: All-time query returned ${maps.length} rows');

      if (maps.isEmpty) {
        AppLogger.i('TransactionAnalytics: No transactions found, returning empty all-time summary');
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
      AppLogger.i('TransactionAnalytics: All-time summary retrieved successfully');
      return Result.success(model.toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('TransactionAnalytics: Failed to get all-time summary', e, stackTrace);
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
    AppLogger.d('TransactionAnalytics: Fetching category breakdown for $yearMonth, type=${type.value}');

    try {
      AppLogger.d('TransactionAnalytics: Database acquired, executing breakdown query...');

      final List<Map<String, dynamic>> maps = await _dataSource.rawQuery('''
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

      AppLogger.d('TransactionAnalytics: Breakdown query returned ${maps.length} categories');

      if (maps.isEmpty) {
        AppLogger.i('TransactionAnalytics: No category breakdown found for $yearMonth');
        return Result.success([]);
      }

      final totalAmount = maps.fold<double>(
        0,
        (sum, map) => sum + ((map['total_amount'] as num?)?.toDouble() ?? 0),
      );

      final breakdown = maps
          .map((map) => CategoryBreakdownModel.fromMap(map).toEntity(totalAmount))
          .toList();

      AppLogger.i('TransactionAnalytics: Retrieved category breakdown: ${breakdown.length} categories');
      return Result.success(breakdown);
    } catch (e, stackTrace) {
      AppLogger.e('TransactionAnalytics: Failed to get category breakdown', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mengambil breakdown kategori: $e'),
      );
    }
  }

  @override
  Future<Result<List<CategoryBreakdownEntity>>> getAllCategoryBreakdown(
    TransactionType type,
  ) async {
    AppLogger.d('TransactionAnalytics: Fetching all-time category breakdown for type=${type.value}');

    try {
      AppLogger.d('TransactionAnalytics: Database acquired, executing all-time breakdown query...');

      final List<Map<String, dynamic>> maps = await _dataSource.rawQuery('''
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

      AppLogger.d('TransactionAnalytics: All-time breakdown query returned ${maps.length} categories');

      if (maps.isEmpty) {
        AppLogger.i('TransactionAnalytics: No all-time category breakdown found');
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
        'TransactionAnalytics: Retrieved all-time category breakdown: ${breakdown.length} categories',
      );
      return Result.success(breakdown);
    } catch (e, stackTrace) {
      AppLogger.e('TransactionAnalytics: Failed to get all-time category breakdown', e, stackTrace);
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
      final List<Map<String, dynamic>> maps = await _dataSource.rawQuery('''
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
