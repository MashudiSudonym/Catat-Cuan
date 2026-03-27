import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  group('TransactionEntity', () {
    group('Entity creation', () {
      test('should create entity with all required fields', () {
        final now = DateTime.now();
        final entity = TransactionEntity(
          id: 1,
          amount: 50000,
          type: TransactionType.expense,
          dateTime: now,
          categoryId: 2,
          note: 'Test transaction',
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.id, equals(1));
        expect(entity.amount, equals(50000));
        expect(entity.type, equals(TransactionType.expense));
        expect(entity.dateTime, equals(now));
        expect(entity.categoryId, equals(2));
        expect(entity.note, equals('Test transaction'));
      });

      test('should create entity without ID (for new transactions)', () {
        final now = DateTime.now();
        final entity = TransactionEntity(
          id: null,
          amount: 50000,
          type: TransactionType.expense,
          dateTime: now,
          categoryId: 2,
          note: null,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.id, isNull);
        expect(entity.note, isNull);
      });

      test('should create entity with optional note', () {
        final now = DateTime.now();
        final entity = TransactionEntity(
          id: 1,
          amount: 50000,
          type: TransactionType.expense,
          dateTime: now,
          categoryId: 2,
          note: 'Lunch at restaurant',
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.note, equals('Lunch at restaurant'));
      });
    });

    group('Immutability', () {
      test('should be immutable with copyWith', () {
        final now = DateTime.now();
        final entity = TransactionEntity(
          id: 1,
          amount: 50000,
          type: TransactionType.expense,
          dateTime: now,
          categoryId: 2,
          note: 'Original',
          createdAt: now,
          updatedAt: now,
        );

        final updated = entity.copyWith(amount: 75000);

        expect(entity.amount, equals(50000)); // Original unchanged
        expect(updated.amount, equals(75000)); // Copy updated
      });

      test('should copy with ID', () {
        final now = DateTime.now();
        final entity = TransactionEntity(
          id: null,
          amount: 50000,
          type: TransactionType.expense,
          dateTime: now,
          categoryId: 2,
          note: null,
          createdAt: now,
          updatedAt: now,
        );

        final withId = entity.copyWith(id: 1);

        expect(entity.id, isNull);
        expect(withId.id, equals(1));
      });

      test('should copy with note', () {
        final now = DateTime.now();
        final entity = TransactionEntity(
          id: 1,
          amount: 50000,
          type: TransactionType.expense,
          dateTime: now,
          categoryId: 2,
          note: null,
          createdAt: now,
          updatedAt: now,
        );

        final withNote = entity.copyWith(note: 'Added note');

        expect(entity.note, isNull);
        expect(withNote.note, equals('Added note'));
      });
    });

    group('Type validation', () {
      test('should accept income type', () {
        final now = DateTime.now();
        final entity = TransactionEntity(
          id: 1,
          amount: 5000000,
          type: TransactionType.income,
          dateTime: now,
          categoryId: 1,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.type, equals(TransactionType.income));
        expect(entity.type.displayName, equals('Pemasukan'));
      });

      test('should accept expense type', () {
        final now = DateTime.now();
        final entity = TransactionEntity(
          id: 1,
          amount: 50000,
          type: TransactionType.expense,
          dateTime: now,
          categoryId: 2,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.type, equals(TransactionType.expense));
        expect(entity.type.displayName, equals('Pengeluaran'));
      });
    });

    group('Amount validation', () {
      test('should accept positive amount', () {
        final now = DateTime.now();
        final entity = TransactionEntity(
          id: 1,
          amount: 0.01,
          type: TransactionType.expense,
          dateTime: now,
          categoryId: 1,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.amount, equals(0.01));
      });

      test('should accept large amount', () {
        final now = DateTime.now();
        final entity = TransactionEntity(
          id: 1,
          amount: 999999999.99,
          type: TransactionType.income,
          dateTime: now,
          categoryId: 1,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.amount, equals(999999999.99));
      });

      test('should accept zero amount (though validator will reject)', () {
        final now = DateTime.now();
        final entity = TransactionEntity(
          id: 1,
          amount: 0,
          type: TransactionType.expense,
          dateTime: now,
          categoryId: 1,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.amount, equals(0));
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        final now = DateTime.now();
        final entity1 = TransactionEntity(
          id: 1,
          amount: 50000,
          type: TransactionType.expense,
          dateTime: now,
          categoryId: 2,
          note: 'Test',
          createdAt: now,
          updatedAt: now,
        );

        final entity2 = TransactionEntity(
          id: 1,
          amount: 50000,
          type: TransactionType.expense,
          dateTime: now,
          categoryId: 2,
          note: 'Test',
          createdAt: now,
          updatedAt: now,
        );

        expect(entity1, equals(entity2));
      });

      test('should not be equal when ID differs', () {
        final now = DateTime.now();
        final entity1 = TransactionEntity(
          id: 1,
          amount: 50000,
          type: TransactionType.expense,
          dateTime: now,
          categoryId: 2,
          createdAt: now,
          updatedAt: now,
        );

        final entity2 = TransactionEntity(
          id: 2,
          amount: 50000,
          type: TransactionType.expense,
          dateTime: now,
          categoryId: 2,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when amount differs', () {
        final now = DateTime.now();
        final entity1 = TransactionEntity(
          id: 1,
          amount: 50000,
          type: TransactionType.expense,
          dateTime: now,
          categoryId: 2,
          createdAt: now,
          updatedAt: now,
        );

        final entity2 = TransactionEntity(
          id: 1,
          amount: 60000,
          type: TransactionType.expense,
          dateTime: now,
          categoryId: 2,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when type differs', () {
        final now = DateTime.now();
        final entity1 = TransactionEntity(
          id: 1,
          amount: 50000,
          type: TransactionType.expense,
          dateTime: now,
          categoryId: 2,
          createdAt: now,
          updatedAt: now,
        );

        final entity2 = TransactionEntity(
          id: 1,
          amount: 50000,
          type: TransactionType.income,
          dateTime: now,
          categoryId: 2,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity1, isNot(equals(entity2)));
      });
    });

    group('Real-world scenarios', () {
      test('should create lunch expense', () {
        final entity = TestFixtures.transactionLunch();

        expect(entity.amount, equals(25000));
        expect(entity.type, equals(TransactionType.expense));
        expect(entity.note, equals('Makan siang'));
        expect(entity.categoryId, equals(1));
      });

      test('should create transport expense', () {
        final entity = TestFixtures.transactionTransport();

        expect(entity.amount, equals(50000));
        expect(entity.type, equals(TransactionType.expense));
        expect(entity.note, equals('Bensin'));
        expect(entity.categoryId, equals(2));
      });

      test('should create salary income', () {
        final entity = TestFixtures.transactionSalary();

        expect(entity.amount, equals(5000000));
        expect(entity.type, equals(TransactionType.income));
        expect(entity.note, equals('Gaji bulanan'));
        expect(entity.categoryId, equals(3));
      });
    });
  });

  group('TransactionType enum', () {
    group('fromString', () {
      test('should parse income from English', () {
        final type = TransactionType.fromString('income');
        expect(type, equals(TransactionType.income));
      });

      test('should parse expense from English', () {
        final type = TransactionType.fromString('expense');
        expect(type, equals(TransactionType.expense));
      });

      test('should parse income from Indonesian', () {
        final type = TransactionType.fromString('pemasukan');
        expect(type, equals(TransactionType.income));
      });

      test('should parse expense from Indonesian', () {
        final type = TransactionType.fromString('pengeluaran');
        expect(type, equals(TransactionType.expense));
      });

      test('should handle case insensitive', () {
        expect(TransactionType.fromString('INCOME'), equals(TransactionType.income));
        expect(TransactionType.fromString('Income'), equals(TransactionType.income));
        expect(TransactionType.fromString('PEMASUKAN'), equals(TransactionType.income));
      });

      test('should default to expense for invalid value', () {
        final type = TransactionType.fromString('invalid');
        expect(type, equals(TransactionType.expense));
      });
    });

    group('displayName', () {
      test('should return Indonesian display name for income', () {
        expect(TransactionType.income.displayName, equals('Pemasukan'));
      });

      test('should return Indonesian display name for expense', () {
        expect(TransactionType.expense.displayName, equals('Pengeluaran'));
      });
    });

    group('value property', () {
      test('should return lowercase English value for income', () {
        expect(TransactionType.income.value, equals('income'));
      });

      test('should return lowercase English value for expense', () {
        expect(TransactionType.expense.value, equals('expense'));
      });
    });
  });
}
