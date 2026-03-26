import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_export_repository.dart';
import 'package:catat_cuan/domain/services/export_service.dart';
import 'package:catat_cuan/domain/services/file_naming_service.dart';

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

/// Use case untuk export transaksi ke CSV
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles transaction export
/// - Dependency Inversion: Depends on TransactionExportRepository abstraction
class ExportTransactionsUseCase
    extends UseCase<String, ExportTransactionsParams> {
  final TransactionExportRepository _repository;
  final ExportService _exportService;

  ExportTransactionsUseCase(this._repository, this._exportService);

  @override
  Future<Result<String>> call(ExportTransactionsParams params) async {
    // Get transactions with category names for export
    final result = await _repository.getTransactionsWithCategoryNames(
      startDate: params.startDate,
      endDate: params.endDate,
      categoryId: params.categoryId,
      type: params.type,
    );

    if (result.isFailure) {
      return Result.failure(
        UnknownFailure(result.failure?.message ?? 'Unknown error'),
      );
    }

    final transactions = result.data ?? [];

    if (transactions.isEmpty) {
      return Result.failure(
        const ExportFailure('Tidak ada transaksi untuk diekspor'),
      );
    }

    // Generate filename with date suffix if not provided
    final fileName = params.fileNameSuffix ?? _generateFileNameSuffix();

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
