import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/data/models/transaction_model.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';

void main() {
  group('TransactionModel', () {
    // Test data
    final now = DateTime.now();
    final testMap = {
      TransactionFields.id: 1,
      TransactionFields.amount: 100000.0,
      TransactionFields.type: 'expense',
      TransactionFields.dateTime: now.toIso8601String(),
      TransactionFields.categoryId: 2,
      TransactionFields.note: 'Test transaction',
      TransactionFields.createdAt: now.toIso8601String(),
      TransactionFields.updatedAt: now.toIso8601String(),
    };

    final testEntity = TransactionEntity(
      id: 1,
      amount: 100000.0,
      type: TransactionType.expense,
      dateTime: now,
      categoryId: 2,
      note: 'Test transaction',
      createdAt: now,
      updatedAt: now,
    );

    group('fromMap', () {
      test('should create TransactionModel from Map correctly', () {
        // Act
        final model = TransactionModel.fromMap(testMap);

        // Assert
        expect(model.id, 1);
        expect(model.amount, 100000.0);
        expect(model.type, 'expense');
        expect(model.dateTime, now.toIso8601String());
        expect(model.categoryId, 2);
        expect(model.note, 'Test transaction');
        expect(model.createdAt, now.toIso8601String());
        expect(model.updatedAt, now.toIso8601String());
      });

      test('should handle nullable id field', () {
        // Arrange
        final mapWithoutId = Map<String, dynamic>.from(testMap);
        mapWithoutId.remove(TransactionFields.id);

        // Act
        final model = TransactionModel.fromMap(mapWithoutId);

        // Assert
        expect(model.id, isNull);
      });

      test('should handle nullable note field', () {
        // Arrange
        final mapWithoutNote = Map<String, dynamic>.from(testMap);
        mapWithoutNote[TransactionFields.note] = null;

        // Act
        final model = TransactionModel.fromMap(mapWithoutNote);

        // Assert
        expect(model.note, isNull);
      });

      test('should convert amount from int to double', () {
        // Arrange
        final mapWithIntAmount = Map<String, dynamic>.from(testMap);
        mapWithIntAmount[TransactionFields.amount] = 100000;

        // Act
        final model = TransactionModel.fromMap(mapWithIntAmount);

        // Assert
        expect(model.amount, 100000.0);
        expect(model.amount, isA<double>());
      });
    });

    group('toMap', () {
      test('should convert TransactionModel to Map correctly with id', () {
        // Arrange
        final model = TransactionModel(
          id: 1,
          amount: 100000.0,
          type: 'expense',
          dateTime: now.toIso8601String(),
          categoryId: 2,
          note: 'Test transaction',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final map = model.toMap();

        // Assert
        expect(map[TransactionFields.id], 1);
        expect(map[TransactionFields.amount], 100000.0);
        expect(map[TransactionFields.type], 'expense');
        expect(map[TransactionFields.dateTime], now.toIso8601String());
        expect(map[TransactionFields.categoryId], 2);
        expect(map[TransactionFields.note], 'Test transaction');
        expect(map[TransactionFields.createdAt], now.toIso8601String());
        expect(map[TransactionFields.updatedAt], now.toIso8601String());
      });

      test('should convert TransactionModel to Map correctly without id', () {
        // Arrange
        final model = TransactionModel(
          amount: 100000.0,
          type: 'expense',
          dateTime: now.toIso8601String(),
          categoryId: 2,
          note: 'Test transaction',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final map = model.toMap();

        // Assert
        expect(map.containsKey(TransactionFields.id), false);
        expect(map[TransactionFields.amount], 100000.0);
        expect(map[TransactionFields.type], 'expense');
      });

      test('should handle null note in toMap', () {
        // Arrange
        final model = TransactionModel(
          id: 1,
          amount: 100000.0,
          type: 'expense',
          dateTime: now.toIso8601String(),
          categoryId: 2,
          note: null,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final map = model.toMap();

        // Assert
        expect(map[TransactionFields.note], isNull);
      });
    });

    group('toEntity', () {
      test('should convert TransactionModel to TransactionEntity correctly', () {
        // Arrange
        final model = TransactionModel(
          id: 1,
          amount: 100000.0,
          type: 'expense',
          dateTime: now.toIso8601String(),
          categoryId: 2,
          note: 'Test transaction',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.id, 1);
        expect(entity.amount, 100000.0);
        expect(entity.type, TransactionType.expense);
        expect(entity.dateTime, now);
        expect(entity.categoryId, 2);
        expect(entity.note, 'Test transaction');
        expect(entity.createdAt, now);
        expect(entity.updatedAt, now);
      });

      test('should convert type "pemasukan" to TransactionType.income', () {
        // Arrange
        final model = TransactionModel(
          id: 1,
          amount: 100000.0,
          type: 'pemasukan',
          dateTime: now.toIso8601String(),
          categoryId: 1,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.type, TransactionType.income);
      });
    });

    group('fromEntity', () {
      test('should convert TransactionEntity to TransactionModel correctly', () {
        // Act
        final model = TransactionModel.fromEntity(testEntity);

        // Assert
        expect(model.id, 1);
        expect(model.amount, 100000.0);
        expect(model.type, 'expense');
        expect(model.dateTime, now.toIso8601String());
        expect(model.categoryId, 2);
        expect(model.note, 'Test transaction');
        expect(model.createdAt, now.toIso8601String());
        expect(model.updatedAt, now.toIso8601String());
      });

      test('should convert TransactionType to string value correctly', () {
        // Arrange
        final incomeEntity = TransactionEntity(
          id: 1,
          amount: 50000.0,
          type: TransactionType.income,
          dateTime: now,
          categoryId: 1,
          createdAt: now,
          updatedAt: now,
        );

        // Act
        final model = TransactionModel.fromEntity(incomeEntity);

        // Assert
        expect(model.type, 'income');
      });

      test('should handle null note in fromEntity', () {
        // Arrange
        final entityWithoutNote = TransactionEntity(
          id: 1,
          amount: 100000.0,
          type: TransactionType.expense,
          dateTime: now,
          categoryId: 2,
          createdAt: now,
          updatedAt: now,
        );

        // Act
        final model = TransactionModel.fromEntity(entityWithoutNote);

        // Assert
        expect(model.note, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated values', () {
        // Arrange
        final model = TransactionModel(
          id: 1,
          amount: 100000.0,
          type: 'expense',
          dateTime: now.toIso8601String(),
          categoryId: 2,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final updated = model.copyWith(amount: 200000.0);

        // Assert
        expect(updated.id, 1);
        expect(updated.amount, 200000.0);
        expect(updated.type, 'expense');
        expect(model.amount, 100000.0); // Original unchanged
      });

      test('should handle null values in copyWith', () {
        // Arrange
        final model = TransactionModel(
          id: 1,
          amount: 100000.0,
          type: 'expense',
          dateTime: now.toIso8601String(),
          categoryId: 2,
          note: 'Test',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final updated = model.copyWith(note: null);

        // Assert
        expect(updated.note, isNull);
        expect(updated.id, 1);
        expect(updated.amount, 100000.0);
      });
    });

    group('Equality', () {
      test('should return true for identical models', () {
        // Arrange
        final model1 = TransactionModel(
          id: 1,
          amount: 100000.0,
          type: 'expense',
          dateTime: now.toIso8601String(),
          categoryId: 2,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );
        final model2 = TransactionModel(
          id: 1,
          amount: 100000.0,
          type: 'expense',
          dateTime: now.toIso8601String(),
          categoryId: 2,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Assert
        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should return false for different models', () {
        // Arrange
        final model1 = TransactionModel(
          id: 1,
          amount: 100000.0,
          type: 'expense',
          dateTime: now.toIso8601String(),
          categoryId: 2,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );
        final model2 = TransactionModel(
          id: 2,
          amount: 200000.0,
          type: 'income',
          dateTime: now.toIso8601String(),
          categoryId: 1,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Assert
        expect(model1, isNot(equals(model2)));
      });
    });

    group('Round-trip conversion', () {
      test('should maintain data integrity through toMap and fromMap', () {
        // Arrange
        final originalModel = TransactionModel(
          id: 1,
          amount: 100000.0,
          type: 'expense',
          dateTime: now.toIso8601String(),
          categoryId: 2,
          note: 'Test transaction',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final map = originalModel.toMap();
        final recreatedModel = TransactionModel.fromMap(map);

        // Assert
        expect(recreatedModel, equals(originalModel));
      });

      test('should maintain data integrity through toEntity and fromEntity', () {
        // Arrange
        final originalModel = TransactionModel(
          id: 1,
          amount: 100000.0,
          type: 'expense',
          dateTime: now.toIso8601String(),
          categoryId: 2,
          note: 'Test transaction',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final entity = originalModel.toEntity();
        final recreatedModel = TransactionModel.fromEntity(entity);

        // Assert
        expect(recreatedModel.id, equals(originalModel.id));
        expect(recreatedModel.amount, equals(originalModel.amount));
        expect(recreatedModel.type, equals(originalModel.type));
        expect(recreatedModel.dateTime, equals(originalModel.dateTime));
        expect(recreatedModel.categoryId, equals(originalModel.categoryId));
        expect(recreatedModel.note, equals(originalModel.note));
        expect(recreatedModel.createdAt, equals(originalModel.createdAt));
        expect(recreatedModel.updatedAt, equals(originalModel.updatedAt));
      });
    });

    group('toString', () {
      test('should return readable string representation', () {
        // Arrange
        final model = TransactionModel(
          id: 1,
          amount: 100000.0,
          type: 'expense',
          dateTime: now.toIso8601String(),
          categoryId: 2,
          note: 'Test',
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final str = model.toString();

        // Assert
        expect(str, contains('TransactionModel'));
        expect(str, contains('id: 1'));
        expect(str, contains('amount: 100000.0'));
        expect(str, contains('type: expense'));
        expect(str, contains('categoryId: 2'));
      });
    });
  });
}
