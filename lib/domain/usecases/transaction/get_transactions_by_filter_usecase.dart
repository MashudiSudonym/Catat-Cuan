import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_query_repository.dart';
import 'transaction_filter_params.dart';

/// Use case untuk mengambil transaksi dengan filter sesuai AC-LOG-005.3
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles filtered transaction queries
/// - Dependency Inversion: Depends on TransactionQueryRepository abstraction
class GetTransactionsByFilterUseCase extends UseCase<List<TransactionEntity>,
    TransactionFilterParams> {
  final TransactionQueryRepository _repository;

  GetTransactionsByFilterUseCase(this._repository);

  @override
  Future<Result<List<TransactionEntity>>> call(
    TransactionFilterParams params,
  ) async {
    try {
      final result = await _repository.getTransactionsByFilter(
        startDate: params.startDate,
        endDate: params.endDate,
        categoryId: params.categoryId,
        type: params.type,
      );
      return result;
    } catch (e) {
      return ResultFailures.database<List<TransactionEntity>>(
        'Gagal mengambil transaksi: $e',
      );
    }
  }
}
