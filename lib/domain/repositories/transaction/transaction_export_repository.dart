import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// Repository interface untuk export data transaksi
///
/// Following Interface Segregation Principle (ISP) - hanya berisi operasi export
///
/// Responsibility: Menyiapkan data transaksi untuk keperluan export
abstract class TransactionExportRepository {
  /// Mengambil transaksi dengan nama kategori untuk export
  ///
  /// Returns list of maps containing transaction data plus category name
  ///
  /// Parameters:
  /// - [startDate]: Filter tanggal awal (opsional)
  /// - [endDate]: Filter tanggal akhir (opsional)
  /// - [categoryId]: Filter kategori (opsional)
  /// - [type]: Filter tipe transaksi (opsional)
  Future<Result<List<Map<String, dynamic>>>> getTransactionsWithCategoryNames({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  });
}
