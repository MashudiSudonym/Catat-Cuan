import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_write_repository.dart';

/// Use case untuk menghapus beberapa transaksi sekaligus (batch delete)
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles deleting multiple transactions
/// - Dependency Inversion: Depends on TransactionWriteRepository abstraction
class DeleteMultipleTransactionsUseCase extends UseCase<void, List<int>> {
  final TransactionWriteRepository _repository;

  DeleteMultipleTransactionsUseCase(this._repository);

  @override
  Future<Result<void>> call(List<int> transactionIds) async {
    // Validasi daftar ID
    if (transactionIds.isEmpty) {
      return Result.failure(
        ValidationFailure('Daftar transaksi tidak boleh kosong'),
      );
    }

    // Validasi setiap ID
    for (final id in transactionIds) {
      if (id <= 0) {
        return Result.failure(
          ValidationFailure('ID transaksi tidak valid: $id'),
        );
      }
    }

    // Hapus dari repository
    try {
      final result = await _repository.deleteMultipleTransactions(transactionIds);
      return result;
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal menghapus transaksi: $e'),
      );
    }
  }

  /// Convenience method for backward compatibility
  /// Delegates to the call method
  Future<Result<void>> execute(List<int> transactionIds) => call(transactionIds);
}
