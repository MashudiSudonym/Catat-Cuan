import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_query_repository.dart';
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

/// Parameter object untuk filter transaksi
class TransactionFilterParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? categoryId;
  final TransactionType? type;

  const TransactionFilterParams({
    this.startDate,
    this.endDate,
    this.categoryId,
    this.type,
  });
}

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
