import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/repositories/transaction_repository.dart';
import 'package:catat_cuan/domain/usecases/add_transaction.dart';
import 'package:catat_cuan/domain/validators/transaction_validator.dart';

/// Use case untuk mengupdate transaksi yang sudah ada
class UpdateTransactionUseCase {
  final TransactionRepository _repository;

  UpdateTransactionUseCase(this._repository);

  /// Execute use case untuk mengupdate transaksi
  /// Mengembalikan TransactionEntity yang sudah diupdate jika sukses
  /// Melempar Exception jika validasi gagal atau transaksi tidak ditemukan
  Future<TransactionEntity?> execute(TransactionEntity transaction) async {
    // Lakukan validasi menggunakan shared validator (dengan requireId: true)
    final validation = TransactionValidator.validateForUpdate(transaction);
    if (!validation.isValid) {
      throw ValidationException(validation.error ?? 'Validasi gagal');
    }

    // Update timestamp
    final transactionToUpdate = transaction.copyWith(
      updatedAt: DateTime.now(),
    );

    // Update ke repository
    final result = await _repository.updateTransaction(transactionToUpdate);

    if (result.isFailure) {
      throw DatabaseException(result.error ?? 'Gagal mengupdate transaksi');
    }

    return result.data;
  }
}
