import 'package:catat_cuan/domain/core/result.dart';

/// Export service interface for exporting data to various formats
/// Following DIP: High-level modules depend on this abstraction
abstract class ExportService {
  /// Generate CSV file and save to local device storage
  /// - [transactions]: List of transaction data as maps
  /// - [fileName]: Name of the file to generate (without extension)
  /// Returns Result with file path if successful, error message if failed
  Future<Result<String>> saveTransactionsToCsv({
    required List<Map<String, dynamic>> transactions,
    required String fileName,
  });

  /// Generate CSV file and share via share_plus
  /// - [transactions]: List of transaction data as maps
  /// - [fileName]: Name of the file to generate (without extension)
  /// Returns Result with file path if successful, error message if failed
  Future<Result<String>> shareTransactionsToCsv({
    required List<Map<String, dynamic>> transactions,
    required String fileName,
  });

  /// Export transactions to CSV format (deprecated - use saveTransactionsToCsv or shareTransactionsToCsv)
  /// - [transactions]: List of transaction data as maps
  /// - [fileName]: Name of the file to generate (without extension)
  /// Returns Result with file path if successful, error message if failed
  @Deprecated('Use saveTransactionsToCsv or shareTransactionsToCsv instead')
  Future<Result<String>> exportTransactionsToCsv({
    required List<Map<String, dynamic>> transactions,
    required String fileName,
  });
}
