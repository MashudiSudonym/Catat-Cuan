import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/import_result_entity.dart';

/// Import service interface for parsing import files
/// Following DIP: High-level modules depend on this abstraction
abstract class ImportService {
  /// Parse a CSV file into a list of parsed rows
  ///
  /// - [filePath]: Absolute path to the CSV file
  /// Returns Result with list of ParsedCsvRow if successful, failure if file cannot be read or header is invalid
  Future<Result<List<ParsedCsvRow>>> parseCsvFile(String filePath);
}
