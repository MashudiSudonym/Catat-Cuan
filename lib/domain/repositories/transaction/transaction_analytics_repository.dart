import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// Repository interface untuk analitik dan summary transaksi
///
/// Following Interface Segregation Principle (ISP) - hanya berisi operasi analitik
///
/// Responsibility: Menghitung dan mengambil summary, breakdown, dan aggregations
abstract class TransactionAnalyticsRepository {
  /// Mengambil ringkasan bulanan transaksi
  ///
  /// Parameters:
  /// - [yearMonth]: Format "YYYY-MM" (contoh: "2024-03")
  ///
  /// Mengembalikan Result dengan MonthlySummaryEntity jika sukses
  Future<Result<MonthlySummaryEntity>> getMonthlySummary(String yearMonth);

  /// Mengambil ringkasan seluruh transaksi (all-time)
  ///
  /// Mengembalikan Result dengan MonthlySummaryEntity jika sukses
  Future<Result<MonthlySummaryEntity>> getAllTimeSummary();

  /// Mengambil breakdown kategori untuk bulan tertentu
  ///
  /// Parameters:
  /// - [yearMonth]: Format "YYYY-MM" (contoh: "2024-03")
  /// - [type]: Filter tipe transaksi (income/expense)
  ///
  /// Mengembalikan list CategoryBreakdownEntity yang sudah di-sort by total amount DESC
  Future<Result<List<CategoryBreakdownEntity>>> getCategoryBreakdown(
    String yearMonth,
    TransactionType type,
  );

  /// Mengambil breakdown kategori untuk seluruh transaksi (all-time)
  ///
  /// Parameters:
  /// - [type]: Filter tipe transaksi (income/expense)
  ///
  /// Mengembalikan list CategoryBreakdownEntity yang sudah di-sort by total amount DESC
  Future<Result<List<CategoryBreakdownEntity>>> getAllCategoryBreakdown(
    TransactionType type,
  );

  /// Mengambil ringkasan transaksi untuk beberapa bulan (trend analysis)
  ///
  /// Parameters:
  /// - [startYearMonth]: Format "YYYY-MM" (contoh: "2024-03") - awal periode (inclusive)
  /// - [endYearMonth]: Format "YYYY-MM" (contoh: "2024-08") - akhir periode (inclusive)
  ///
  /// Mengembalikan list MonthlySummaryEntity yang diurut by year_month ASC
  Future<Result<List<MonthlySummaryEntity>>> getMultiMonthSummary(
    String startYearMonth,
    String endYearMonth,
  );
}
