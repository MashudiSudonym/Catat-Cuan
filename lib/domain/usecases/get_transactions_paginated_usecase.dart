import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/paginated_result_entity.dart';
import 'package:catat_cuan/domain/entities/pagination_params_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_query_repository.dart';

/// Parameter untuk mengambil transaksi dengan pagination
class GetTransactionsPaginatedParams {
  final PaginationParamsEntity pagination;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? categoryId;
  final TransactionType? type;

  const GetTransactionsPaginatedParams({
    required this.pagination,
    this.startDate,
    this.endDate,
    this.categoryId,
    this.type,
  });
}

/// Use case untuk mengambil transaksi dengan pagination
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles paginated transaction queries
/// - Dependency Inversion: Depends on TransactionQueryRepository abstraction
class GetTransactionsPaginatedUseCase
    extends UseCase<PaginatedResultEntity<TransactionEntity>,
        GetTransactionsPaginatedParams> {
  final TransactionQueryRepository _repository;

  GetTransactionsPaginatedUseCase(this._repository);

  @override
  Future<Result<PaginatedResultEntity<TransactionEntity>>> call(
    GetTransactionsPaginatedParams params,
  ) async {
    try {
      final result = await _repository.getTransactionsPaginated(
        params.pagination,
        startDate: params.startDate,
        endDate: params.endDate,
        categoryId: params.categoryId,
        type: params.type,
      );
      return result;
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengambil transaksi: $e'),
      );
    }
  }
}
