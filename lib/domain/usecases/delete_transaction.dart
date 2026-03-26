import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_write_repository.dart';

/// Use case untuk menghapus transaksi
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles deleting transactions by ID
/// - Dependency Inversion: Depends on TransactionWriteRepository abstraction
class DeleteTransactionUseCase extends UseCase<void, int> {
  final TransactionWriteRepository _repository;

  DeleteTransactionUseCase(this._repository);

  @override
  Future<Result<void>> call(int transactionId) async {
    // Validasi ID
    if (transactionId <= 0) {
      return Result.failure(
        ValidationFailure('ID transaksi tidak valid'),
      );
    }

    // Hapus dari repository
    try {
      final result = await _repository.deleteTransaction(transactionId);
      return result;
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal menghapus transaksi: $e'),
      );
    }
  }

  /// Convenience method for backward compatibility
  /// Delegates to the call method
  Future<Result<void>> execute(int transactionId) => call(transactionId);
}
