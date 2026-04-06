import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/entities/import_result_entity.dart';

void main() {
  group('ImportResult', () {
    group('Creation', () {
      test('should create with all fields', () {
        final result = ImportResult(
          totalRows: 10,
          imported: 8,
          skipped: 2,
          errors: [],
        );

        expect(result.totalRows, equals(10));
        expect(result.imported, equals(8));
        expect(result.skipped, equals(2));
        expect(result.errors, isEmpty);
      });

      test('should create with errors', () {
        final errors = [
          ImportRowError(
            rowNumber: 3,
            rowData: 'raw,data',
            errorMessage: 'Invalid format',
          ),
        ];

        final result = ImportResult(
          totalRows: 5,
          imported: 3,
          skipped: 1,
          errors: errors,
        );

        expect(result.errors, hasLength(1));
        expect(result.errors.first.rowNumber, equals(3));
      });

      test('should create with categoriesCreated', () {
        final result = ImportResult(
          totalRows: 10,
          imported: 10,
          skipped: 0,
          errors: [],
          categoriesCreated: 3,
        );

        expect(result.categoriesCreated, equals(3));
      });

      test('should default categoriesCreated to 0', () {
        final result = ImportResult(
          totalRows: 5,
          imported: 5,
          skipped: 0,
          errors: [],
        );

        expect(result.categoriesCreated, equals(0));
      });

      test('should handle all skipped', () {
        final result = ImportResult(
          totalRows: 10,
          imported: 0,
          skipped: 10,
          errors: [],
        );

        expect(result.imported, equals(0));
        expect(result.skipped, equals(10));
      });

      test('should handle empty file', () {
        final result = ImportResult(
          totalRows: 0,
          imported: 0,
          skipped: 0,
          errors: [],
        );

        expect(result.totalRows, equals(0));
      });
    });

    group('Computed properties', () {
      group('hasErrors', () {
        test('should return true when errors list is not empty', () {
          final result = ImportResult(
            totalRows: 5,
            imported: 3,
            skipped: 1,
            errors: [
              ImportRowError(
                rowNumber: 2,
                rowData: 'data',
                errorMessage: 'Error',
              ),
            ],
          );

          expect(result.hasErrors, isTrue);
        });

        test('should return false when errors list is empty', () {
          final result = ImportResult(
            totalRows: 5,
            imported: 5,
            skipped: 0,
            errors: [],
          );

          expect(result.hasErrors, isFalse);
        });

        test('should return true for multiple errors', () {
          final result = ImportResult(
            totalRows: 10,
            imported: 5,
            skipped: 2,
            errors: List.generate(3, (i) => ImportRowError(
              rowNumber: i + 1,
              rowData: 'data',
              errorMessage: 'Error',
            )),
          );

          expect(result.hasErrors, isTrue);
          expect(result.errors, hasLength(3));
        });
      });

      group('isFullySuccessful', () {
        test('should return true when all rows imported and no errors', () {
          final result = ImportResult(
            totalRows: 10,
            imported: 10,
            skipped: 0,
            errors: [],
          );

          expect(result.isFullySuccessful, isTrue);
        });

        test('should return false when some rows skipped', () {
          final result = ImportResult(
            totalRows: 10,
            imported: 8,
            skipped: 2,
            errors: [],
          );

          expect(result.isFullySuccessful, isFalse);
        });

        test('should return false when there are errors', () {
          final result = ImportResult(
            totalRows: 10,
            imported: 10,
            skipped: 0,
            errors: [
              ImportRowError(
                rowNumber: 5,
                rowData: 'data',
                errorMessage: 'Warning',
              ),
            ],
          );

          expect(result.isFullySuccessful, isFalse);
        });

        test('should return false when both skipped and errors', () {
          final result = ImportResult(
            totalRows: 10,
            imported: 7,
            skipped: 2,
            errors: [
              ImportRowError(
                rowNumber: 1,
                rowData: 'data',
                errorMessage: 'Error',
              ),
            ],
          );

          expect(result.isFullySuccessful, isFalse);
        });

        test('should return true for empty file', () {
          final result = ImportResult(
            totalRows: 0,
            imported: 0,
            skipped: 0,
            errors: [],
          );

          expect(result.isFullySuccessful, isTrue);
        });
      });

      group('hasCategoriesCreated', () {
        test('should return true when categoriesCreated > 0', () {
          final result = ImportResult(
            totalRows: 10,
            imported: 10,
            skipped: 0,
            errors: [],
            categoriesCreated: 3,
          );

          expect(result.hasCategoriesCreated, isTrue);
        });

        test('should return false when categoriesCreated is 0', () {
          final result = ImportResult(
            totalRows: 10,
            imported: 10,
            skipped: 0,
            errors: [],
            categoriesCreated: 0,
          );

          expect(result.hasCategoriesCreated, isFalse);
        });

        test('should return false when using default', () {
          final result = ImportResult(
            totalRows: 10,
            imported: 10,
            skipped: 0,
            errors: [],
          );

          expect(result.hasCategoriesCreated, isFalse);
        });
      });
    });

    group('Real-world scenarios', () {
      test('should handle successful import with new categories', () {
        final result = ImportResult(
          totalRows: 15,
          imported: 15,
          skipped: 0,
          errors: [],
          categoriesCreated: 2,
        );

        expect(result.isFullySuccessful, isTrue);
        expect(result.hasErrors, isFalse);
        expect(result.hasCategoriesCreated, isTrue);
      });

      test('should handle partial success with duplicates skipped', () {
        final result = ImportResult(
          totalRows: 20,
          imported: 15,
          skipped: 5,
          errors: [],
        );

        expect(result.isFullySuccessful, isFalse);
        expect(result.hasErrors, isFalse);
        expect(result.imported + result.skipped, equals(result.totalRows));
      });

      test('should handle import with validation errors', () {
        final result = ImportResult(
          totalRows: 10,
          imported: 7,
          skipped: 1,
          errors: [
            ImportRowError(
              rowNumber: 3,
              rowData: 'invalid,data',
              errorMessage: 'Invalid date format',
            ),
            ImportRowError(
              rowNumber: 8,
              rowData: 'bad,amount',
              errorMessage: 'Invalid amount',
            ),
          ],
        );

        expect(result.hasErrors, isTrue);
        expect(result.isFullySuccessful, isFalse);
        expect(result.imported, equals(7));
      });

      test('should handle failed import with many errors', () {
        final result = ImportResult(
          totalRows: 10,
          imported: 2,
          skipped: 0,
          errors: List.generate(8, (i) => ImportRowError(
            rowNumber: i + 3,
            rowData: 'error,data',
            errorMessage: 'Validation failed',
          )),
        );

        expect(result.hasErrors, isTrue);
        expect(result.errors, hasLength(8));
      });
    });
  });

  group('ImportRowError', () {
    group('Creation', () {
      test('should create with all fields', () {
        final error = ImportRowError(
          rowNumber: 5,
          rowData: '2024-03-15,Pemasukan,Gaji,10000000',
          errorMessage: 'Invalid category',
        );

        expect(error.rowNumber, equals(5));
        expect(error.rowData, equals('2024-03-15,Pemasukan,Gaji,10000000'));
        expect(error.errorMessage, equals('Invalid category'));
      });

      test('should handle long row data', () {
        final longData = 'a' * 1000;
        final error = ImportRowError(
          rowNumber: 1,
          rowData: longData,
          errorMessage: 'Too long',
        );

        expect(error.rowData.length, equals(1000));
      });

      test('should handle empty row data', () {
        final error = ImportRowError(
          rowNumber: 3,
          rowData: '',
          errorMessage: 'Empty row',
        );

        expect(error.rowData, isEmpty);
      });

      test('should handle special characters in error message', () {
        final error = ImportRowError(
          rowNumber: 10,
          rowData: 'data,with,commas',
          errorMessage: 'Error: field "amount" contains invalid character "."',
        );

        expect(error.errorMessage, contains('.'));
        expect(error.errorMessage, contains('"'));
      });
    });

    group('Immutability', () {
      test('should have immutable fields', () {
        // ImportRowError is a simple class with final fields
        final error = ImportRowError(
          rowNumber: 5,
          rowData: 'data',
          errorMessage: 'error',
        );

        // Cannot modify final fields - this is compile-time enforced
        expect(error.rowNumber, equals(5));
      });
    });
  });

  group('ParsedCsvRow', () {
    group('Creation', () {
      test('should create with all fields including time', () {
        final row = ParsedCsvRow(
          rowNumber: 2,
          date: '15/03/2024',
          time: '14:30',
          type: 'Pemasukan',
          category: 'Gaji',
          amount: '10000000',
          note: 'Gaji bulanan',
        );

        expect(row.rowNumber, equals(2));
        expect(row.date, equals('15/03/2024'));
        expect(row.time, equals('14:30'));
        expect(row.type, equals('Pemasukan'));
        expect(row.category, equals('Gaji'));
        expect(row.amount, equals('10000000'));
        expect(row.note, equals('Gaji bulanan'));
      });

      test('should create with default empty time', () {
        final row = ParsedCsvRow(
          rowNumber: 1,
          date: '15/03/2024',
          type: 'Pengeluaran',
          category: 'Makan',
          amount: '50000',
          note: '',
        );

        expect(row.time, isEmpty);
      });

      test('should handle all empty strings', () {
        final row = ParsedCsvRow(
          rowNumber: 5,
          date: '',
          type: '',
          category: '',
          amount: '',
          note: '',
        );

        expect(row.rowNumber, equals(5));
        expect(row.date, isEmpty);
        expect(row.type, isEmpty);
        expect(row.category, isEmpty);
        expect(row.amount, isEmpty);
        expect(row.note, isEmpty);
      });

      test('should handle long note', () {
        final longNote = 'Lorem ipsum ' * 50;
        final row = ParsedCsvRow(
          rowNumber: 1,
          date: '15/03/2024',
          type: 'Pemasukan',
          category: 'Bonus',
          amount: '5000000',
          note: longNote,
        );

        expect(row.note.length, greaterThan(500));
      });

      test('should handle amount with thousand separators', () {
        final row = ParsedCsvRow(
          rowNumber: 1,
          date: '15/03/2024',
          type: 'Pengeluaran',
          category: 'Belanja',
          amount: '1.500.000',
          note: 'Belanja bulanan',
        );

        expect(row.amount, equals('1.500.000'));
      });
    });

    group('Real-world scenarios', () {
      test('should parse standard Indonesian CSV format', () {
        final row = ParsedCsvRow(
          rowNumber: 2,
          date: '15/03/2024',
          time: '',
          type: 'Pengeluaran',
          category: 'Makan',
          amount: '75000',
          note: 'Makan siang',
        );

        expect(row.rowNumber, equals(2));
        expect(row.type, equals('Pengeluaran'));
        expect(row.category, equals('Makan'));
      });

      test('should parse with time field (new format)', () {
        final row = ParsedCsvRow(
          rowNumber: 10,
          date: '15/03/2024',
          time: '08:30',
          type: 'Pengeluaran',
          category: 'Transport',
          amount: '25000',
          note: 'Gojek',
        );

        expect(row.time, equals('08:30'));
      });

      test('should parse income transaction', () {
        final row = ParsedCsvRow(
          rowNumber: 1,
          date: '01/03/2024',
          time: '',
          type: 'Pemasukan',
          category: 'Gaji',
          amount: '15.000.000',
          note: 'Gaji bulan Maret',
        );

        expect(row.type, equals('Pemasukan'));
        expect(row.amount, equals('15.000.000'));
      });
    });
  });

  group('Integration scenarios', () {
    test('should represent complete import workflow', () {
      // Simulate parsing CSV with errors
      final parsedRows = [
        ParsedCsvRow(
          rowNumber: 1,
          date: '15/03/2024',
          type: 'Pengeluaran',
          category: 'Makan',
          amount: '50000',
          note: '',
        ),
        ParsedCsvRow(
          rowNumber: 2,
          date: 'invalid-date',
          type: 'Pengeluaran',
          category: 'Makan',
          amount: '75000',
          note: '',
        ),
        ParsedCsvRow(
          rowNumber: 3,
          date: '16/03/2024',
          type: 'Pengeluaran',
          category: 'Transport',
          amount: 'invalid-amount',
          note: '',
        ),
      ];

      // Create import result with errors
      final result = ImportResult(
        totalRows: parsedRows.length,
        imported: 1,
        skipped: 0,
        errors: [
          ImportRowError(
            rowNumber: 2,
            rowData: 'invalid-date,Pengeluaran,Makan,75000,',
            errorMessage: 'Invalid date format',
          ),
          ImportRowError(
            rowNumber: 3,
            rowData: '16/03/2024,Pengeluaran,Transport,invalid-amount,',
            errorMessage: 'Invalid amount format',
          ),
        ],
      );

      expect(result.totalRows, equals(3));
      expect(result.imported, equals(1));
      expect(result.hasErrors, isTrue);
      expect(result.errors, hasLength(2));
    });
  });
}
