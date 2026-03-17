import 'package:catat_cuan/domain/core/result.dart';

/// Export service interface for exporting data to various formats
/// Following DIP: High-level modules depend on this abstraction
abstract class ExportService {
  /// Export transactions to CSV format
  /// - [transactions]: List of transaction data as maps
  /// - [fileName]: Name of the file to generate (without extension)
  /// Returns Result with file path if successful, error message if failed
  Future<Result<String>> exportTransactionsToCsv({
    required List<Map<String, dynamic>> transactions,
    required String fileName,
  });
}
