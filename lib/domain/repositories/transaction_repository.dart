import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/entities/paginated_result_entity.dart';
import 'package:catat_cuan/domain/entities/pagination_params_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// Legacy Result type untuk return value yang bisa sukses atau gagal
///
/// @deprecated Use domain/core/result.dart instead with proper Failure types
@Deprecated('Use Result from domain/core/result.dart instead')
class LegacyResult<T> {
  final T? data;
  final String? error;

  const LegacyResult._({this.data, this.error});

  factory LegacyResult.success(T data) => LegacyResult._(data: data);
  factory LegacyResult.failure(String error) => LegacyResult._(error: error);

  bool get isSuccess => data != null;
  bool get isFailure => error != null;
}

/// Legacy monolithic TransactionRepository interface
///
/// This interface combines all transaction operations in one place.
/// It violates the Interface Segregation Principle (ISP) because clients
/// are forced to depend on methods they don't use.
///
/// MIGRATION GUIDE:
/// Instead of using this monolithic interface, depend on the specific
/// segregated interfaces you actually need:
///
/// - For reading transactions: `TransactionReadRepository`
/// - For writing transactions: `TransactionWriteRepository`
/// - For filtering/pagination: `TransactionQueryRepository`
/// - For search: `TransactionSearchRepository`
/// - For analytics: `TransactionAnalyticsRepository`
/// - For export: `TransactionExportRepository`
///
/// Example migration:
/// ```dart
/// // OLD - depends on everything
/// class MyService {
///   final TransactionRepository _repo;
/// }
///
/// // NEW - depends only on what's needed
/// class MyService {
///   final TransactionReadRepository _readRepo;
///   final TransactionWriteRepository _writeRepo;
/// }
/// ```
@Deprecated('Use segregated interfaces from transaction/transaction_repositories.dart instead')
abstract class TransactionRepository {
  /// Menambahkan transaksi baru
  /// Mengembalikan LegacyResult dengan TransactionEntity yang sudah disertai ID jika sukses
  @Deprecated('Use TransactionWriteRepository.addTransaction instead')
  Future<LegacyResult<TransactionEntity>> addTransaction(TransactionEntity transaction);

  /// Mengambil semua transaksi
  /// Mengembalikan list kosong jika tidak ada data
  @Deprecated('Use TransactionReadRepository.getTransactions instead')
  Future<LegacyResult<List<TransactionEntity>>> getTransactions();

  /// Mengambil transaksi berdasarkan ID
  /// Mengembalikan LegacyResult dengan error jika tidak ditemukan
  @Deprecated('Use TransactionReadRepository.getTransactionById instead')
  Future<LegacyResult<TransactionEntity>> getTransactionById(int id);

  /// Mengupdate transaksi yang sudah ada
  /// Mengembalikan LegacyResult dengan error jika tidak ditemukan
  @Deprecated('Use TransactionWriteRepository.updateTransaction instead')
  Future<LegacyResult<TransactionEntity>> updateTransaction(TransactionEntity transaction);

  /// Menghapus transaksi berdasarkan ID
  /// Mengembalikan LegacyResult dengan error jika tidak ditemukan
  @Deprecated('Use TransactionWriteRepository.deleteTransaction instead')
  Future<LegacyResult<void>> deleteTransaction(int id);

  /// Menghapus SEMUA transaksi
  /// Mengembalikan LegacyResult dengan error jika gagal
  @Deprecated('Use TransactionWriteRepository.deleteAllTransactions instead')
  Future<LegacyResult<void>> deleteAllTransactions();

  /// Menghapus beberapa transaksi sekaligus (batch delete)
  @Deprecated('Use TransactionWriteRepository.deleteMultipleTransactions instead')
  Future<LegacyResult<void>> deleteMultipleTransactions(List<int> ids);

  /// Mengambil transaksi dengan filter
  @Deprecated('Use TransactionQueryRepository.getTransactionsByFilter instead')
  Future<LegacyResult<List<TransactionEntity>>> getTransactionsByFilter({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  });

  /// Mencari transaksi berdasarkan query text
  @Deprecated('Use TransactionSearchRepository.searchTransactions instead')
  Future<LegacyResult<List<TransactionEntity>>> searchTransactions(
    String query, {
    TransactionType? type,
    int? limit,
  });

  /// Mengambil ringkasan bulanan transaksi
  @Deprecated('Use TransactionAnalyticsRepository.getMonthlySummary instead')
  Future<LegacyResult<MonthlySummaryEntity>> getMonthlySummary(String yearMonth);

  /// Mengambil ringkasan seluruh transaksi (all-time)
  @Deprecated('Use TransactionAnalyticsRepository.getAllTimeSummary instead')
  Future<LegacyResult<MonthlySummaryEntity>> getAllTimeSummary();

  /// Mengambil breakdown kategori untuk bulan tertentu
  @Deprecated('Use TransactionAnalyticsRepository.getCategoryBreakdown instead')
  Future<LegacyResult<List<CategoryBreakdownEntity>>> getCategoryBreakdown(
    String yearMonth,
    TransactionType type,
  );

  /// Mengambil breakdown kategori untuk seluruh transaksi (all-time)
  @Deprecated('Use TransactionAnalyticsRepository.getAllCategoryBreakdown instead')
  Future<LegacyResult<List<CategoryBreakdownEntity>>> getAllCategoryBreakdown(
    TransactionType type,
  );

  /// Mengambil ringkasan transaksi untuk beberapa bulan (trend analysis)
  @Deprecated('Use TransactionAnalyticsRepository.getMultiMonthSummary instead')
  Future<LegacyResult<List<MonthlySummaryEntity>>> getMultiMonthSummary(
    String startYearMonth,
    String endYearMonth,
  );

  /// Mengambil transaksi dengan nama kategori untuk export
  @Deprecated('Use TransactionExportRepository.getTransactionsWithCategoryNames instead')
  Future<LegacyResult<List<Map<String, dynamic>>>> getTransactionsWithCategoryNames({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  });

  /// Mengambil transaksi dengan pagination
  ///
  /// Note: This returns PaginatedResultEntity directly for backward compatibility.
  /// Use TransactionQueryRepository.getTransactionsPaginated for the new API
  /// that returns `Result<PaginatedResultEntity>`.
  @Deprecated('Use TransactionQueryRepository.getTransactionsPaginated instead')
  Future<PaginatedResultEntity<TransactionEntity>> getTransactionsPaginated(
    PaginationParamsEntity pagination, {
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  });
}
