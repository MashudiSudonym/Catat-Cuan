import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/repositories/transaction_repository.dart';

/// Use case untuk mencari transaksi
class SearchTransactionsUseCase {
  final TransactionRepository _repository;

  SearchTransactionsUseCase(this._repository);

  /// Mencari transaksi berdasarkan query text
  /// Pencarian dilakukan pada note dan nama kategori
  /// - [query]: Kata kunci pencarian
  /// - [type]: Filter tipe transaksi (opsional)
  /// - [limit]: Batas jumlah hasil (opsional, default 50)
  ///
  /// Mengembalikan list transaksi yang cocok, diurut by date DESC
  Future<List<TransactionEntity>> execute(
    String query, {
    TransactionType? type,
    int limit = 50,
  }) async {
    // Return empty list jika query kosong
    if (query.trim().isEmpty) {
      return [];
    }

    final result = await _repository.searchTransactions(
      query,
      type: type,
      limit: limit,
    );

    if (result.isFailure) {
      throw Exception(result.error ?? 'Gagal mencari transaksi');
    }

    return result.data ?? [];
  }
}

/// Parameter untuk pencarian transaksi
class SearchTransactionsParams {
  final String query;
  final TransactionType? type;
  final int limit;

  const SearchTransactionsParams({
    required this.query,
    this.type,
    this.limit = 50,
  });
}
