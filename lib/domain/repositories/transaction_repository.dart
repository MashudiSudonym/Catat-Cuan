import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/entities/paginated_result_entity.dart';
import 'package:catat_cuan/domain/entities/pagination_params_entity.dart';

/// Result type untuk return value yang bisa sukses atau gagal
///
/// TODO: Migrate to use domain/core/result.dart after updating all implementations
class Result<T> {
  final T? data;
  final String? error;

  const Result._({this.data, this.error});

  factory Result.success(T data) => Result._(data: data);
  factory Result.failure(String error) => Result._(error: error);

  bool get isSuccess => data != null;
  bool get isFailure => error != null;
}

/// Repository interface untuk operasi transaksi
///
/// This is the main transaction repository interface that combines
/// read, write, and summary operations.
///
/// For finer-grained interfaces following the Interface Segregation Principle (ISP),
/// see the segregated interfaces in the transaction/ subdirectory:
/// - [TransactionReadRepository]: For querying transactions
/// - [TransactionWriteRepository]: For creating/updating/deleting transactions
/// - [TransactionSummaryRepository]: For aggregated summaries and breakdowns
abstract class TransactionRepository {
  /// Menambahkan transaksi baru
  /// Mengembalikan Result dengan TransactionEntity yang sudah disertai ID jika sukses
  Future<Result<TransactionEntity>> addTransaction(TransactionEntity transaction);

  /// Mengambil semua transaksi
  /// Mengembalikan list kosong jika tidak ada data
  Future<Result<List<TransactionEntity>>> getTransactions();

  /// Mengambil transaksi berdasarkan ID
  /// Mengembalikan Result dengan error jika tidak ditemukan
  Future<Result<TransactionEntity>> getTransactionById(int id);

  /// Mengupdate transaksi yang sudah ada
  /// Mengembalikan Result dengan error jika tidak ditemukan
  Future<Result<TransactionEntity>> updateTransaction(TransactionEntity transaction);

  /// Menghapus transaksi berdasarkan ID
  /// Mengembalikan Result dengan error jika tidak ditemukan
  Future<Result<void>> deleteTransaction(int id);

  /// Menghapus SEMUA transaksi
  /// Mengembalikan Result dengan error jika gagal
  Future<Result<void>> deleteAllTransactions();

  /// Mengambil transaksi dengan filter
  /// - [startDate]: Filter tanggal awal (inclusive), null = tidak ada filter
  /// - [endDate]: Filter tanggal akhir (inclusive), null = tidak ada filter
  /// - [categoryId]: Filter berdasarkan kategori, null = semua kategori
  /// - [type]: Filter tipe transaksi, null = semua tipe
  /// Default sorting by date descending (terbaru di atas)
  Future<Result<List<TransactionEntity>>> getTransactionsByFilter({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  });

  /// Mengambil ringkasan bulanan transaksi
  /// - [yearMonth]: Format "YYYY-MM" (contoh: "2024-03")
  /// Mengembalikan Result dengan MonthlySummaryEntity jika sukses
  Future<Result<MonthlySummaryEntity>> getMonthlySummary(String yearMonth);

  /// Mengambil breakdown kategori untuk bulan tertentu
  /// - [yearMonth]: Format "YYYY-MM" (contoh: "2024-03")
  /// - [type]: Filter tipe transaksi (income/expense)
  /// Mengembalikan list CategoryBreakdownEntity yang sudah di-sort by total amount DESC
  Future<Result<List<CategoryBreakdownEntity>>> getCategoryBreakdown(
    String yearMonth,
    TransactionType type,
  );

  /// Mengambil ringkasan transaksi untuk beberapa bulan (trend analysis)
  /// - [startYearMonth]: Format "YYYY-MM" (contoh: "2024-03") - awal periode (inclusive)
  /// - [endYearMonth]: Format "YYYY-MM" (contoh: "2024-08") - akhir periode (inclusive)
  /// Mengembalikan list MonthlySummaryEntity yang diurut by year_month ASC
  Future<Result<List<MonthlySummaryEntity>>> getMultiMonthSummary(
    String startYearMonth,
    String endYearMonth,
  );

  /// Mencari transaksi berdasarkan query text
  /// Pencarian dilakukan pada note dan nama kategori
  /// - [query]: Kata kunci pencarian
  /// - [type]: Filter tipe transaksi (opsional)
  /// - [limit]: Batas jumlah hasil (opsional, default 50)
  /// Mengembalikan list transaksi yang cocok, diurut by date DESC
  Future<Result<List<TransactionEntity>>> searchTransactions(
    String query, {
    TransactionType? type,
    int? limit,
  });

  /// Mengambil transaksi dengan nama kategori untuk export
  /// Returns list of maps containing transaction data plus category name
  /// - [startDate]: Filter tanggal awal (opsional)
  /// - [endDate]: Filter tanggal akhir (opsional)
  /// - [categoryId]: Filter kategori (opsional)
  /// - [type]: Filter tipe transaksi (opsional)
  Future<Result<List<Map<String, dynamic>>>> getTransactionsWithCategoryNames({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  });

  /// Mengambil transaksi dengan pagination
  /// - [pagination]: Parameter pagination (page, limit)
  /// - [startDate]: Filter tanggal awal (opsional)
  /// - [endDate]: Filter tanggal akhir (opsional)
  /// - [categoryId]: Filter kategori (opsional)
  /// - [type]: Filter tipe transaksi (opsional)
  /// Mengembalikan PaginatedResult dengan data transaksi dan metadata pagination
  Future<PaginatedResultEntity<TransactionEntity>> getTransactionsPaginated(
    PaginationParamsEntity pagination, {
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  });
}


