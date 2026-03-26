/// Service for generating file names for exports
///
/// Responsibility: Generating timestamped file names for data export
///
/// Following SRP - Only handles file name generation
class FileNamingService {
  FileNamingService._();

  /// Generate timestamp suffix for file names
  ///
  /// Returns formatted timestamp in YYYYMMDD_HHMMSS format
  /// Example: 20260326_143055
  static String generateTimestampSuffix() {
    final now = DateTime.now();

    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');

    return '$year$month$day' '_$hour$minute$second';
  }

  /// Generate date suffix for file names
  ///
  /// Returns formatted date in YYYYMMDD format
  /// Example: 20260326
  static String generateDateSuffix() {
    final now = DateTime.now();

    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '$year$month$day';
  }

  /// Generate export file name with timestamp
  ///
  /// Parameters:
  /// - [baseName]: Base name for the file (e.g., 'transactions', 'expenses')
  /// - [extension]: File extension (default: 'csv')
  ///
  /// Returns formatted file name: {baseName}_{timestamp}.{extension}
  /// Example: transactions_20260326_143055.csv
  static String generateExportFileName(
    String baseName, {
    String extension = 'csv',
    bool includeTimestamp = true,
  }) {
    if (includeTimestamp) {
      final timestamp = generateTimestampSuffix();
      return '${baseName}_$timestamp.$extension';
    } else {
      return '$baseName.$extension';
    }
  }

  /// Generate export file name with date only
  ///
  /// Parameters:
  /// - [baseName]: Base name for the file (e.g., 'transactions', 'expenses')
  /// - [extension]: File extension (default: 'csv')
  ///
  /// Returns formatted file name: {baseName}_{date}.{extension}
  /// Example: transactions_20260326.csv
  static String generateExportFileNameWithDate(
    String baseName, {
    String extension = 'csv',
  }) {
    final date = generateDateSuffix();
    return '${baseName}_$date.$extension';
  }

  /// Sanitize file name
  ///
  /// Removes or replaces invalid characters from file names
  /// Parameters:
  /// - [fileName]: The file name to sanitize
  ///
  /// Returns sanitized file name safe for file systems
  static String sanitizeFileName(String fileName) {
    // Replace invalid characters with underscore
    final sanitized = fileName.replaceAll(
      RegExp(r'[<>:"/\\|?*]'),
      '_',
    );

    // Remove leading/trailing spaces and dots
    return sanitized.replaceAll(RegExp(r'^[.\s]+|[.\s]+$'), '');
  }

  /// Generate safe export file name
  ///
  /// Combines base name sanitization with timestamp generation
  /// Parameters:
  /// - [baseName]: Base name for the file
  /// - [extension]: File extension (default: 'csv')
  ///
  /// Returns sanitized and formatted file name
  static String generateSafeExportFileName(
    String baseName, {
    String extension = 'csv',
  }) {
    final sanitizedBase = sanitizeFileName(baseName);
    return generateExportFileName(sanitizedBase, extension: extension);
  }
}
