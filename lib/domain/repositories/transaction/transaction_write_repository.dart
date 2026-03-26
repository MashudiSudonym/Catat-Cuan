/// Write operations interface for Transaction Repository
///
/// This interface follows the Interface Segregation Principle (ISP)
/// by only defining write operations. Clients that only need to write
/// transactions don't need to depend on read operations.
library;

import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// Repository interface for write-only transaction operations
abstract class TransactionWriteRepository {
  /// Menambahkan transaksi baru
  ///
  /// Mengembalikan Result dengan TransactionEntity yang sudah disertai ID jika sukses
  Future<Result<TransactionEntity>> addTransaction(TransactionEntity transaction);

  /// Mengupdate transaksi yang sudah ada
  ///
  /// Mengembalikan Result dengan error jika tidak ditemukan
  Future<Result<TransactionEntity>> updateTransaction(TransactionEntity transaction);

  /// Menghapus transaksi berdasarkan ID
  ///
  /// Mengembalikan Result dengan error jika tidak ditemukan
  Future<Result<void>> deleteTransaction(int id);

  /// Menghapus SEMUA transaksi
  ///
  /// Mengembalikan Result dengan error jika gagal
  Future<Result<void>> deleteAllTransactions();

  /// Menghapus beberapa transaksi sekaligus (batch delete)
  ///
  /// Parameters:
  /// - [ids]: Daftar ID transaksi yang akan dihapus
  ///
  /// Mengembalikan Result dengan error jika gagal
  Future<Result<void>> deleteMultipleTransactions(List<int> ids);
}
