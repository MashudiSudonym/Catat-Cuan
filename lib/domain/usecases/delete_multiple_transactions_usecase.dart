import 'package:catat_cuan/domain/repositories/transaction_repository.dart';

/// Use case untuk menghapus beberapa transaksi sekaligus (batch delete)
class DeleteMultipleTransactionsUseCase {
  final TransactionRepository _repository;

  DeleteMultipleTransactionsUseCase(this._repository);

  /// Execute use case untuk menghapus beberapa transaksi berdasarkan daftar ID
  /// Melempar Exception jika daftar kosong, ID tidak valid, atau terjadi error
  Future<void> execute(List<int> transactionIds) async {
    // Validasi daftar ID
    if (transactionIds.isEmpty) {
      throw ValidationException('Daftar transaksi tidak boleh kosong');
    }

    // Validasi setiap ID
    for (final id in transactionIds) {
      if (id <= 0) {
        throw ValidationException('ID transaksi tidak valid: $id');
      }
    }

    // Hapus dari repository
    final result = await _repository.deleteMultipleTransactions(transactionIds);

    if (result.isFailure) {
      throw DatabaseException(
        result.error ?? 'Gagal menghapus transaksi',
      );
    }
  }
}

/// Exception untuk error validasi
class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => message;
}

/// Exception untuk error database
class DatabaseException implements Exception {
  final String message;

  DatabaseException(this.message);

  @override
  String toString() => message;
}
