import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/entities/import_result_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_query_repository.dart';
import 'package:catat_cuan/domain/repositories/transaction/transaction_write_repository.dart';
import 'package:catat_cuan/domain/services/import_service.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Parameter untuk import transaksi
class ImportTransactionsParams {
  final String filePath;

  const ImportTransactionsParams({required this.filePath});
}

/// Use case untuk import transaksi dari CSV
///
/// Flow: parse CSV -> load categories -> load existing transactions (dedup set)
///       -> build name-to-id map -> validate each row -> skip if duplicate
///       -> insert valid rows -> return ImportResult
class ImportTransactionsUseCase extends UseCase<ImportResult, ImportTransactionsParams> {
  final ImportService _importService;
  final CategoryReadRepository _categoryReadRepository;
  final TransactionWriteRepository _transactionWriteRepository;
  final TransactionQueryRepository _transactionQueryRepository;

  ImportTransactionsUseCase(
    this._importService,
    this._categoryReadRepository,
    this._transactionWriteRepository,
    this._transactionQueryRepository,
  );

  @override
  Future<Result<ImportResult>> call(ImportTransactionsParams params) async {
    AppLogger.d('Starting CSV import: ${params.filePath}');

    // Step 1: Parse CSV file
    final parseResult = await _importService.parseCsvFile(params.filePath);
    if (parseResult.isFailure) {
      return Result.failure(parseResult.failure!);
    }

    final parsedRows = parseResult.data!;

    // Step 2: Load categories and build name-to-id map
    final categoriesResult = await _categoryReadRepository.getCategories();
    if (categoriesResult.isFailure) {
      return Result.failure(
        UnknownFailure(categoriesResult.failure?.message ?? 'Gagal memuat kategori'),
      );
    }

    final categories = categoriesResult.data ?? [];
    final categoryMap = _buildCategoryMap(categories);
    AppLogger.d('Category map built: ${categoryMap.length} entries');

    // Step 3: Load existing transactions for dedup
    final existingResult = await _transactionQueryRepository.getTransactionsByFilter();
    if (existingResult.isFailure) {
      return Result.failure(
        UnknownFailure(existingResult.failure?.message ?? 'Gagal memuat transaksi'),
      );
    }

    final existingTransactions = existingResult.data ?? [];
    final dedupSet = _buildDedupSet(existingTransactions);
    AppLogger.d('Dedup set built: ${dedupSet.length} existing transactions');

    // Step 4: Process each row
    int imported = 0;
    int skipped = 0;
    final errors = <ImportRowError>[];

    for (final row in parsedRows) {
      final rowDisplay = '${row.date},${row.type},${row.category},${row.amount}';

      // Parse and validate type
      final type = _parseType(row.type);
      if (type == null) {
        errors.add(ImportRowError(
          rowNumber: row.rowNumber,
          rowData: rowDisplay,
          errorMessage: 'Jenis transaksi tidak valid: "${row.type}"',
        ));
        continue;
      }

      // Parse date
      final dateTime = _parseDate(row.date);
      if (dateTime == null) {
        errors.add(ImportRowError(
          rowNumber: row.rowNumber,
          rowData: rowDisplay,
          errorMessage: 'Format tanggal tidak valid: "${row.date}" (gunakan dd/MM/yyyy)',
        ));
        continue;
      }

      // Parse amount
      final amount = _parseAmount(row.amount);
      if (amount == null) {
        errors.add(ImportRowError(
          rowNumber: row.rowNumber,
          rowData: rowDisplay,
          errorMessage: 'Format jumlah tidak valid: "${row.amount}"',
        ));
        continue;
      }

      // Resolve category
      final categoryKey = '${row.category.toLowerCase()}_${type == TransactionType.income ? 'income' : 'expense'}';
      final categoryId = categoryMap[categoryKey];
      if (categoryId == null) {
        errors.add(ImportRowError(
          rowNumber: row.rowNumber,
          rowData: rowDisplay,
          errorMessage: 'Kategori tidak ditemukan: "${row.category}" (${type.displayName})',
        ));
        continue;
      }

      // Check duplicate
      final dedupKey = '${amount}_${dateTime.millisecondsSinceEpoch}_${type.value}_$categoryId';
      if (dedupSet.contains(dedupKey)) {
        skipped++;
        errors.add(ImportRowError(
          rowNumber: row.rowNumber,
          rowData: rowDisplay,
          errorMessage: 'Duplikat',
        ));
        continue;
      }

      // Insert transaction
      final now = DateTime.now();
      final transaction = TransactionEntity(
        amount: amount,
        type: type,
        dateTime: dateTime,
        categoryId: categoryId,
        note: row.note.isEmpty ? null : row.note,
        createdAt: now,
        updatedAt: now,
      );

      final addResult = await _transactionWriteRepository.addTransaction(transaction);
      if (addResult.isSuccess) {
        imported++;
        // Add to dedup set to prevent duplicates within the CSV itself
        dedupSet.add(dedupKey);
      } else {
        errors.add(ImportRowError(
          rowNumber: row.rowNumber,
          rowData: rowDisplay,
          errorMessage: 'Gagal menyimpan: ${addResult.failure?.message ?? "Unknown error"}',
        ));
      }
    }

    final result = ImportResult(
      totalRows: parsedRows.length,
      imported: imported,
      skipped: skipped,
      errors: errors,
    );

    AppLogger.i('Import complete: ${result.imported}/${result.totalRows} imported, ${result.skipped} skipped, ${result.errors.length} errors');
    return Result.success(result);
  }

  /// Build a map of "categoryname_type" -> categoryId
  Map<String, int> _buildCategoryMap(List<CategoryEntity> categories) {
    final map = <String, int>{};
    for (final cat in categories) {
      final key = '${cat.name.toLowerCase()}_${cat.type.value}';
      map[key] = cat.id!;
    }
    return map;
  }

  /// Build a dedup set of "{amount}_{dateTime.millisecondsSinceEpoch}_{type}_{categoryId}"
  Set<String> _buildDedupSet(List<TransactionEntity> transactions) {
    return transactions.map((t) =>
      '${t.amount}_${t.dateTime.millisecondsSinceEpoch}_${t.type.value}_${t.categoryId}'
    ).toSet();
  }

  /// Parse transaction type from Indonesian string
  TransactionType? _parseType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'pemasukan':
        return TransactionType.income;
      case 'pengeluaran':
        return TransactionType.expense;
      default:
        return null;
    }
  }

  /// Parse date from dd/MM/yyyy format
  DateTime? _parseDate(String dateStr) {
    final parts = dateStr.split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return null;
    if (year < 1900 || year > 2100) return null;
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > 31) return null;

    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  /// Parse amount string with thousand separators (e.g., "5.000.000")
  double? _parseAmount(String amountStr) {
    // Remove thousand separators (dots in Indonesian format)
    final cleaned = amountStr.replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(cleaned);
  }
}
