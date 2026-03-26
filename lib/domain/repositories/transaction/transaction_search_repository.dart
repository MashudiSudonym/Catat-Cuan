import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// Repository interface untuk pencarian transaksi
///
/// Following Interface Segregation Principle (ISP) - hanya berisi operasi pencarian
///
/// Responsibility: Mencari transaksi berdasarkan query text
abstract class TransactionSearchRepository {
  /// Mencari transaksi berdasarkan query text
  ///
  /// Pencarian dilakukan pada note dan nama kategori
  ///
  /// Parameters:
  /// - [query]: Kata kunci pencarian
  /// - [type]: Filter tipe transaksi (opsional)
  /// - [limit]: Batas jumlah hasil (opsional, default 50)
  ///
  /// Mengembalikan list transaksi yang cocok, diurut by date DESC
  Future<Result<List<TransactionEntity>>> searchTransactions(
    String query, {
    TransactionType? type,
    int? limit,
  });
}
