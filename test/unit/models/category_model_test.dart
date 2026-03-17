import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/data/models/category_model.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';

void main() {
  group('CategoryModel', () {
    // Test data
    final now = DateTime.now();
    final testMap = {
      CategoryFields.id: 1,
      CategoryFields.name: 'Makan',
      CategoryFields.type: 'expense',
      CategoryFields.color: '#F44336',
      CategoryFields.icon: '🍔',
      CategoryFields.sortOrder: 1,
      CategoryFields.isActive: 1,
      CategoryFields.createdAt: now.toIso8601String(),
      CategoryFields.updatedAt: now.toIso8601String(),
    };

    final testEntity = CategoryEntity(
      id: 1,
      name: 'Makan',
      type: CategoryType.expense,
      color: '#F44336',
      icon: '🍔',
      sortOrder: 1,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    group('fromMap', () {
      test('should create CategoryModel from Map correctly', () {
        // Act
        final model = CategoryModel.fromMap(testMap);

        // Assert
        expect(model.id, 1);
        expect(model.name, 'Makan');
        expect(model.type, 'expense');
        expect(model.color, '#F44336');
        expect(model.icon, '🍔');
        expect(model.sortOrder, 1);
        expect(model.isActive, 1);
        expect(model.createdAt, now.toIso8601String());
        expect(model.updatedAt, now.toIso8601String());
      });

      test('should handle nullable id field', () {
        // Arrange
        final mapWithoutId = {...testMap};
        mapWithoutId.remove(CategoryFields.id);

        // Act
        final model = CategoryModel.fromMap(mapWithoutId);

        // Assert
        expect(model.id, isNull);
      });

      test('should handle nullable icon field', () {
        // Arrange
        final mapWithoutIcon = Map<String, dynamic>.from(testMap);
        mapWithoutIcon[CategoryFields.icon] = null;

        // Act
        final model = CategoryModel.fromMap(mapWithoutIcon);

        // Assert
        expect(model.icon, isNull);
      });

      test('should use default value for sortOrder when null', () {
        // Arrange
        final mapWithoutSortOrder = {...testMap};
        mapWithoutSortOrder.remove(CategoryFields.sortOrder);

        // Act
        final model = CategoryModel.fromMap(mapWithoutSortOrder);

        // Assert
        expect(model.sortOrder, 0);
      });

      test('should use default value for isActive when null', () {
        // Arrange
        final mapWithoutIsActive = {...testMap};
        mapWithoutIsActive.remove(CategoryFields.isActive);

        // Act
        final model = CategoryModel.fromMap(mapWithoutIsActive);

        // Assert
        expect(model.isActive, 1);
      });
    });

    group('toMap', () {
      test('should convert CategoryModel to Map correctly with id', () {
        // Arrange
        final model = CategoryModel(
          id: 1,
          name: 'Makan',
          type: 'expense',
          color: '#F44336',
          icon: '🍔',
          sortOrder: 1,
          isActive: 1,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final map = model.toMap();

        // Assert
        expect(map[CategoryFields.id], 1);
        expect(map[CategoryFields.name], 'Makan');
        expect(map[CategoryFields.type], 'expense');
        expect(map[CategoryFields.color], '#F44336');
        expect(map[CategoryFields.icon], '🍔');
        expect(map[CategoryFields.sortOrder], 1);
        expect(map[CategoryFields.isActive], 1);
        expect(map[CategoryFields.createdAt], now.toIso8601String());
        expect(map[CategoryFields.updatedAt], now.toIso8601String());
      });

      test('should convert CategoryModel to Map correctly without id', () {
        // Arrange
        final model = CategoryModel(
          name: 'Makan',
          type: 'expense',
          color: '#F44336',
          icon: '🍔',
          sortOrder: 1,
          isActive: 1,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final map = model.toMap();

        // Assert
        expect(map.containsKey(CategoryFields.id), false);
        expect(map[CategoryFields.name], 'Makan');
        expect(map[CategoryFields.type], 'expense');
      });

      test('should handle null icon in toMap', () {
        // Arrange
        final model = CategoryModel(
          id: 1,
          name: 'Makan',
          type: 'expense',
          color: '#F44336',
          icon: null,
          sortOrder: 1,
          isActive: 1,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final map = model.toMap();

        // Assert
        expect(map[CategoryFields.icon], isNull);
      });
    });

    group('toEntity', () {
      test('should convert CategoryModel to CategoryEntity correctly', () {
        // Arrange
        final model = CategoryModel(
          id: 1,
          name: 'Makan',
          type: 'expense',
          color: '#F44336',
          icon: '🍔',
          sortOrder: 1,
          isActive: 1,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.id, 1);
        expect(entity.name, 'Makan');
        expect(entity.type, CategoryType.expense);
        expect(entity.color, '#F44336');
        expect(entity.icon, '🍔');
        expect(entity.sortOrder, 1);
        expect(entity.isActive, true);
        expect(entity.createdAt, now);
        expect(entity.updatedAt, now);
      });

      test('should convert isActive 1 to true and 0 to false', () {
        // Arrange
        final activeModel = CategoryModel(
          id: 1,
          name: 'Active',
          type: 'expense',
          color: '#F44336',
          isActive: 1,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        final inactiveModel = CategoryModel(
          id: 2,
          name: 'Inactive',
          type: 'expense',
          color: '#F44336',
          isActive: 0,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final activeEntity = activeModel.toEntity();
        final inactiveEntity = inactiveModel.toEntity();

        // Assert
        expect(activeEntity.isActive, true);
        expect(inactiveEntity.isActive, false);
      });

      test('should convert type "income" to CategoryType.income', () {
        // Arrange
        final model = CategoryModel(
          id: 1,
          name: 'Gaji',
          type: 'income',
          color: '#4CAF50',
          icon: '💰',
          isActive: 1,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.type, CategoryType.income);
      });
    });

    group('fromEntity', () {
      test('should convert CategoryEntity to CategoryModel correctly', () {
        // Act
        final model = CategoryModel.fromEntity(testEntity);

        // Assert
        expect(model.id, 1);
        expect(model.name, 'Makan');
        expect(model.type, 'expense');
        expect(model.color, '#F44336');
        expect(model.icon, '🍔');
        expect(model.sortOrder, 1);
        expect(model.isActive, 1);
        expect(model.createdAt, now.toIso8601String());
        expect(model.updatedAt, now.toIso8601String());
      });

      test('should convert CategoryType to string value correctly', () {
        // Arrange
        final incomeEntity = CategoryEntity(
          id: 1,
          name: 'Gaji',
          type: CategoryType.income,
          color: '#4CAF50',
          icon: '💰',
          createdAt: now,
          updatedAt: now,
        );

        // Act
        final model = CategoryModel.fromEntity(incomeEntity);

        // Assert
        expect(model.type, 'income');
      });

      test('should convert boolean isActive to int (1 for true, 0 for false)', () {
        // Arrange
        final activeEntity = CategoryEntity(
          id: 1,
          name: 'Active',
          type: CategoryType.expense,
          color: '#F44336',
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );

        final inactiveEntity = CategoryEntity(
          id: 2,
          name: 'Inactive',
          type: CategoryType.expense,
          color: '#F44336',
          isActive: false,
          createdAt: now,
          updatedAt: now,
        );

        // Act
        final activeModel = CategoryModel.fromEntity(activeEntity);
        final inactiveModel = CategoryModel.fromEntity(inactiveEntity);

        // Assert
        expect(activeModel.isActive, 1);
        expect(inactiveModel.isActive, 0);
      });

      test('should handle null icon in fromEntity', () {
        // Arrange
        final entityWithoutIcon = CategoryEntity(
          id: 1,
          name: 'Makan',
          type: CategoryType.expense,
          color: '#F44336',
          createdAt: now,
          updatedAt: now,
        );

        // Act
        final model = CategoryModel.fromEntity(entityWithoutIcon);

        // Assert
        expect(model.icon, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated values', () {
        // Arrange
        final model = CategoryModel(
          id: 1,
          name: 'Makan',
          type: 'expense',
          color: '#F44336',
          icon: '🍔',
          sortOrder: 1,
          isActive: 1,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final updated = model.copyWith(name: 'Jajan');

        // Assert
        expect(updated.id, 1);
        expect(updated.name, 'Jajan');
        expect(updated.type, 'expense');
        expect(model.name, 'Makan'); // Original unchanged
      });

      test('should handle null values in copyWith', () {
        // Arrange
        final model = CategoryModel(
          id: 1,
          name: 'Makan',
          type: 'expense',
          color: '#F44336',
          icon: '🍔',
          sortOrder: 1,
          isActive: 1,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final updated = model.copyWith(icon: null);

        // Assert
        expect(updated.icon, isNull);
        expect(updated.id, 1);
        expect(updated.name, 'Makan');
      });

      test('should handle boolean to int conversion in copyWith for isActive', () {
        // Arrange
        final model = CategoryModel(
          id: 1,
          name: 'Makan',
          type: 'expense',
          color: '#F44336',
          isActive: 1,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final updated = model.copyWith(isActive: 0);

        // Assert
        expect(updated.isActive, 0);
      });
    });

    group('Equality', () {
      test('should return true for identical models', () {
        // Arrange
        final model1 = CategoryModel(
          id: 1,
          name: 'Makan',
          type: 'expense',
          color: '#F44336',
          icon: '🍔',
          sortOrder: 1,
          isActive: 1,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );
        final model2 = CategoryModel(
          id: 1,
          name: 'Makan',
          type: 'expense',
          color: '#F44336',
          icon: '🍔',
          sortOrder: 1,
          isActive: 1,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Assert
        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should return false for different models', () {
        // Arrange
        final model1 = CategoryModel(
          id: 1,
          name: 'Makan',
          type: 'expense',
          color: '#F44336',
          icon: '🍔',
          sortOrder: 1,
          isActive: 1,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );
        final model2 = CategoryModel(
          id: 2,
          name: 'Transport',
          type: 'expense',
          color: '#E91E63',
          icon: '🚗',
          sortOrder: 2,
          isActive: 1,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Assert
        expect(model1, isNot(equals(model2)));
      });

      test('should return false when only icon differs', () {
        // Arrange
        final model1 = CategoryModel(
          id: 1,
          name: 'Makan',
          type: 'expense',
          color: '#F44336',
          icon: '🍔',
          sortOrder: 1,
          isActive: 1,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );
        final model2 = CategoryModel(
          id: 1,
          name: 'Makan',
          type: 'expense',
          color: '#F44336',
          icon: '🍕',
          sortOrder: 1,
          isActive: 1,
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
        final originalModel = CategoryModel(
          id: 1,
          name: 'Makan',
          type: 'expense',
          color: '#F44336',
          icon: '🍔',
          sortOrder: 1,
          isActive: 1,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final map = originalModel.toMap();
        final recreatedModel = CategoryModel.fromMap(map);

        // Assert
        expect(recreatedModel, equals(originalModel));
      });

      test('should maintain data integrity through toEntity and fromEntity', () {
        // Arrange
        final originalModel = CategoryModel(
          id: 1,
          name: 'Makan',
          type: 'expense',
          color: '#F44336',
          icon: '🍔',
          sortOrder: 1,
          isActive: 1,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final entity = originalModel.toEntity();
        final recreatedModel = CategoryModel.fromEntity(entity);

        // Assert
        expect(recreatedModel.id, equals(originalModel.id));
        expect(recreatedModel.name, equals(originalModel.name));
        expect(recreatedModel.type, equals(originalModel.type));
        expect(recreatedModel.color, equals(originalModel.color));
        expect(recreatedModel.icon, equals(originalModel.icon));
        expect(recreatedModel.sortOrder, equals(originalModel.sortOrder));
        expect(recreatedModel.isActive, equals(originalModel.isActive));
        expect(recreatedModel.createdAt, equals(originalModel.createdAt));
        expect(recreatedModel.updatedAt, equals(originalModel.updatedAt));
      });
    });

    group('toString', () {
      test('should return readable string representation', () {
        // Arrange
        final model = CategoryModel(
          id: 1,
          name: 'Makan',
          type: 'expense',
          color: '#F44336',
          icon: '🍔',
          sortOrder: 1,
          isActive: 1,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );

        // Act
        final str = model.toString();

        // Assert
        expect(str, contains('CategoryModel'));
        expect(str, contains('id: 1'));
        expect(str, contains('name: Makan'));
        expect(str, contains('type: expense'));
        expect(str, contains('color: #F44336'));
        expect(str, contains('icon: 🍔'));
      });
    });
  });
}
