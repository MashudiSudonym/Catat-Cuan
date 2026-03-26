import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/models/transaction_model.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_read_repository.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_write_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:sqflite/sqflite.dart';

/// Implementation of basic CRUD operations for transactions
///
/// This repository follows the Single Responsibility Principle (SRP)
/// by handling only basic read and write operations:
/// - Create (add)
/// - Read (get by ID, get all)
/// - Update
/// - Delete (single, all, multiple)
///
/// For filtering, pagination, search, and analytics, use the specialized
/// repository implementations instead.
class BasicTransactionRepositoryImpl
    implements TransactionReadRepository, TransactionWriteRepository {
  final DatabaseHelper _dbHelper;

  BasicTransactionRepositoryImpl(this._dbHelper);

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

  @override
  Future<Result<TransactionEntity>> addTransaction(
    TransactionEntity transaction,
  ) async {
    AppLogger.d('Adding transaction: ${transaction.type} - ${transaction.amount}');

    try {
      final db = await _dbHelper.database;

      final model = TransactionModel.fromEntity(transaction);

      final id = await db.insert(
        DatabaseHelper.tableTransactions,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      final inserted = await db.query(
        DatabaseHelper.tableTransactions,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (inserted.isEmpty) {
        AppLogger.w('Transaction inserted but not found in database');
        return Result.failure(
          DatabaseFailure('Gagal menyimpan transaksi'),
        );
      }

      final insertedModel = TransactionModel.fromMap(inserted.first);
      AppLogger.i('Transaction added successfully: ID $id');
      return Result.success(insertedModel.toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('Failed to add transaction', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal menyimpan transaksi: $e'),
      );
    }
  }

  @override
  Future<Result<TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  ) async {
    AppLogger.d('Updating transaction: ID ${transaction.id}');

    try {
      if (transaction.id == null) {
        AppLogger.w('Update attempted without transaction ID');
        return Result.failure(
          ValidationFailure('ID transaksi wajib diisi untuk update'),
        );
      }

      final db = await _dbHelper.database;

      final model = TransactionModel.fromEntity(transaction);

      final rowsAffected = await db.update(
        DatabaseHelper.tableTransactions,
        model.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );

      if (rowsAffected == 0) {
        AppLogger.w('Transaction not found for update: ID ${transaction.id}');
        return Result.failure(
          NotFoundFailure(
            'Transaksi dengan ID ${transaction.id} tidak ditemukan',
          ),
        );
      }

      final updated = await db.query(
        DatabaseHelper.tableTransactions,
        where: 'id = ?',
        whereArgs: [transaction.id],
      );

      if (updated.isEmpty) {
        AppLogger.w('Updated transaction not found: ID ${transaction.id}');
        return Result.failure(
          DatabaseFailure('Gagal mengambil transaksi yang diupdate'),
        );
      }

      final updatedModel = TransactionModel.fromMap(updated.first);
      AppLogger.i('Transaction updated successfully: ID ${transaction.id}');
      return Result.success(updatedModel.toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('Failed to update transaction', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal mengubah transaksi: $e'),
      );
    }
  }

  @override
  Future<Result<void>> deleteTransaction(int id) async {
    AppLogger.d('Deleting transaction: ID $id');

    try {
      final db = await _dbHelper.database;

      final rowsAffected = await db.delete(
        DatabaseHelper.tableTransactions,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        AppLogger.w('Transaction not found for deletion: ID $id');
        return Result.failure(
          NotFoundFailure('Transaksi dengan ID $id tidak ditemukan'),
        );
      }

      AppLogger.i('Transaction deleted successfully: ID $id');
      return Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to delete transaction: $id', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal menghapus transaksi: $e'),
      );
    }
  }

  @override
  Future<Result<void>> deleteAllTransactions() async {
    AppLogger.d('Deleting all transactions');

    try {
      final db = await _dbHelper.database;
      await db.delete(DatabaseHelper.tableTransactions);
      AppLogger.i('All transactions deleted successfully');
      return Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to delete all transactions', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal menghapus semua transaksi: $e'),
      );
    }
  }

  @override
  Future<Result<void>> deleteMultipleTransactions(List<int> ids) async {
    AppLogger.d(
      'Deleting ${ids.length} transactions: ${ids.take(10).join(', ')}${ids.length > 10 ? '...' : ''}',
    );

    try {
      if (ids.isEmpty) {
        AppLogger.w('Cannot delete empty list of transactions');
        return Result.failure(
          ValidationFailure('Daftar transaksi tidak boleh kosong'),
        );
      }

      final db = await _dbHelper.database;

      final inList = ids.map((id) => '?').join(',');
      final rowsAffected = await db.delete(
        DatabaseHelper.tableTransactions,
        where: 'id IN ($inList)',
        whereArgs: ids,
      );

      if (rowsAffected == 0) {
        AppLogger.w('No transactions found for deletion');
        return Result.failure(
          NotFoundFailure('Tidak ada transaksi yang ditemukan'),
        );
      }

      AppLogger.i('Successfully deleted $rowsAffected of ${ids.length} transactions');
      return Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to delete multiple transactions', e, stackTrace);
      return Result.failure(
        DatabaseFailure('Gagal menghapus transaksi: $e'),
      );
    }
  }
}
