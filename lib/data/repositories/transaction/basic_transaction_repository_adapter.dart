import 'package:catat_cuan/data/repositories/transaction_repository_impl.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/repositories/transaction_repository.dart' show LegacyResult;
import 'package:catat_cuan/domain/repositories/transaction/transaction_read_repository.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_write_repository.dart';

/// Adapter that bridges legacy TransactionRepositoryImpl with new segregated interfaces
///
/// This adapter converts between LegacyResult (used by the legacy implementation)
/// and Result (from domain/core/result.dart) used by the new segregated interfaces.
///
/// This is a temporary solution during the migration phase.
/// Eventually, dedicated implementations will replace this adapter.
class BasicTransactionRepositoryAdapter implements TransactionReadRepository, TransactionWriteRepository {
  final TransactionRepositoryImpl _legacyRepository;

  BasicTransactionRepositoryAdapter(this._legacyRepository);

  // Helper to convert LegacyResult to Result
  Result<T> _convertResult<T>(LegacyResult<T> legacyResult) {
    if (legacyResult.isSuccess) {
      return Result.success(legacyResult.data as T);
    }
    return Result.failure(DatabaseFailure(legacyResult.error ?? 'Unknown error'));
  }

  // TransactionReadRepository implementation
  @override
  Future<Result<TransactionEntity>> getTransactionById(int id) async {
    final legacyResult = await _legacyRepository.getTransactionById(id);
    return _convertResult(legacyResult);
  }

  @override
  Future<Result<List<TransactionEntity>>> getTransactions() async {
    final legacyResult = await _legacyRepository.getTransactions();
    return _convertResult(legacyResult);
  }

  // TransactionWriteRepository implementation
  @override
  Future<Result<TransactionEntity>> addTransaction(TransactionEntity transaction) async {
    final legacyResult = await _legacyRepository.addTransaction(transaction);
    return _convertResult(legacyResult);
  }

  @override
  Future<Result<TransactionEntity>> updateTransaction(TransactionEntity transaction) async {
    final legacyResult = await _legacyRepository.updateTransaction(transaction);
    return _convertResult(legacyResult);
  }

  @override
  Future<Result<void>> deleteTransaction(int id) async {
    final legacyResult = await _legacyRepository.deleteTransaction(id);
    return _convertResult(legacyResult);
  }

  @override
  Future<Result<void>> deleteAllTransactions() async {
    final legacyResult = await _legacyRepository.deleteAllTransactions();
    return _convertResult(legacyResult);
  }

  @override
  Future<Result<void>> deleteMultipleTransactions(List<int> ids) async {
    final legacyResult = await _legacyRepository.deleteMultipleTransactions(ids);
    return _convertResult(legacyResult);
  }
}
