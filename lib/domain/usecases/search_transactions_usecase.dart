import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_search_repository.dart';

/// Parameter untuk pencarian transaksi
class SearchTransactionsParams {
  final String query;
  final TransactionType? type;
  final int limit;

  const SearchTransactionsParams({
    required this.query,
    this.type,
    this.limit = 50,
  });
}

/// Use case untuk mencari transaksi
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles searching transactions
/// - Dependency Inversion: Depends on TransactionSearchRepository abstraction
class SearchTransactionsUseCase extends UseCase<List<TransactionEntity>,
    SearchTransactionsParams> {
  final TransactionSearchRepository _repository;

  SearchTransactionsUseCase(this._repository);

  @override
  Future<Result<List<TransactionEntity>>> call(
    SearchTransactionsParams params,
  ) async {
    // Return empty result jika query kosong
    if (params.query.trim().isEmpty) {
      return Result.success([]);
    }

    try {
      final result = await _repository.searchTransactions(
        params.query,
        type: params.type,
        limit: params.limit,
      );
      return result;
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mencari transaksi: $e'),
      );
    }
  }
}
