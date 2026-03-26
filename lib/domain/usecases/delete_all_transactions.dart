import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_write_repository.dart';

/// Use case untuk menghapus SEMUA transaksi
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles deleting all transactions
/// - Dependency Inversion: Depends on TransactionWriteRepository abstraction
class DeleteAllTransactionsUseCase extends UseCase<void, NoParams> {
  final TransactionWriteRepository _repository;

  DeleteAllTransactionsUseCase(this._repository);

  @override
  Future<Result<void>> call(NoParams params) async {
    try {
      final result = await _repository.deleteAllTransactions();
      return result;
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal menghapus semua transaksi: $e'),
      );
    }
  }

  /// Convenience method for backward compatibility
  Future<Result<void>> execute() => call(const NoParams());
}
