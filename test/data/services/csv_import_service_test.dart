import 'dart:io';
import 'package:catat_cuan/data/services/csv_import_service_impl.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/import_result_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  // Initialize logger for tests
  setUpAll(() {
    AppLogger.initialize();
  });

  late CsvImportServiceImpl service;
  late Directory tempDir;

  setUp(() async {
    service = CsvImportServiceImpl();
    tempDir = await Directory.systemTemp.createTemp('csv_import_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('CsvImportServiceImpl parseCsvFile', () {
    Future<String> createTempCsvFile(String content) async {
      final file = File(path.join(tempDir.path, 'test.csv'));
      await file.writeAsString(content);
      return file.path;
    }

    group('Header validation', () {
      test('should accept valid new format headers with Waktu column', () async {
        // Arrange
        final content = '''ID,Tanggal,Waktu,Jenis,Kategori,Jumlah,Catatan
1,18/3/2026,14:30,Pengeluaran,Makan,25000,Makan siang''';
        final filePath = await createTempCsvFile(content);

        // Act
        final result = await service.parseCsvFile(filePath);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.length, 1);
        expect(result.data?.first.date, '18/3/2026');
        expect(result.data?.first.time, '14:30');
        expect(result.data?.first.type, 'Pengeluaran');
        expect(result.data?.first.category, 'Makan');
        expect(result.data?.first.amount, '25000');
        expect(result.data?.first.note, 'Makan siang');
      });

      test('should accept valid old format headers without Waktu column', () async {
        // Arrange
        final content = '''ID,Tanggal,Jenis,Kategori,Jumlah,Catatan
1,18/3/2026,Pengeluaran,Makan,25000,Makan siang''';
        final filePath = await createTempCsvFile(content);

        // Act
        final result = await service.parseCsvFile(filePath);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.length, 1);
        expect(result.data?.first.date, '18/3/2026');
        expect(result.data?.first.time, isEmpty); // Old format has no time
        expect(result.data?.first.type, 'Pengeluaran');
      });

      test('should reject invalid headers', () async {
        // Arrange
        final content = '''InvalidHeader1,InvalidHeader2,InvalidHeader3
1,data,more''';
        final filePath = await createTempCsvFile(content);

        // Act
        final result = await service.parseCsvFile(filePath);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<ImportFailure>());
        expect(result.failure?.message, contains('Format header CSV tidak sesuai'));
      });

      test('should strip UTF-8 BOM from file', () async {
        // Arrange - File with UTF-8 BOM prefix
        final content = '\ufeffID,Tanggal,Waktu,Jenis,Kategori,Jumlah,Catatan\n1,18/3/2026,14:30,Pengeluaran,Makan,25000,Makan siang';
        final filePath = await createTempCsvFile(content);

        // Act
        final result = await service.parseCsvFile(filePath);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.length, 1);
      });
    });

    group('Row parsing', () {
      test('should handle quoted fields with commas', () async {
        // Arrange
        final content = '''ID,Tanggal,Waktu,Jenis,Kategori,Jumlah,Catatan
1,18/3/2026,14:30,Pengeluaran,Makan,"25,000",Makan siang dengan koma''';
        final filePath = await createTempCsvFile(content);

        // Act
        final result = await service.parseCsvFile(filePath);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.first.amount, '25,000');
      });

      test('should handle quoted fields with escaped quotes', () async {
        // Arrange
        final content = '''ID,Tanggal,Waktu,Jenis,Kategori,Jumlah,Catatan
1,18/3/2026,14:30,Pengeluaran,Makan,25000,"Makan siang ""enak"" banget"''';
        final filePath = await createTempCsvFile(content);

        // Act
        final result = await service.parseCsvFile(filePath);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.first.note, 'Makan siang "enak" banget');
      });

      test('should skip empty lines', () async {
        // Arrange
        final content = '''ID,Tanggal,Waktu,Jenis,Kategori,Jumlah,Catatan
1,18/3/2026,14:30,Pengeluaran,Makan,25000,Makan siang

2,18/3/2026,18:00,Pengeluaran,Transport,50000,Bensin''';
        final filePath = await createTempCsvFile(content);

        // Act
        final result = await service.parseCsvFile(filePath);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.length, 2); // Empty line skipped
      });

      test('should skip malformed rows with insufficient fields', () async {
        // Arrange
        final content = '''ID,Tanggal,Waktu,Jenis,Kategori,Jumlah,Catatan
1,18/3/2026,14:30,Pengeluaran
2,18/3/2026,18:00,Pengeluaran,Transport,50000,Bensin''';
        final filePath = await createTempCsvFile(content);

        // Act
        final result = await service.parseCsvFile(filePath);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.length, 1); // Only the valid row
        expect(result.data?.first.category, 'Transport');
      });

      test('should handle different line endings (CRLF, LF, CR)', () async {
        // Arrange - Mixed line endings
        final content = 'ID,Tanggal,Waktu,Jenis,Kategori,Jumlah,Catatan\r\n1,18/3/2026,14:30,Pengeluaran,Makan,25000,Makan siang\n2,18/3/2026,18:00,Pengeluaran,Transport,50000,Bensin';
        final filePath = await createTempCsvFile(content);

        // Act
        final result = await service.parseCsvFile(filePath);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.length, 2);
      });
    });

    group('Edge cases', () {
      test('should return failure when file does not exist', () async {
        // Arrange
        final filePath = path.join(tempDir.path, 'nonexistent.csv');

        // Act
        final result = await service.parseCsvFile(filePath);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<ImportFailure>());
        expect(result.failure?.message, contains('tidak ditemukan'));
      });

      test('should return failure when file is empty', () async {
        // Arrange
        final filePath = await createTempCsvFile('');

        // Act
        final result = await service.parseCsvFile(filePath);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure?.message, contains('kosong'));
      });

      test('should return failure when no data rows found', () async {
        // Arrange - Only header, no data
        final content = 'ID,Tanggal,Waktu,Jenis,Kategori,Jumlah,Catatan';
        final filePath = await createTempCsvFile(content);

        // Act
        final result = await service.parseCsvFile(filePath);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure?.message, contains('Tidak ada data'));
      });

      test('should handle null/empty note field', () async {
        // Arrange
        final content = '''ID,Tanggal,Waktu,Jenis,Kategori,Jumlah,Catatan
1,18/3/2026,14:30,Pengeluaran,Makan,25000,''';
        final filePath = await createTempCsvFile(content);

        // Act
        final result = await service.parseCsvFile(filePath);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.first.note, isEmpty);
      });

      test('should handle both income and expense types', () async {
        // Arrange
        final content = '''ID,Tanggal,Waktu,Jenis,Kategori,Jumlah,Catatan
1,18/3/2026,14:30,Pengeluaran,Makan,25000,Makan siang
2,18/3/2026,09:00,Pemasukan,Gaji,5000000,Gaji bulanan''';
        final filePath = await createTempCsvFile(content);

        // Act
        final result = await service.parseCsvFile(filePath);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.length, 2);
        expect(result.data?[0].type, 'Pengeluaran');
        expect(result.data?[1].type, 'Pemasukan');
      });
    });
  });
}
