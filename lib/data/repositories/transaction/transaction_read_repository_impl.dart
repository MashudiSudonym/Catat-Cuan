import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/models/transaction_model.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_read_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Implementation of read operations for transactions
///
/// This repository follows the Single Responsibility Principle (SRP)
/// by handling only read operations:
/// - Get by ID
/// - Get all transactions
///
/// For write operations, use TransactionWriteRepositoryImpl.
/// For filtering, pagination, search, and analytics, use the specialized
/// repository implementations instead.
class TransactionReadRepositoryImpl implements TransactionReadRepository {
  final DatabaseHelper _dbHelper;

  TransactionReadRepositoryImpl(this._dbHelper);

  @override
  Future<Result<TransactionEntity>> getTransactionById(int id) async {
    AppLogger.d('Fetching transaction by ID: $id');

    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTransactions,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        AppLogger.w('Transaction not found: ID $id');
        return Result.failure(
          NotFoundFailure('Transaksi dengan ID $id tidak ditemukan'),
        );
      }

      final transaction = TransactionModel.fromMap(maps.first).toEntity();
      return Result.success(transaction);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get transaction by ID: $id', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mengambil transaksi: $e'),
      );
    }
  }

  @override
  Future<Result<List<TransactionEntity>>> getTransactions() async {
    AppLogger.d('Fetching all transactions');

    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableTransactions,
        orderBy: 'date_time DESC',
      );

      final transactions = maps
          .map((map) => TransactionModel.fromMap(map).toEntity())
          .toList();

      AppLogger.i('Retrieved ${transactions.length} transactions');
      return Result.success(transactions);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get transactions', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mengambil transaksi: $e'),
      );
    }
  }
}
