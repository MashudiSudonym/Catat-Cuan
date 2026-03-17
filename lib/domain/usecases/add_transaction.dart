import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/repositories/transaction_repository.dart';
import 'package:catat_cuan/domain/validators/transaction_validator.dart';

/// Use case untuk menambahkan transaksi baru
class AddTransactionUseCase {
  final TransactionRepository _repository;

  AddTransactionUseCase(this._repository);

  /// Execute use case untuk menambah transaksi
  /// Mengembalikan Result dengan TransactionEntity yang sudah disertai ID jika sukses
  /// Mengembalikan Result dengan error jika validasi gagal atau terjadi database error
  Future<TransactionEntity?> execute(TransactionEntity transaction) async {
    // Lakukan validasi menggunakan shared validator
    final validation = TransactionValidator.validateForCreation(transaction);
    if (!validation.isValid) {
      throw ValidationException(validation.error ?? 'Validasi gagal');
    }

    // Set timestamps
    final now = DateTime.now();
    final transactionToSave = transaction.copyWith(
      createdAt: now,
      updatedAt: now,
    );

    // Simpan ke repository
    final result = await _repository.addTransaction(transactionToSave);

    if (result.isFailure) {
      throw DatabaseException(result.error ?? 'Gagal menyimpan transaksi');
    }

    return result.data;
  }
}

/// Exception untuk error validasi (AC-LOG-002.2)
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
