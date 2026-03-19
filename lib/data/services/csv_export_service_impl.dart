import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/services/export_service.dart';

/// CSV Export service implementation
/// Implements ExportService for CSV export functionality
class CsvExportServiceImpl implements ExportService {
  @override
  Future<Result<String>> saveTransactionsToCsv({
    required List<Map<String, dynamic>> transactions,
    required String fileName,
  }) async {
    try {
      // Get export directory
      final exportDir = await _getExportDirectory();

      // Generate CSV file
      final file = await _generateCsvFile(transactions, fileName, exportDir);

      // Verify file exists
      if (await file.exists()) {
        return Result.success(file.path);
      } else {
        return Result.failure(ExportFailure('File tidak ditemukan setelah disimpan'));
      }
    } catch (e) {
      return Result.failure(ExportFailure('Gagal menyimpan: ${e.toString()}'));
    }
  }

  @override
  Future<Result<String>> shareTransactionsToCsv({
    required List<Map<String, dynamic>> transactions,
    required String fileName,
  }) async {
    try {
      // Generate CSV file in temp directory
      final tempDir = await getTemporaryDirectory();
      final file = await _generateCsvFile(transactions, fileName, tempDir);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Export Transaksi - Catat Cuan',
      );

      return Result.success(file.path);
    } catch (e) {
      return Result.failure(ExportFailure('Gagal membagikan: ${e.toString()}'));
    }
  }

  @override
  @Deprecated('Use saveTransactionsToCsv or shareTransactionsToCsv instead')
  Future<Result<String>> exportTransactionsToCsv({
    required List<Map<String, dynamic>> transactions,
    required String fileName,
  }) async {
    // Default to share behavior for backward compatibility
    return shareTransactionsToCsv(transactions: transactions, fileName: fileName);
  }

  /// Get the export directory for saving CSV files
  /// Creates "CatatCuan/Exports" subdirectory in Documents folder
  Future<Directory> _getExportDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${documentsDir.path}/CatatCuan/Exports');

    // Create directory if it doesn't exist
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    return exportDir;
  }

  /// Generate CSV file with transaction data
  /// Returns the created file
  Future<File> _generateCsvFile(
    List<Map<String, dynamic>> transactions,
    String fileName,
    Directory directory,
  ) async {
    // Define CSV headers in Indonesian
    const headers = [
      'ID',
      'Tanggal',
      'Jenis',
      'Kategori',
      'Jumlah',
      'Catatan',
    ];

    // Convert transactions to CSV rows
    List<List<dynamic>> rows = [headers];

    for (var tx in transactions) {
      rows.add([
        tx['id'],
        _formatDate(tx['date_time']),
        _translateType(tx['type']),
        tx['category_name'] ?? '',
        _formatCurrency(tx['amount']),
        tx['note'] ?? '',
      ]);
    }

    // Generate CSV string
    final csvString = const ListToCsvConverter().convert(rows);

    // Write to file
    final file = File('${directory.path}/$fileName.csv');
    await file.writeAsString(csvString);

    return file;
  }

  /// Format date from milliseconds or ISO string to Indonesian date format
  String _formatDate(dynamic dateTime) {
    DateTime date;
    if (dateTime is int) {
      date = DateTime.fromMillisecondsSinceEpoch(dateTime);
    } else if (dateTime is String) {
      date = DateTime.parse(dateTime);
    } else {
      date = DateTime.now();
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Translate transaction type to Indonesian
  String _translateType(String type) {
    return type == 'income' ? 'Pemasukan' : 'Pengeluaran';
  }

  /// Format currency with Indonesian thousand separators
  String _formatCurrency(dynamic amount) {
    final doubleValue = amount is String
        ? double.parse(amount)
        : (amount is int ? amount.toDouble() : amount as double);
    return doubleValue.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
