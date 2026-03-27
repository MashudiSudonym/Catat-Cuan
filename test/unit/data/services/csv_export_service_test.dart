import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/data/services/csv_export_service_impl.dart';

void main() {
  late CsvExportServiceImpl service;

  setUp(() {
    service = CsvExportServiceImpl();
  });

  group('generateCsvString', () {
    test('amounts are exported as raw numbers without thousand separators', () {
      final transactions = [
        {
          'id': 1,
          'date_time': DateTime(2026, 3, 15).millisecondsSinceEpoch,
          'type': 'expense',
          'category_name': 'Makanan',
          'amount': 5000,
          'note': '',
        },
      ];

      final csv = service.generateCsvString(transactions);

      expect(csv, contains(',5000,'));
      expect(csv, isNot(contains('5.000')));
    });

    test('large amounts are exported without thousand separators', () {
      final transactions = [
        {
          'id': 2,
          'date_time': DateTime(2026, 3, 15).millisecondsSinceEpoch,
          'type': 'income',
          'category_name': 'Gaji',
          'amount': 15000000,
          'note': '',
        },
      ];

      final csv = service.generateCsvString(transactions);

      expect(csv, contains(',15000000,'));
      expect(csv, isNot(contains('15.000.000')));
    });

    test('amounts under 1000 are unaffected', () {
      final transactions = [
        {
          'id': 3,
          'date_time': DateTime(2026, 3, 15).millisecondsSinceEpoch,
          'type': 'expense',
          'category_name': 'Parkir',
          'amount': 500,
          'note': '',
        },
      ];

      final csv = service.generateCsvString(transactions);

      expect(csv, contains(',500,'));
    });

    test('handles String amount type', () {
      final transactions = [
        {
          'id': 4,
          'date_time': DateTime(2026, 3, 15).millisecondsSinceEpoch,
          'type': 'expense',
          'category_name': 'Makanan',
          'amount': '7500',
          'note': '',
        },
      ];

      final csv = service.generateCsvString(transactions);

      expect(csv, contains(',7500,'));
      expect(csv, isNot(contains('7.500')));
    });

    test('handles double amount type', () {
      final transactions = [
        {
          'id': 5,
          'date_time': DateTime(2026, 3, 15).millisecondsSinceEpoch,
          'type': 'expense',
          'category_name': 'Makanan',
          'amount': 25000.0,
          'note': '',
        },
      ];

      final csv = service.generateCsvString(transactions);

      expect(csv, contains(',25000,'));
      expect(csv, isNot(contains('25.000')));
    });

    test('exported amounts are parseable by import _parseAmount logic', () {
      // Simulates the import parsing: remove dots then double.tryParse
      final amounts = [5000, 15000000, 500, 999999];
      for (final amount in amounts) {
        final transactions = [
          {
            'id': 1,
            'date_time': DateTime(2026, 3, 15).millisecondsSinceEpoch,
            'type': 'expense',
            'category_name': 'Test',
            'amount': amount,
            'note': '',
          },
        ];

        final csv = service.generateCsvString(transactions);
        // Extract amount from CSV (5th column)
        final lines = csv.split('\n');
        final dataLine = lines[1];
        final columns = dataLine.split(',');
        final amountStr = columns[4];

        // Simulate import's _parseAmount
        final cleaned = amountStr.replaceAll('.', '').replaceAll(',', '.').trim();
        final parsed = double.tryParse(cleaned);

        expect(parsed, equals(amount.toDouble()),
            reason: 'Amount $amount should round-trip correctly');
      }
    });

    test('CSV has correct headers', () {
      final csv = service.generateCsvString([]);

      expect(csv, startsWith('ID,Tanggal,Jenis,Kategori,Jumlah,Catatan'));
    });

    test('multiple transactions are on separate lines', () {
      final transactions = [
        {
          'id': 1,
          'date_time': DateTime(2026, 1, 1).millisecondsSinceEpoch,
          'type': 'income',
          'category_name': 'Gaji',
          'amount': 10000000,
          'note': '',
        },
        {
          'id': 2,
          'date_time': DateTime(2026, 1, 2).millisecondsSinceEpoch,
          'type': 'expense',
          'category_name': 'Makanan',
          'amount': 50000,
          'note': 'Lunch',
        },
      ];

      final csv = service.generateCsvString(transactions);
      final lines = csv.split('\n');

      expect(lines.length, equals(3)); // header + 2 data rows
      expect(lines[1], contains('10000000'));
      expect(lines[2], contains('50000'));
    });

    test('notes with commas are properly quoted', () {
      final transactions = [
        {
          'id': 1,
          'date_time': DateTime(2026, 3, 15).millisecondsSinceEpoch,
          'type': 'expense',
          'category_name': 'Makanan',
          'amount': 10000,
          'note': 'ayam, nasi, teh',
        },
      ];

      final csv = service.generateCsvString(transactions);

      expect(csv, contains('"ayam, nasi, teh"'));
    });
  });
}
