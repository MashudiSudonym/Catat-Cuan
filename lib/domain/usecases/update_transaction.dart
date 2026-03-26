import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_write_repository.dart';
import 'package:catat_cuan/domain/validators/transaction_validator.dart';

/// Use case untuk mengupdate transaksi yang sudah ada
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles updating transactions
/// - Dependency Inversion: Depends on TransactionWriteRepository abstraction
/// - Open/Closed: Validation logic is delegated to TransactionValidator
class UpdateTransactionUseCase extends UseCase<TransactionEntity, TransactionEntity> {
  final TransactionWriteRepository _repository;

  UpdateTransactionUseCase(this._repository);

  @override
  Future<Result<TransactionEntity>> call(TransactionEntity transaction) async {
    // Lakukan validasi menggunakan shared validator (dengan requireId: true)
    final validation = TransactionValidator.validateForUpdate(transaction);
    if (!validation.isValid) {
      return Result.failure(
        ValidationFailure(validation.error ?? 'Validasi gagal'),
      );
    }

    // Update timestamp
    final transactionToUpdate = transaction.copyWith(
      updatedAt: DateTime.now(),
    );

    // Update ke repository
    try {
      final result = await _repository.updateTransaction(transactionToUpdate);
      return result;
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengupdate transaksi: $e'),
      );
    }
  }
}
