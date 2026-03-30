import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/entities/import_result_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_management_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_write_repository.dart';
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
  final CategoryWriteRepository _categoryWriteRepository;
  final CategoryManagementRepository _categoryManagementRepository;
  final TransactionWriteRepository _transactionWriteRepository;
  final TransactionQueryRepository _transactionQueryRepository;

  ImportTransactionsUseCase(
    this._importService,
    this._categoryReadRepository,
    this._categoryWriteRepository,
    this._categoryManagementRepository,
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
    final createdCategories = <String>{}; // Track created category keys

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
      final dateTime = _parseDateTime(row.date, row.time);
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

      // Resolve or create category
      final categoryKey = '${row.category.toLowerCase()}_${type == TransactionType.income ? 'income' : 'expense'}';
      final categoryType = type == TransactionType.income ? CategoryType.income : CategoryType.expense;

      final categoryId = await _resolveOrCreateCategory(
        row.category,
        categoryType,
        categoryKey,
        categoryMap,
        createdCategories,
        errors,
        row,
        rowDisplay,
      );

      if (categoryId == null) {
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
      categoriesCreated: createdCategories.length,
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

  /// Parse date from dd/MM/yyyy format with optional time in HH:mm format
  DateTime? _parseDateTime(String dateStr, [String timeStr = '']) {
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
      int hour = 0;
      int minute = 0;

      // Parse time if provided
      if (timeStr.isNotEmpty) {
        final timeParts = timeStr.split(':');
        if (timeParts.length == 2) {
          hour = int.tryParse(timeParts[0]) ?? 0;
          minute = int.tryParse(timeParts[1]) ?? 0;
        }
      }

      return DateTime(year, month, day, hour, minute);
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

  /// Resolve category by name, reactivate if soft-deleted, or create new one
  ///
  /// Returns category ID if successful, null if failed (error already added to errors list)
  Future<int?> _resolveOrCreateCategory(
    String categoryName,
    CategoryType type,
    String categoryKey,
    Map<String, int> categoryMap,
    Set<String> createdCategories,
    List<ImportRowError> errors,
    ParsedCsvRow row,
    String rowDisplay,
  ) async {
    // 1. Check categoryMap (active categories) — if found, return ID directly
    final existingId = categoryMap[categoryKey];
    if (existingId != null) {
      return existingId;
    }

    // 2. Call getCategoryByName(name, type) — searches ALL categories including inactive
    final categoryResult = await _categoryReadRepository.getCategoryByName(categoryName, type);
    if (categoryResult.isSuccess && categoryResult.data != null) {
      final category = categoryResult.data!;
      // If found and isActive == false → call reactivateCategory(id) → return ID
      if (!category.isActive && category.id != null) {
        final reactivateResult = await _categoryManagementRepository.reactivateCategory(category.id!);
        if (reactivateResult.isSuccess) {
          AppLogger.d('Reactivated soft-deleted category: ${category.name} (ID: ${category.id})');
          return category.id!;
        }
        // Reactivate failed, will fall through to create new
      } else if (category.isActive && category.id != null) {
        // Defensive fallback: active category not in map (shouldn't happen)
        return category.id;
      }
    }

    // 3. If no match at all → create new via addCategory() with defaults
    final now = DateTime.now();
    final newCategory = CategoryEntity(
      name: categoryName,
      type: type,
      color: '#6B7280', // neutral gray
      icon: null,
      sortOrder: categoryMap.length + 1,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    final addResult = await _categoryWriteRepository.addCategory(newCategory);
    if (addResult.isSuccess && addResult.data?.id != null) {
      final newId = addResult.data!.id!;
      AppLogger.d('Created new category: $categoryName (ID: $newId)');
      // Cache in categoryMap so same unknown category in multiple rows is only created once
      categoryMap[categoryKey] = newId;
      // Track that we created this category
      createdCategories.add(categoryKey);
      return newId;
    }

    // 5. If both reactivate and create fail → return null (row becomes error)
    errors.add(ImportRowError(
      rowNumber: row.rowNumber,
      rowData: rowDisplay,
      errorMessage: 'Gagal membuat kategori: "$categoryName" (${type.displayName})',
    ));
    return null;
  }
}
