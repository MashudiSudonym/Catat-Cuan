import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/services/export_service.dart';
import 'package:catat_cuan/domain/services/file_save_service.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// CSV Export service implementation
/// Implements ExportService for CSV export functionality
class CsvExportServiceImpl implements ExportService {
  final FileSaveService? _fileSaveService;

  /// Constructor with optional FileSaveService
  ///
  /// If [fileSaveService] is provided, saveToDevice will use Storage Access Framework.
  /// Otherwise, it will fall back to direct file system access (legacy behavior).
  CsvExportServiceImpl({FileSaveService? fileSaveService})
      : _fileSaveService = fileSaveService;

  @override
  Future<Result<String>> saveTransactionsToCsv({
    required List<Map<String, dynamic>> transactions,
    required String fileName,
  }) async {
    AppLogger.d('Starting CSV export save: $fileName (${transactions.length} transactions)');

    // Use FileSaveService if available (Storage Access Framework)
    if (_fileSaveService != null) {
      return _saveWithSaf(transactions, fileName);
    }

    // Fallback to legacy direct file system access
    return _saveToFileSystem(transactions, fileName);
  }

  /// Save using Storage Access Framework (system file picker)
  Future<Result<String>> _saveWithSaf(
    List<Map<String, dynamic>> transactions,
    String fileName,
  ) async {
    try {
      AppLogger.d('Using SAF for file save');

      // Generate CSV content
      final csvString = generateCsvString(transactions);
      final csvBytes = utf8.encode(csvString);

      // Use FileSaveService to show system file picker
      final result = await _fileSaveService!.saveFile(
        content: csvBytes,
        fileName: fileName,
        mimeType: 'text/csv',
      );

      return result;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to save CSV via SAF', e, stackTrace);
      return Result.failure(ExportFailure('Gagal menyimpan file'));
    }
  }

  /// Save using direct file system access (legacy)
  Future<Result<String>> _saveToFileSystem(
    List<Map<String, dynamic>> transactions,
    String fileName,
  ) async {
    try {
      AppLogger.d('Using direct file system access');

      // Get export directory
      final exportDir = await _getExportDirectory();
      AppLogger.d('Export directory: ${exportDir.path}');

      // Generate CSV file
      final file = await _generateCsvFile(transactions, fileName, exportDir);
      AppLogger.i('CSV file saved successfully: ${file.path}');

      // Verify file exists
      if (await file.exists()) {
        return Result.success(file.path);
      } else {
        AppLogger.w('CSV file not found after save: ${file.path}');
        return Result.failure(ExportFailure('File tidak ditemukan setelah disimpan'));
      }
    } catch (e, stackTrace) {
      AppLogger.e('Failed to save CSV file', e, stackTrace);
      return Result.failure(ExportFailure('Gagal menyimpan file'));
    }
  }

  @override
  Future<Result<String>> shareTransactionsToCsv({
    required List<Map<String, dynamic>> transactions,
    required String fileName,
  }) async {
    AppLogger.d('Starting CSV export share: $fileName (${transactions.length} transactions)');

    try {
      // Generate CSV file in temp directory
      final tempDir = await getTemporaryDirectory();
      final file = await _generateCsvFile(transactions, fileName, tempDir);
      AppLogger.d('CSV file generated in temp: ${file.path}');

      // Share the file
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Export Transaksi - Catat Cuan',
      );
      AppLogger.i('CSV file shared successfully');

      return Result.success(file.path);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to share CSV file', e, stackTrace);
      return Result.failure(ExportFailure('Gagal membagikan file'));
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
  /// Uses public Download folder on Android so files are easily accessible.
  /// Creates "CatatCuan" subdirectory in Downloads.
  /// On Android: /storage/emulated/0/Download/CatatCuan/
  /// On iOS: Falls back to app documents directory (visible via iTunes file sharing)
  Future<Directory> _getExportDirectory() async {
    // On Android, use the public Download folder
    if (Platform.isAndroid) {
      // Hardcoded path to Download/CatatCuan is more reliable than
      // getExternalStorageDirectory() or getDownloadsDirectory()
      // for writing to public folders with MANAGE_EXTERNAL_STORAGE permission
      const exportPath = '/storage/emulated/0/Download/CatatCuan';
      final exportDir = Directory(exportPath);

      // Create directory if it doesn't exist
      if (!await exportDir.exists()) {
        AppLogger.d('Creating export directory: $exportPath');
        await exportDir.create(recursive: true);
      }

      return exportDir;
    }

    // On iOS and other platforms, fallback to app documents directory
    AppLogger.w('Non-Android platform, falling back to app documents directory');
    final documentsDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${documentsDir.path}/CatatCuan/Exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  /// Generate CSV string from transaction data
  /// Public for testability — allows unit testing without file I/O
  String generateCsvString(List<Map<String, dynamic>> transactions) {
    // Define CSV headers in Indonesian
    const headers = [
      'ID',
      'Tanggal',
      'Waktu',
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
        _formatTime(tx['date_time']),
        _translateType(tx['type']),
        tx['category_name'] ?? '',
        _formatCurrency(tx['amount']),
        tx['note'] ?? '',
      ]);
    }

    // Generate CSV string
    final csvString = rows.map((row) => row.map((cell) {
      // Escape cells containing commas or quotes
      final cellStr = cell?.toString() ?? '';
      if (cellStr.contains(',') || cellStr.contains('"') || cellStr.contains('\n')) {
        return '"${cellStr.replaceAll('"', '""')}"';
      }
      return cellStr;
    }).join(',')).join('\n');

    return csvString;
  }

  /// Generate CSV file with transaction data
  /// Returns the created file
  Future<File> _generateCsvFile(
    List<Map<String, dynamic>> transactions,
    String fileName,
    Directory directory,
  ) async {
    AppLogger.d('Generating CSV file with ${transactions.length} rows');

    final csvString = generateCsvString(transactions);
    AppLogger.d('CSV string generated (${csvString.length} characters)');

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

  /// Format time from milliseconds or ISO string to HH:mm format
  String _formatTime(dynamic dateTime) {
    DateTime date;
    if (dateTime is int) {
      date = DateTime.fromMillisecondsSinceEpoch(dateTime);
    } else if (dateTime is String) {
      date = DateTime.parse(dateTime);
    } else {
      date = DateTime.now();
    }
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Translate transaction type to Indonesian
  String _translateType(String type) {
    return type == 'income' ? 'Pemasukan' : 'Pengeluaran';
  }

  /// Format currency as plain number (no thousand separators)
  /// Uses raw numbers in CSV to avoid misinterpretation by spreadsheet software
  String _formatCurrency(dynamic amount) {
    final doubleValue = amount is String
        ? double.parse(amount)
        : (amount is int ? amount.toDouble() : amount as double);
    return doubleValue.toStringAsFixed(0);
  }
}
