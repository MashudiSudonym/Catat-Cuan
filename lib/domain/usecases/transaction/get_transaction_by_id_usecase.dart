import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_read_repository.dart';

/// Use case untuk mengambil transaksi berdasarkan ID
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles getting transaction by ID
/// - Dependency Inversion: Depends on TransactionReadRepository abstraction
class GetTransactionByIdUseCase
    extends UseCase<TransactionEntity, int> {
  final TransactionReadRepository _repository;

  GetTransactionByIdUseCase(this._repository);

  @override
  Future<Result<TransactionEntity>> call(int id) async {
    try {
      final result = await _repository.getTransactionById(id);
      return result;
    } catch (e) {
      return ResultFailures.database<TransactionEntity>(
        'Gagal mengambil transaksi: $e',
      );
    }
  }
}
