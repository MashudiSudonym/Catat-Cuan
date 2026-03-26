import 'package:catat_cuan/domain/core/result.dart' as core;
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction_repository.dart';
import 'package:catat_cuan/domain/services/export_service.dart';
import 'package:catat_cuan/domain/services/file_naming_service.dart';

/// Use case untuk export transaksi ke CSV
class ExportTransactionsUseCase {
  final TransactionRepository _repository;
  final ExportService _exportService;

  ExportTransactionsUseCase(this._repository, this._exportService);

  /// Export transaksi ke CSV
  /// - [startDate]: Filter tanggal awal (opsional)
  /// - [endDate]: Filter tanggal akhir (opsional)
  /// - [categoryId]: Filter kategori (opsional)
  /// - [type]: Filter tipe transaksi (opsional)
  /// - [fileNameSuffix]: Suffix nama file (opsional, default: timestamp)
  ///
  /// Mengembalikan Result dengan path file jika sukses
  Future<core.Result<String>> execute({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? type,
    String? fileNameSuffix,
  }) async {
    // Get transactions with category names for export
    final result = await _repository.getTransactionsWithCategoryNames(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      type: type,
    );

    if (result.isFailure) {
      return core.Result.failure(UnknownFailure(result.error ?? 'Unknown error'));
    }

    final transactions = result.data!;

    if (transactions.isEmpty) {
      return core.Result.failure(const ExportFailure('Tidak ada transaksi untuk diekspor'));
    }

    // Generate filename with date suffix if not provided
    final fileName = fileNameSuffix ?? _generateFileNameSuffix();

    // Export to CSV
    return await _exportService.exportTransactionsToCsv(
      transactions: transactions,
      fileName: fileName,
    );
  }

  /// Generate filename suffix dari tanggal hari ini
  /// Format: YYYYMMDD (contoh: 20240315)
  String _generateFileNameSuffix() {
    return FileNamingService.generateDateSuffix();
  }
}

/// Parameter untuk export transaksi
class ExportTransactionsParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? categoryId;
  final TransactionType? type;
  final String? fileNameSuffix;

  const ExportTransactionsParams({
    this.startDate,
    this.endDate,
    this.categoryId,
    this.type,
    this.fileNameSuffix,
  });
}
