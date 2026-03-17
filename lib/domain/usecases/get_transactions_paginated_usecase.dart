import 'package:catat_cuan/domain/entities/paginated_result_entity.dart';
import 'package:catat_cuan/domain/entities/pagination_params_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/repositories/transaction_repository.dart';

/// Use case untuk mengambil transaksi dengan pagination
class GetTransactionsPaginatedUseCase {
  final TransactionRepository _repository;

  GetTransactionsPaginatedUseCase(this._repository);

  /// Mengambil transaksi dengan pagination
  /// - [pagination]: Parameter pagination (page, limit)
  /// - [startDate]: Filter tanggal awal (opsional)
  /// - [endDate]: Filter tanggal akhir (opsional)
  /// - [categoryId]: Filter kategori (opsional)
  /// - [type]: Filter tipe transaksi (opsional)
  Future<PaginatedResultEntity<TransactionEntity>> execute(
    PaginationParamsEntity pagination, {
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
  }) async {
    return await _repository.getTransactionsPaginated(
      pagination,
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      type: type,
    );
  }
}
