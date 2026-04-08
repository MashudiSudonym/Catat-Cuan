import 'package:catat_cuan/data/services/csv_export_service_impl.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Initialize logger for tests
  setUpAll(() {
    AppLogger.initialize();
  });

  late CsvExportServiceImpl service;

  setUp(() {
    service = CsvExportServiceImpl();
  });

  group('CsvExportServiceImpl generateCsvString', () {
    test('should generate valid CSV with Indonesian headers', () {
      // Arrange
      final transactions = [
        {
          'id': 1,
          'date_time': '2026-03-18T14:30:00.000Z',
          'type': 'expense',
          'category_name': 'Makan',
          'amount': 25000.0,
          'note': 'Makan siang',
        },
      ];

      // Act
      final csv = service.generateCsvString(transactions);

      // Assert
      expect(csv, contains('ID,Tanggal,Waktu,Jenis,Kategori,Jumlah,Catatan'));
      expect(csv, contains('1,18/3/2026,14:30,Pengeluaran,Makan,25000,Makan siang'));
    });

    test('should format date correctly (DD/MM/YYYY)', () {
      // Arrange
      final transactions = [
        {
          'id': 1,
          'date_time': '2026-12-25T10:15:00.000Z',
          'type': 'expense',
          'category_name': 'Hadiah',
          'amount': 500000.0,
          'note': 'Kado Natal',
        },
      ];

      // Act
      final csv = service.generateCsvString(transactions);

      // Assert
      expect(csv, contains('25/12/2026'));
    });

    test('should format time correctly (HH:mm)', () {
      // Arrange
      final transactions = [
        {
          'id': 1,
          'date_time': '2026-03-18T09:05:00.000Z',
          'type': 'expense',
          'category_name': 'Sarapan',
          'amount': 15000.0,
          'note': 'Nasi uduk',
        },
      ];

      // Act
      final csv = service.generateCsvString(transactions);

      // Assert
      expect(csv, contains('09:05'));
    });

    test('should translate transaction type to Indonesian', () {
      // Arrange - Test both income and expense
      final transactions = [
        {
          'id': 1,
          'date_time': '2026-03-18T10:00:00.000Z',
          'type': 'income',
          'category_name': 'Gaji',
          'amount': 5000000.0,
          'note': 'Gaji bulanan',
        },
        {
          'id': 2,
          'date_time': '2026-03-18T14:30:00.000Z',
          'type': 'expense',
          'category_name': 'Makan',
          'amount': 25000.0,
          'note': 'Makan siang',
        },
      ];

      // Act
      final csv = service.generateCsvString(transactions);

      // Assert
      expect(csv, contains('Pemasukan'));
      expect(csv, contains('Pengeluaran'));
    });

    test('should format currency as plain number without separators', () {
      // Arrange
      final transactions = [
        {
          'id': 1,
          'date_time': '2026-03-18T14:30:00.000Z',
          'type': 'expense',
          'category_name': 'Belanja',
          'amount': 150000.0,
          'note': 'Beli barang',
        },
      ];

      // Act
      final csv = service.generateCsvString(transactions);

      // Assert
      expect(csv, contains('150000')); // No decimal places for currency
    });

    test('should escape cells containing commas', () {
      // Arrange
      final transactions = [
        {
          'id': 1,
          'date_time': '2026-03-18T14:30:00.000Z',
          'type': 'expense',
          'category_name': 'Makan',
          'amount': 25000.0,
          'note': 'Makan siang, enak banget',
        },
      ];

      // Act
      final csv = service.generateCsvString(transactions);

      // Assert
      expect(csv, contains('"Makan siang, enak banget"'));
    });

    test('should escape cells containing quotes by doubling them', () {
      // Arrange
      final transactions = [
        {
          'id': 1,
          'date_time': '2026-03-18T14:30:00.000Z',
          'type': 'expense',
          'category_name': 'Makan',
          'amount': 25000.0,
          'note': 'Makan siang "enak" banget',
        },
      ];

      // Act
      final csv = service.generateCsvString(transactions);

      // Assert - CSV escaping doubles quotes within quoted cells: "Makan siang ""enak"" banget"
      expect(csv, contains('"Makan siang ""enak"" banget"'));
    });

    test('should handle null category name gracefully', () {
      // Arrange
      final transactions = [
        {
          'id': 1,
          'date_time': '2026-03-18T14:30:00.000Z',
          'type': 'expense',
          'category_name': null,
          'amount': 25000.0,
          'note': 'Tanpa kategori',
        },
      ];

      // Act
      final csv = service.generateCsvString(transactions);

      // Assert
      expect(csv, contains('1,18/3/2026')); // Partial match to verify row exists
    });

    test('should handle null note gracefully', () {
      // Arrange
      final transactions = [
        {
          'id': 1,
          'date_time': '2026-03-18T14:30:00.000Z',
          'type': 'expense',
          'category_name': 'Makan',
          'amount': 25000.0,
          'note': null,
        },
      ];

      // Act
      final csv = service.generateCsvString(transactions);

      // Assert - null note becomes empty string, row ends with trailing comma
      final lines = csv.split('\n');
      expect(lines[1], endsWith(',')); // Data row ends with comma (empty note field)
    });

    test('should generate multiple rows correctly', () {
      // Arrange
      final transactions = [
        {
          'id': 1,
          'date_time': '2026-03-18T12:00:00.000Z',
          'type': 'expense',
          'category_name': 'Makan',
          'amount': 25000.0,
          'note': 'Makan siang',
        },
        {
          'id': 2,
          'date_time': '2026-03-18T18:00:00.000Z',
          'type': 'expense',
          'category_name': 'Transport',
          'amount': 50000.0,
          'note': 'Bensin',
        },
      ];

      // Act
      final csv = service.generateCsvString(transactions);

      // Assert
      final lines = csv.split('\n');
      expect(lines.length, 3); // Header + 2 data rows
      expect(lines[0], contains('ID,Tanggal'));
      expect(lines[1], contains('1,'));
      expect(lines[2], contains('2,'));
    });

    test('should handle date_time as integer (milliseconds since epoch)', () async {
      // Arrange
      final transactions = [
        {
          'id': 1,
          'date_time': 1700131200000, // 2023-11-17 00:00:00 UTC in milliseconds
          'type': 'expense',
          'category_name': 'Test',
          'amount': 10000.0,
          'note': 'Test note',
        },
      ];

      // Act
      final csv = service.generateCsvString(transactions);

      // Assert - Should handle the int format and convert to date
      expect(csv, contains('1,')); // Row exists
    });

    test('should round currency to 0 decimal places', () {
      // Arrange
      final transactions = [
        {
          'id': 1,
          'date_time': '2026-03-18T14:30:00.000Z',
          'type': 'expense',
          'category_name': 'Belanja',
          'amount': 12345.67,
          'note': 'Belanja',
        },
      ];

      // Act
      final csv = service.generateCsvString(transactions);

      // Assert
      expect(csv, contains('12346')); // Rounded to nearest integer
    });
  });
}
