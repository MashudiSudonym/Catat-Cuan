import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/models/transaction_model.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionModel', () {
    group('fromMap', () {
      test('should create model from complete database map', () {
        // Arrange
        final map = {
          TransactionFields.id: 1,
          TransactionFields.amount: 25000.0,
          TransactionFields.type: 'expense',
          TransactionFields.dateTime: '2026-03-18T14:30:00.000Z',
          TransactionFields.categoryId: 1,
          TransactionFields.note: 'Makan siang',
          TransactionFields.createdAt: '2026-03-18T14:30:00.000Z',
          TransactionFields.updatedAt: '2026-03-18T14:30:00.000Z',
        };

        // Act
        final model = TransactionModel.fromMap(map);

        // Assert
        expect(model.id, 1);
        expect(model.amount, 25000.0);
        expect(model.type, 'expense');
        expect(model.dateTime, '2026-03-18T14:30:00.000Z');
        expect(model.categoryId, 1);
        expect(model.note, 'Makan siang');
        expect(model.createdAt, '2026-03-18T14:30:00.000Z');
        expect(model.updatedAt, '2026-03-18T14:30:00.000Z');
      });

      test('should convert amount from num to double correctly', () {
        // Arrange - Amount as int (SQLite stores numbers as INTEGER or REAL)
        final mapWithInt = {
          TransactionFields.amount: 50000, // int instead of double
          TransactionFields.type: 'expense',
          TransactionFields.dateTime: '2026-03-18T14:30:00.000Z',
          TransactionFields.categoryId: 2,
          TransactionFields.createdAt: '2026-03-18T14:30:00.000Z',
          TransactionFields.updatedAt: '2026-03-18T14:30:00.000Z',
        };

        // Act
        final model = TransactionModel.fromMap(mapWithInt);

        // Assert
        expect(model.amount, 50000.0); // int → double
        expect(model.amount, isA<double>());
      });

      test('should use default values for missing nullable fields', () {
        // Arrange - Map with only required fields
        final map = {
          TransactionFields.amount: 100000.0,
          TransactionFields.type: 'income',
          TransactionFields.dateTime: '2026-03-18T14:30:00.000Z',
          TransactionFields.categoryId: 3,
          TransactionFields.createdAt: '2026-03-18T14:30:00.000Z',
          TransactionFields.updatedAt: '2026-03-18T14:30:00.000Z',
        };

        // Act
        final model = TransactionModel.fromMap(map);

        // Assert
        expect(model.id, isNull); // Nullable, no default
        expect(model.note, isNull); // Nullable, no default
        expect(model.amount, 100000.0);
        expect(model.type, 'income');
      });

      test('should use fallback default for amount when null', () {
        // Arrange - Amount is null
        final map = {
          TransactionFields.amount: null,
          TransactionFields.type: 'expense',
          TransactionFields.dateTime: '2026-03-18T14:30:00.000Z',
          TransactionFields.categoryId: 1,
          TransactionFields.createdAt: '2026-03-18T14:30:00.000Z',
          TransactionFields.updatedAt: '2026-03-18T14:30:00.000Z',
        };

        // Act
        final model = TransactionModel.fromMap(map);

        // Assert
        expect(model.amount, 0.0); // Fallback to 0.0
      });
    });

    group('toMap', () {
      test('should convert to map for database insert/update', () {
        // Arrange
        final model = TransactionModel(
          id: 1,
          amount: 25000.0,
          type: 'expense',
          dateTime: '2026-03-18T14:30:00.000Z',
          categoryId: 1,
          note: 'Makan siang',
          createdAt: '2026-03-18T14:30:00.000Z',
          updatedAt: '2026-03-18T14:30:00.000Z',
        );

        // Act
        final map = model.toMap();

        // Assert
        expect(map[TransactionFields.id], 1);
        expect(map[TransactionFields.amount], 25000.0);
        expect(map[TransactionFields.type], 'expense');
        expect(map[TransactionFields.dateTime], '2026-03-18T14:30:00.000Z');
        expect(map[TransactionFields.categoryId], 1);
        expect(map[TransactionFields.note], 'Makan siang');
        expect(map[TransactionFields.createdAt], '2026-03-18T14:30:00.000Z');
        expect(map[TransactionFields.updatedAt], '2026-03-18T14:30:00.000Z');
      });

      test('should exclude id from map when id is null', () {
        // Arrange - New transaction without ID
        final model = TransactionModel(
          amount: 50000.0,
          type: 'expense',
          dateTime: '2026-03-18T14:30:00.000Z',
          categoryId: 2,
          note: 'Bensin',
          createdAt: '2026-03-18T14:30:00.000Z',
          updatedAt: '2026-03-18T14:30:00.000Z',
        );

        // Act
        final map = model.toMap();

        // Assert
        expect(map.containsKey(TransactionFields.id), isFalse);
        expect(map[TransactionFields.amount], 50000.0);
      });

      test('should include null note in map for database NULL value', () {
        // Arrange - Transaction without note
        final model = TransactionModel(
          id: 1,
          amount: 100000.0,
          type: 'income',
          dateTime: '2026-03-18T14:30:00.000Z',
          categoryId: 3,
          note: null,
          createdAt: '2026-03-18T14:30:00.000Z',
          updatedAt: '2026-03-18T14:30:00.000Z',
        );

        // Act
        final map = model.toMap();

        // Assert - note is included with null value for database NULL
        expect(map.containsKey(TransactionFields.note), isTrue);
        expect(map[TransactionFields.note], isNull);
      });
    });

    group('toEntity', () {
      test('should convert to TransactionEntity with correct type conversions', () {
        // Arrange
        final model = TransactionModel(
          id: 1,
          amount: 25000.0,
          type: 'expense',
          dateTime: '2026-03-18T14:30:00.000Z', // String → DateTime
          categoryId: 1,
          note: 'Makan siang',
          createdAt: '2026-03-18T14:30:00.000Z', // String → DateTime
          updatedAt: '2026-03-18T14:30:00.000Z',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.id, 1);
        expect(entity.amount, 25000.0);
        expect(entity.type, TransactionType.expense); // String → TransactionType
        expect(entity.dateTime, DateTime.parse('2026-03-18T14:30:00.000Z'));
        expect(entity.categoryId, 1);
        expect(entity.note, 'Makan siang');
        expect(entity.createdAt, DateTime.parse('2026-03-18T14:30:00.000Z'));
        expect(entity.updatedAt, DateTime.parse('2026-03-18T14:30:00.000Z'));
      });

      test('should convert type string to TransactionType correctly', () {
        // Test expense type
        final expenseModel = TransactionModel(
          id: 1,
          amount: 25000.0,
          type: 'expense',
          dateTime: '2026-03-18T14:30:00.000Z',
          categoryId: 1,
          createdAt: '2026-03-18T14:30:00.000Z',
          updatedAt: '2026-03-18T14:30:00.000Z',
        );

        final expenseEntity = expenseModel.toEntity();
        expect(expenseEntity.type, TransactionType.expense);

        // Test income type
        final incomeModel = TransactionModel(
          id: 2,
          amount: 5000000.0,
          type: 'income',
          dateTime: '2026-03-18T14:30:00.000Z',
          categoryId: 3,
          createdAt: '2026-03-18T14:30:00.000Z',
          updatedAt: '2026-03-18T14:30:00.000Z',
        );

        final incomeEntity = incomeModel.toEntity();
        expect(incomeEntity.type, TransactionType.income);
      });

      test('should handle null note when converting to entity', () {
        // Arrange
        final model = TransactionModel(
          id: 1,
          amount: 50000.0,
          type: 'expense',
          dateTime: '2026-03-18T14:30:00.000Z',
          categoryId: 2,
          note: null,
          createdAt: '2026-03-18T14:30:00.000Z',
          updatedAt: '2026-03-18T14:30:00.000Z',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.note, isNull);
      });
    });

    group('fromEntity', () {
      test('should convert from TransactionEntity to TransactionModel', () {
        // Arrange
        final entity = TransactionEntity(
          id: 1,
          amount: 25000.0,
          type: TransactionType.expense,
          dateTime: DateTime.parse('2026-03-18T14:30:00.000Z'),
          categoryId: 1,
          note: 'Makan siang',
          createdAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
          updatedAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
        );

        // Act
        final model = TransactionModel.fromEntity(entity);

        // Assert
        expect(model.id, 1);
        expect(model.amount, 25000.0);
        expect(model.type, 'expense'); // TransactionType → String
        expect(model.dateTime, '2026-03-18T14:30:00.000Z'); // DateTime → String
        expect(model.categoryId, 1);
        expect(model.note, 'Makan siang');
        expect(model.createdAt, '2026-03-18T14:30:00.000Z'); // DateTime → String
        expect(model.updatedAt, '2026-03-18T14:30:00.000Z');
      });

      test('should handle null note when converting from entity', () {
        // Arrange
        final entity = TransactionEntity(
          id: 1,
          amount: 50000.0,
          type: TransactionType.expense,
          dateTime: DateTime.parse('2026-03-18T14:30:00.000Z'),
          categoryId: 2,
          note: null,
          createdAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
          updatedAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
        );

        // Act
        final model = TransactionModel.fromEntity(entity);

        // Assert
        expect(model.note, isNull);
      });

      test('should convert both income and expense types to string', () {
        // Test income
        final incomeEntity = TransactionEntity(
          id: 1,
          amount: 5000000.0,
          type: TransactionType.income,
          dateTime: DateTime.parse('2026-03-18T14:30:00.000Z'),
          categoryId: 3,
          createdAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
          updatedAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
        );

        final incomeModel = TransactionModel.fromEntity(incomeEntity);
        expect(incomeModel.type, 'income');

        // Test expense
        final expenseEntity = TransactionEntity(
          id: 2,
          amount: 25000.0,
          type: TransactionType.expense,
          dateTime: DateTime.parse('2026-03-18T14:30:00.000Z'),
          categoryId: 1,
          createdAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
          updatedAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
        );

        final expenseModel = TransactionModel.fromEntity(expenseEntity);
        expect(expenseModel.type, 'expense');
      });
    });

    group('Round-trip conversions', () {
      test('should maintain data integrity through fromMap→toEntity→fromEntity→toMap', () {
        // Arrange - Original database map
        final originalMap = {
          TransactionFields.id: 1,
          TransactionFields.amount: 25000.0,
          TransactionFields.type: 'expense',
          TransactionFields.dateTime: '2026-03-18T14:30:00.000Z',
          TransactionFields.categoryId: 1,
          TransactionFields.note: 'Makan siang',
          TransactionFields.createdAt: '2026-03-18T14:30:00.000Z',
          TransactionFields.updatedAt: '2026-03-18T14:30:00.000Z',
        };

        // Act - Full round-trip conversion
        final model = TransactionModel.fromMap(originalMap);
        final entity = model.toEntity();
        final backToModel = TransactionModel.fromEntity(entity);
        final finalMap = backToModel.toMap();

        // Assert - All fields should match
        expect(finalMap[TransactionFields.id], originalMap[TransactionFields.id]);
        expect(finalMap[TransactionFields.amount], originalMap[TransactionFields.amount]);
        expect(finalMap[TransactionFields.type], originalMap[TransactionFields.type]);
        expect(
          finalMap[TransactionFields.dateTime],
          originalMap[TransactionFields.dateTime],
        );
        expect(
          finalMap[TransactionFields.categoryId],
          originalMap[TransactionFields.categoryId],
        );
        expect(finalMap[TransactionFields.note], originalMap[TransactionFields.note]);
      });

      test('should handle null id through round-trip conversion', () {
        // Arrange - New transaction (id is null)
        final originalMap = {
          TransactionFields.amount: 50000.0,
          TransactionFields.type: 'expense',
          TransactionFields.dateTime: '2026-03-18T14:30:00.000Z',
          TransactionFields.categoryId: 2,
          TransactionFields.note: 'Bensin',
          TransactionFields.createdAt: '2026-03-18T14:30:00.000Z',
          TransactionFields.updatedAt: '2026-03-18T14:30:00.000Z',
        };

        // Act
        final model = TransactionModel.fromMap(originalMap);
        final entity = model.toEntity();
        final backToModel = TransactionModel.fromEntity(entity);
        final finalMap = backToModel.toMap();

        // Assert - id should not be in the map (null values are excluded)
        expect(finalMap.containsKey(TransactionFields.id), isFalse);
        expect(finalMap[TransactionFields.amount], 50000.0);
      });
    });
  });
}
