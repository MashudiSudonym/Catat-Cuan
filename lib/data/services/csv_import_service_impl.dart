import 'dart:io';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/import_result_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/services/import_service.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// CSV Import service implementation
/// Implements ImportService for CSV import functionality
class CsvImportServiceImpl implements ImportService {
  /// Expected CSV header columns
  static const _expectedHeaders = ['ID', 'Tanggal', 'Jenis', 'Kategori', 'Jumlah', 'Catatan'];

  /// UTF-8 BOM bytes
  static const _utf8Bom = '\ufeff';

  @override
  Future<Result<List<ParsedCsvRow>>> parseCsvFile(String filePath) async {
    AppLogger.d('Starting CSV import parse: $filePath');

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return Result.failure(const ImportFailure('File tidak ditemukan'));
      }

      String content = await file.readAsString();

      // Strip UTF-8 BOM if present
      if (content.startsWith(_utf8Bom)) {
        content = content.substring(1);
      }

      content = content.trim();

      if (content.isEmpty) {
        return Result.failure(const ImportFailure('File CSV kosong'));
      }

      // Split into lines and parse
      final lines = _splitLines(content);
      if (lines.isEmpty) {
        return Result.failure(const ImportFailure('File CSV kosong'));
      }

      // Validate header
      final headerLine = lines[0].trim();
      final headers = _parseCsvRow(headerLine);
      if (!_validateHeaders(headers)) {
        return Result.failure(
          const ImportFailure('Format header CSV tidak sesuai. Kolom: ID,Tanggal,Jenis,Kategori,Jumlah,Catatan'),
        );
      }

      AppLogger.d('CSV header validated successfully');

      // Parse data rows
      final parsedRows = <ParsedCsvRow>[];
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue; // Skip empty lines

        final fields = _parseCsvRow(line);
        if (fields.length < 5) continue; // Skip malformed rows (need at least ID,Tanggal,Jenis,Kategori,Jumlah)

        parsedRows.add(ParsedCsvRow(
          rowNumber: i + 1, // 1-based row number (1 = header)
          date: fields[1].trim(),
          type: fields[2].trim(),
          category: fields[3].trim(),
          amount: fields[4].trim(),
          note: fields.length > 5 ? fields[5].trim() : '',
        ));
      }

      if (parsedRows.isEmpty) {
        return Result.failure(const ImportFailure('Tidak ada data yang ditemukan dalam file CSV'));
      }

      AppLogger.i('CSV parsed successfully: ${parsedRows.length} data rows');
      return Result.success(parsedRows);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to parse CSV file', e, stackTrace);
      return Result.failure(const ImportFailure('Gagal membaca file CSV. Silakan coba lagi.'));
    }
  }

  /// Validate CSV headers match expected format
  bool _validateHeaders(List<String> headers) {
    if (headers.length < _expectedHeaders.length) return false;
    for (int i = 0; i < _expectedHeaders.length; i++) {
      if (headers[i].trim() != _expectedHeaders[i]) return false;
    }
    return true;
  }

  /// Parse a single CSV row handling quoted fields
  List<String> _parseCsvRow(String row) {
    final fields = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < row.length; i++) {
      final char = row[i];

      if (inQuotes) {
        if (char == '"') {
          // Check for escaped quote ""
          if (i + 1 < row.length && row[i + 1] == '"') {
            buffer.write('"');
            i++; // Skip next quote
          } else {
            inQuotes = false; // End of quoted field
          }
        } else {
          buffer.write(char);
        }
      } else {
        if (char == '"') {
          inQuotes = true;
        } else if (char == ',') {
          fields.add(buffer.toString());
          buffer.clear();
        } else {
          buffer.write(char);
        }
      }
    }

    // Add the last field
    fields.add(buffer.toString());

    return fields;
  }

  /// Split content into lines handling different line endings
  List<String> _splitLines(String content) {
    return content.split(RegExp(r'\r\n|\r|\n'));
  }
}
