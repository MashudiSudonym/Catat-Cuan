import 'package:catat_cuan/domain/repositories/transaction_repository.dart';

/// Use case untuk menghapus SEMUA transaksi
class DeleteAllTransactionsUseCase {
  final TransactionRepository _repository;

  DeleteAllTransactionsUseCase(this._repository);

  /// Execute use case untuk menghapus semua transaksi
  /// Mengembalikan Result dengan error jika gagal
  Future<void> execute() async {
    final result = await _repository.deleteAllTransactions();
    if (result.isFailure) {
      throw Exception(result.error);
    }
  }
}
