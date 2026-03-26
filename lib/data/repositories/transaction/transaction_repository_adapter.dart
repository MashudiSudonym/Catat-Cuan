import 'package:catat_cuan/data/repositories/transaction_repository_impl.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/entities/paginated_result_entity.dart';
import 'package:catat_cuan/domain/entities/pagination_params_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/repositories/transaction_repository.dart' show LegacyResult;
import 'package:catat_cuan/domain/repositories/transaction/transaction_repositories.dart';

/// Unified adapter that bridges legacy TransactionRepositoryImpl with all new segregated interfaces
///
/// This adapter converts between LegacyResult (used by the legacy implementation)
/// and Result (from domain/core/result.dart) used by the new segregated interfaces.
///
/// This is a temporary solution during the migration phase.
/// Eventually, dedicated implementations will replace this adapter:
/// - BasicTransactionRepositoryImpl (CRUD)
/// - TransactionQueryRepositoryImpl (filtering/pagination)
/// - TransactionAnalyticsRepositoryImpl (summaries/breakdowns)
/// - TransactionSearchRepositoryImpl (search)
/// - TransactionExportRepositoryImpl (export)
class TransactionRepositoryAdapter implements
    TransactionReadRepository,
    TransactionWriteRepository,
    TransactionQueryRepository,
    TransactionSearchRepository,
    TransactionAnalyticsRepository,
    TransactionExportRepository {
  final TransactionRepositoryImpl _legacyRepository;

  TransactionRepositoryAdapter(this._legacyRepository);

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

  // TransactionQueryRepository implementation
  @override
  Future<Result<List<TransactionEntity>>> getTransactionsByFilter({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  }) async {
    final legacyResult = await _legacyRepository.getTransactionsByFilter(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      type: type,
    );
    return _convertResult(legacyResult);
  }

  @override
  Future<Result<PaginatedResultEntity<TransactionEntity>>> getTransactionsPaginated(
    PaginationParamsEntity pagination, {
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  }) async {
    try {
      final paginatedResult = await _legacyRepository.getTransactionsPaginated(
        pagination,
        startDate: startDate,
        endDate: endDate,
        categoryId: categoryId,
        type: type,
      );
      return Result.success(paginatedResult);
    } catch (e) {
      return Result.failure(DatabaseFailure('Gagal mengambil transaksi: $e'));
    }
  }

  // TransactionSearchRepository implementation
  @override
  Future<Result<List<TransactionEntity>>> searchTransactions(
    String query, {
    TransactionType? type,
    int? limit,
  }) async {
    final legacyResult = await _legacyRepository.searchTransactions(
      query,
      type: type,
      limit: limit,
    );
    return _convertResult(legacyResult);
  }

  // TransactionAnalyticsRepository implementation
  @override
  Future<Result<MonthlySummaryEntity>> getMonthlySummary(String yearMonth) async {
    final legacyResult = await _legacyRepository.getMonthlySummary(yearMonth);
    return _convertResult(legacyResult);
  }

  @override
  Future<Result<MonthlySummaryEntity>> getAllTimeSummary() async {
    final legacyResult = await _legacyRepository.getAllTimeSummary();
    return _convertResult(legacyResult);
  }

  @override
  Future<Result<List<CategoryBreakdownEntity>>> getCategoryBreakdown(
    String yearMonth,
    TransactionType type,
  ) async {
    final legacyResult = await _legacyRepository.getCategoryBreakdown(yearMonth, type);
    return _convertResult(legacyResult);
  }

  @override
  Future<Result<List<CategoryBreakdownEntity>>> getAllCategoryBreakdown(
    TransactionType type,
  ) async {
    final legacyResult = await _legacyRepository.getAllCategoryBreakdown(type);
    return _convertResult(legacyResult);
  }

  @override
  Future<Result<List<MonthlySummaryEntity>>> getMultiMonthSummary(
    String startYearMonth,
    String endYearMonth,
  ) async {
    final legacyResult = await _legacyRepository.getMultiMonthSummary(
      startYearMonth,
      endYearMonth,
    );
    return _convertResult(legacyResult);
  }

  // TransactionExportRepository implementation
  @override
  Future<Result<List<Map<String, dynamic>>>> getTransactionsWithCategoryNames({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  }) async {
    final legacyResult = await _legacyRepository.getTransactionsWithCategoryNames(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      type: type,
    );
    return _convertResult(legacyResult);
  }
}
