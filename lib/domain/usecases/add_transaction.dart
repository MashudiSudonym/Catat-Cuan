import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_write_repository.dart';
import 'package:catat_cuan/domain/validators/transaction_validator.dart';

/// Use case untuk menambahkan transaksi baru
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles adding new transactions
/// - Dependency Inversion: Depends on TransactionWriteRepository abstraction
/// - Open/Closed: Validation logic is delegated to TransactionValidator
class AddTransactionUseCase extends UseCase<TransactionEntity, TransactionEntity> {
  final TransactionWriteRepository _repository;

  AddTransactionUseCase(this._repository);

  @override
  Future<Result<TransactionEntity>> call(TransactionEntity transaction) async {
    // Lakukan validasi menggunakan shared validator
    final validation = TransactionValidator.validateForCreation(transaction);
    if (!validation.isValid) {
      return Result.failure(
        ValidationFailure(validation.error ?? 'Validasi gagal'),
      );
    }

    // Set timestamps
    final now = DateTime.now();
    final transactionToSave = transaction.copyWith(
      createdAt: now,
      updatedAt: now,
    );

    // Simpan ke repository
    try {
      final result = await _repository.addTransaction(transactionToSave);
      return result;
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal menyimpan transaksi: $e'),
      );
    }
  }
}
