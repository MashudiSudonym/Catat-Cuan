import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/paginated_result_entity.dart';
import 'package:catat_cuan/domain/entities/pagination_params_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// Repository interface untuk query dan filter transaksi
///
/// Following Interface Segregation Principle (ISP) - hanya berisi operasi query
///
/// Responsibility: Query transactions dengan filter dan pagination
abstract class TransactionQueryRepository {
  /// Mengambil transaksi dengan filter
  ///
  /// Parameters:
  /// - [startDate]: Filter tanggal awal (inclusive), null = tidak ada filter
  /// - [endDate]: Filter tanggal akhir (inclusive), null = tidak ada filter
  /// - [categoryId]: Filter berdasarkan kategori, null = semua kategori
  /// - [type]: Filter tipe transaksi, null = semua tipe
  ///
  /// Default sorting by date descending (terbaru di atas)
  Future<Result<List<TransactionEntity>>> getTransactionsByFilter({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  });

  /// Mengambil transaksi dengan pagination
  ///
  /// Parameters:
  /// - [pagination]: Parameter pagination (page, limit)
  /// - [startDate]: Filter tanggal awal (opsional)
  /// - [endDate]: Filter tanggal akhir (opsional)
  /// - [categoryId]: Filter kategori (opsional)
  /// - [type]: Filter tipe transaksi (opsional)
  ///
  /// Mengembalikan PaginatedResult dengan data transaksi dan metadata pagination
  Future<Result<PaginatedResultEntity<TransactionEntity>>> getTransactionsPaginated(
    PaginationParamsEntity pagination, {
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  });
}
