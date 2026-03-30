/// Represents the result of a CSV import operation
class ImportResult {
  /// Total number of data rows in the CSV file (excluding header)
  final int totalRows;

  /// Number of rows successfully imported
  final int imported;

  /// Number of rows skipped (duplicates, empty rows)
  final int skipped;

  /// List of row-level errors encountered during import
  final List<ImportRowError> errors;

  /// Number of categories auto-created during import
  final int categoriesCreated;

  const ImportResult({
    required this.totalRows,
    required this.imported,
    required this.skipped,
    required this.errors,
    this.categoriesCreated = 0,
  });

  /// Whether any rows had errors
  bool get hasErrors => errors.isNotEmpty;

  /// Whether the import was fully successful (all rows imported, no errors)
  bool get isFullySuccessful => imported == totalRows && errors.isEmpty;

  /// Whether any categories were auto-created during import
  bool get hasCategoriesCreated => categoriesCreated > 0;
}

/// Represents an error for a specific CSV row
class ImportRowError {
  /// 1-based row number in the CSV file
  final int rowNumber;

  /// Raw row data string
  final String rowData;

  /// Human-readable error message
  final String errorMessage;

  const ImportRowError({
    required this.rowNumber,
    required this.rowData,
    required this.errorMessage,
  });
}

/// Intermediate parsed CSV row before validation
class ParsedCsvRow {
  /// 1-based row number in the CSV file
  final int rowNumber;

  /// Date string in dd/MM/yyyy format
  final String date;

  /// Time string in HH:mm format (empty for backward compatibility with old CSV files)
  final String time;

  /// Transaction type string ("Pemasukan" or "Pengeluaran")
  final String type;

  /// Category name string
  final String category;

  /// Amount string (may contain thousand separators)
  final String amount;

  /// Optional note
  final String note;

  const ParsedCsvRow({
    required this.rowNumber,
    required this.date,
    this.time = '',
    required this.type,
    required this.category,
    required this.amount,
    required this.note,
  });
}
