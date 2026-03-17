import 'package:catat_cuan/domain/repositories/transaction_repository.dart';
import 'package:catat_cuan/domain/usecases/add_transaction.dart';

/// Use case untuk menghapus transaksi
class DeleteTransactionUseCase {
  final TransactionRepository _repository;

  DeleteTransactionUseCase(this._repository);

  /// Execute use case untuk menghapus transaksi berdasarkan ID
  /// Melempar Exception jika transaksi tidak ditemukan atau terjadi error
  Future<void> execute(int transactionId) async {
    // Validasi ID
    if (transactionId <= 0) {
      throw ValidationException('ID transaksi tidak valid');
    }

    // Hapus dari repository
    final result = await _repository.deleteTransaction(transactionId);

    if (result.isFailure) {
      throw DatabaseException(
        result.error ?? 'Gagal menghapus transaksi',
      );
    }
  }
}
