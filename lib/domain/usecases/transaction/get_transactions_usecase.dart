import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_read_repository.dart';

/// Use case untuk mengambil semua transaksi
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles getting all transactions
/// - Dependency Inversion: Depends on TransactionReadRepository abstraction
class GetTransactionsUseCase
    extends UseCase<List<TransactionEntity>, NoParams> {
  final TransactionReadRepository _repository;

  GetTransactionsUseCase(this._repository);

  @override
  Future<Result<List<TransactionEntity>>> call(NoParams params) async {
    try {
      final result = await _repository.getTransactions();
      return result;
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengambil transaksi: $e'),
      );
    }
  }

  /// Convenience method for backward compatibility
  Future<Result<List<TransactionEntity>>> execute() => call(const NoParams());
}
