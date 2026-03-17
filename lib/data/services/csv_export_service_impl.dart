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
  Future<Result<String>> exportTransactionsToCsv({
    required List<Map<String, dynamic>> transactions,
    required String fileName,
  }) async {
    try {
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

      // Write to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName.csv');
      await file.writeAsString(csvString);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Export Transaksi - Catat Cuan',
      );

      return Result.success(file.path);
    } catch (e) {
      return Result.failure(ExportFailure('Gagal mengekspor: ${e.toString()}'));
    }
  }

  /// Format date from milliseconds to Indonesian date format
  String _formatDate(int dateTime) {
    final date = DateTime.fromMillisecondsSinceEpoch(dateTime);
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Translate transaction type to Indonesian
  String _translateType(String type) {
    return type == 'income' ? 'Pemasukan' : 'Pengeluaran';
  }

  /// Format currency with Indonesian thousand separators
  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
