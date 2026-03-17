import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/repositories/transaction_repository.dart';

/// Use case untuk mengambil list transaksi
class GetTransactionsUseCase {
  final TransactionRepository _repository;

  GetTransactionsUseCase(this._repository);

  /// Mengambil semua transaksi
  /// Default sorting by date descending (terbaru di atas) sesuai AC-LOG-005.2
  Future<List<TransactionEntity>> execute() async {
    final result = await _repository.getTransactions();

    if (result.isFailure) {
      throw Exception(result.error ?? 'Gagal mengambil transaksi');
    }

    return result.data ?? [];
  }

  /// Mengambil transaksi dengan filter sesuai AC-LOG-005.3
  /// - [startDate]: Filter tanggal awal (inclusive)
  /// - [endDate]: Filter tanggal akhir (inclusive)
  /// - [categoryId]: Filter berdasarkan kategori
  /// - [type]: Filter tipe transaksi (income/expense)
  ///
  /// Default sorting by date descending (terbaru di atas)
  Future<List<TransactionEntity>> executeWithFilter({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  }) async {
    final result = await _repository.getTransactionsByFilter(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      type: type,
    );

    if (result.isFailure) {
      throw Exception(result.error ?? 'Gagal mengambil transaksi');
    }

    return result.data ?? [];
  }

  /// Mengambil transaksi berdasarkan ID
  Future<TransactionEntity?> executeById(int id) async {
    final result = await _repository.getTransactionById(id);

    if (result.isFailure) {
      throw Exception(result.error ?? 'Gagal mengambil transaksi');
    }

    return result.data;
  }
}
