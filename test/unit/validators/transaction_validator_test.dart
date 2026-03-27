import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/validators/transaction_validator.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  group('TransactionValidator', () {
    group('validate - general validation', () {
      test('should pass for valid transaction without ID', () {
        final transaction = TestFixtures.transactionLunch();

        final result = TransactionValidator.validate(transaction);

        expect(result.isValid, isTrue);
        expect(result.error, isNull);
      });

      test('should pass for valid transaction with ID', () {
        final transaction = TestFixtures.transactionLunch();

        final result = TransactionValidator.validate(transaction, requireId: false);

        expect(result.isValid, isTrue);
        expect(result.error, isNull);
      });

      test('should fail when amount is zero', () {
        final transaction = TestFixtures.transactionLunch(amount: 0);

        final result = TransactionValidator.validate(transaction);

        expect(result.isValid, isFalse);
        expect(result.error, equals('Nominal harus lebih dari 0'));
      });

      test('should fail when amount is negative', () {
        final transaction = TestFixtures.transactionLunch(amount: -1000);

        final result = TransactionValidator.validate(transaction);

        expect(result.isValid, isFalse);
        expect(result.error, equals('Nominal harus lebih dari 0'));
      });

      test('should fail when categoryId is zero', () {
        final transaction = TestFixtures.transactionLunch(categoryId: 0);

        final result = TransactionValidator.validate(transaction);

        expect(result.isValid, isFalse);
        expect(result.error, equals('Kategori wajib dipilih'));
      });

      test('should fail when categoryId is negative', () {
        final transaction = TestFixtures.transactionLunch(categoryId: -1);

        final result = TransactionValidator.validate(transaction);

        expect(result.isValid, isFalse);
        expect(result.error, equals('Kategori wajib dipilih'));
      });

      test('should pass for income transaction', () {
        final transaction = TestFixtures.transactionSalary();

        final result = TransactionValidator.validate(transaction);

        expect(result.isValid, isTrue);
        expect(result.error, isNull);
      });

      test('should pass for expense transaction', () {
        final transaction = TestFixtures.transactionTransport();

        final result = TransactionValidator.validate(transaction);

        expect(result.isValid, isTrue);
        expect(result.error, isNull);
      });
    });

    group('validate - with requireId', () {
      test('should fail when ID is required but not present', () {
        final transaction = TestFixtures.transactionLunch().copyWith(id: null);

        final result = TransactionValidator.validate(transaction, requireId: true);

        expect(result.isValid, isFalse);
        expect(result.error, equals('ID transaksi wajib ada untuk update'));
      });

      test('should pass when ID is required and present', () {
        final transaction = TestFixtures.transactionLunch();

        final result = TransactionValidator.validate(transaction, requireId: true);

        expect(result.isValid, isTrue);
        expect(result.error, isNull);
      });

      test('should not check ID when requireId is false', () {
        final transaction = TestFixtures.transactionLunch().copyWith(id: null);

        final result = TransactionValidator.validate(transaction, requireId: false);

        expect(result.isValid, isTrue);
        expect(result.error, isNull);
      });
    });

    group('validateForCreation', () {
      test('should pass for valid transaction without ID', () {
        final transaction = TestFixtures.transactionLunch().copyWith(id: null);

        final result = TransactionValidator.validateForCreation(transaction);

        expect(result.isValid, isTrue);
        expect(result.error, isNull);
      });

      test('should pass for valid transaction with ID', () {
        final transaction = TestFixtures.transactionLunch();

        final result = TransactionValidator.validateForCreation(transaction);

        expect(result.isValid, isTrue);
        expect(result.error, isNull);
      });

      test('should fail for transaction with zero amount', () {
        final transaction = TestFixtures.transactionLunch(amount: 0);

        final result = TransactionValidator.validateForCreation(transaction);

        expect(result.isValid, isFalse);
        expect(result.error, equals('Nominal harus lebih dari 0'));
      });

      test('should fail for transaction with invalid category', () {
        final transaction = TestFixtures.transactionLunch(categoryId: 0);

        final result = TransactionValidator.validateForCreation(transaction);

        expect(result.isValid, isFalse);
        expect(result.error, equals('Kategori wajib dipilih'));
      });
    });

    group('validateForUpdate', () {
      test('should pass for valid transaction with ID', () {
        final transaction = TestFixtures.transactionLunch();

        final result = TransactionValidator.validateForUpdate(transaction);

        expect(result.isValid, isTrue);
        expect(result.error, isNull);
      });

      test('should fail when transaction has no ID', () {
        final transaction = TestFixtures.transactionLunch().copyWith(id: null);

        final result = TransactionValidator.validateForUpdate(transaction);

        expect(result.isValid, isFalse);
        expect(result.error, equals('ID transaksi wajib ada untuk update'));
      });

      test('should fail when transaction has invalid amount even with ID', () {
        final transaction = TestFixtures.transactionLunch(amount: 0);

        final result = TransactionValidator.validateForUpdate(transaction);

        expect(result.isValid, isFalse);
        expect(result.error, equals('Nominal harus lebih dari 0'));
      });

      test('should fail when transaction has invalid category even with ID', () {
        final transaction = TestFixtures.transactionLunch(categoryId: 0);

        final result = TransactionValidator.validateForUpdate(transaction);

        expect(result.isValid, isFalse);
        expect(result.error, equals('Kategori wajib dipilih'));
      });
    });

    group('validateAmount', () {
      test('should return null for positive amount', () {
        final result = TransactionValidator.validateAmount(1000);

        expect(result, isNull);
      });

      test('should return null for large positive amount', () {
        final result = TransactionValidator.validateAmount(999999999);

        expect(result, isNull);
      });

      test('should return error for zero amount', () {
        final result = TransactionValidator.validateAmount(0);

        expect(result, equals('Nominal harus lebih dari 0'));
      });

      test('should return error for negative amount', () {
        final result = TransactionValidator.validateAmount(-100);

        expect(result, equals('Nominal harus lebih dari 0'));
      });

      test('should return error for very small negative amount', () {
        final result = TransactionValidator.validateAmount(-0.01);

        expect(result, equals('Nominal harus lebih dari 0'));
      });
    });

    group('validateCategoryId', () {
      test('should return null for valid category ID', () {
        final result = TransactionValidator.validateCategoryId(1);

        expect(result, isNull);
      });

      test('should return null for large category ID', () {
        final result = TransactionValidator.validateCategoryId(9999);

        expect(result, isNull);
      });

      test('should return error for zero category ID', () {
        final result = TransactionValidator.validateCategoryId(0);

        expect(result, equals('Kategori wajib dipilih'));
      });

      test('should return error for negative category ID', () {
        final result = TransactionValidator.validateCategoryId(-1);

        expect(result, equals('Kategori wajib dipilih'));
      });

      test('should return error for very negative category ID', () {
        final result = TransactionValidator.validateCategoryId(-999);

        expect(result, equals('Kategori wajib dipilih'));
      });
    });

    group('validateNote', () {
      test('should return null for null note', () {
        final result = TransactionValidator.validateNote(null);

        expect(result, isNull);
      });

      test('should return null for empty note', () {
        final result = TransactionValidator.validateNote('');

        expect(result, isNull);
      });

      test('should return null for short note', () {
        final result = TransactionValidator.validateNote('Makan siang');

        expect(result, isNull);
      });

      test('should return null for note exactly at limit (500 chars)', () {
        final note = 'A' * 500;
        final result = TransactionValidator.validateNote(note);

        expect(result, isNull);
      });

      test('should return null for long but valid note (499 chars)', () {
        final note = 'A' * 499;
        final result = TransactionValidator.validateNote(note);

        expect(result, isNull);
      });

      test('should return error for note exceeding limit (501 chars)', () {
        final note = 'A' * 501;
        final result = TransactionValidator.validateNote(note);

        expect(result, equals('Catatan tidak boleh lebih dari 500 karakter'));
      });

      test('should return error for very long note (1000 chars)', () {
        final note = 'A' * 1000;
        final result = TransactionValidator.validateNote(note);

        expect(result, equals('Catatan tidak boleh lebih dari 500 karakter'));
      });

      test('should return null for note with special characters', () {
        final note = 'Makan siang @ restoran • harga Rp 25.000';
        final result = TransactionValidator.validateNote(note);

        expect(result, isNull);
      });

      test('should return null for note with emoji', () {
        final note = 'Makan siang 🍽️ enak sekali';
        final result = TransactionValidator.validateNote(note);

        expect(result, isNull);
      });

      test('should return null for note with newlines', () {
        final note = 'Makan siang\n dengan teman\n di restoran';
        final result = TransactionValidator.validateNote(note);

        expect(result, isNull);
      });
    });

    group('ValidationResult', () {
      test('success should create valid result', () {
        final result = ValidationResult.success();

        expect(result.isValid, isTrue);
        expect(result.error, isNull);
        expect(result.toString(), equals('ValidationResult.success()'));
      });

      test('error should create invalid result with message', () {
        final result = ValidationResult.error('Test error');

        expect(result.isValid, isFalse);
        expect(result.error, equals('Test error'));
        expect(result.toString(), equals('ValidationResult.error(Test error)'));
      });

      test('should handle multiple validation failures', () {
        final transaction = TestFixtures.transactionLunch(
          amount: 0,
          categoryId: 0,
        );

        final result = TransactionValidator.validate(transaction);

        // Should fail on amount validation first (checked before category)
        expect(result.isValid, isFalse);
        expect(result.error, equals('Nominal harus lebih dari 0'));
      });
    });

    group('Real-world validation scenarios', () {
      test('should validate typical lunch expense', () {
        final transaction = TestFixtures.transactionLunch(
          note: 'Makan nasi padang',
        );

        final result = TransactionValidator.validateForCreation(transaction);

        expect(result.isValid, isTrue);
      });

      test('should validate monthly salary income', () {
        final transaction = TestFixtures.transactionSalary(
          note: 'Gaji bulan Maret',
        );

        final result = TransactionValidator.validateForCreation(transaction);

        expect(result.isValid, isTrue);
      });

      test('should validate transport expense', () {
        final transaction = TestFixtures.transactionTransport(
          note: 'Bensin motor',
        );

        final result = TransactionValidator.validateForCreation(transaction);

        expect(result.isValid, isTrue);
      });

      test('should reject transaction with minimal invalid data', () {
        final transaction = TransactionEntity(
          id: null,
          amount: 0,
          type: TransactionType.expense,
          dateTime: DateTime.now(),
          categoryId: 0,
          note: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = TransactionValidator.validateForCreation(transaction);

        expect(result.isValid, isFalse);
      });

      test('should accept transaction with maximum valid note', () {
        final transaction = TestFixtures.transactionLunch(
          note: 'A' * 500,
        );

        final result = TransactionValidator.validateForCreation(transaction);
        final noteResult = TransactionValidator.validateNote(transaction.note);

        expect(result.isValid, isTrue);
        expect(noteResult, isNull);
      });

      test('should reject transaction with excessive note (when note is validated separately)', () {
        final transaction = TestFixtures.transactionLunch(
          note: 'A' * 501,
        );

        // validateForCreation doesn't check note length - validateNote must be called separately
        final result = TransactionValidator.validateForCreation(transaction);
        final noteResult = TransactionValidator.validateNote(transaction.note);

        expect(result.isValid, isTrue); // Main validation passes
        expect(noteResult, equals('Catatan tidak boleh lebih dari 500 karakter')); // Note validation fails
      });
    });
  });
}
