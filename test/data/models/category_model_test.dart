import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/models/category_model.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryModel', () {
    group('fromMap', () {
      test('should create model from complete database map', () {
        // Arrange
        final map = {
          CategoryFields.id: 1,
          CategoryFields.name: 'Makan',
          CategoryFields.type: 'expense',
          CategoryFields.color: '#FF64748B',
          CategoryFields.icon: '🍽️',
          CategoryFields.sortOrder: 1,
          CategoryFields.isActive: 1,
          CategoryFields.createdAt: '2026-03-18T14:30:00.000Z',
          CategoryFields.updatedAt: '2026-03-18T14:30:00.000Z',
        };

        // Act
        final model = CategoryModel.fromMap(map);

        // Assert
        expect(model.id, 1);
        expect(model.name, 'Makan');
        expect(model.type, 'expense');
        expect(model.color, '#FF64748B');
        expect(model.icon, '🍽️');
        expect(model.sortOrder, 1);
        expect(model.isActive, 1);
        expect(model.createdAt, '2026-03-18T14:30:00.000Z');
        expect(model.updatedAt, '2026-03-18T14:30:00.000Z');
      });

      test('should use default values for missing nullable fields', () {
        // Arrange - Map with only required fields (id is nullable)
        final map = {
          CategoryFields.name: 'Belanja',
          CategoryFields.type: 'expense',
          CategoryFields.color: '#6B7280',
          CategoryFields.createdAt: '2026-03-18T14:30:00.000Z',
          CategoryFields.updatedAt: '2026-03-18T14:30:00.000Z',
        };

        // Act
        final model = CategoryModel.fromMap(map);

        // Assert
        expect(model.id, isNull); // Nullable, no default
        expect(model.icon, isNull); // Nullable, no default
        expect(model.sortOrder, 0); // Has @Default(0)
        expect(model.isActive, 1); // Has @Default(1)
        expect(model.name, 'Belanja');
        expect(model.type, 'expense');
        expect(model.color, '#6B7280');
      });
    });

    group('toMap', () {
      test('should convert to map for database insert/update', () {
        // Arrange
        final model = CategoryModel(
          id: 1,
          name: 'Transport',
          type: 'expense',
          color: '#FF59E6C6',
          icon: '🚗',
          sortOrder: 2,
          isActive: 1,
          createdAt: '2026-03-18T14:30:00.000Z',
          updatedAt: '2026-03-18T14:30:00.000Z',
        );

        // Act
        final map = model.toMap();

        // Assert
        expect(map[CategoryFields.id], 1);
        expect(map[CategoryFields.name], 'Transport');
        expect(map[CategoryFields.type], 'expense');
        expect(map[CategoryFields.color], '#FF59E6C6');
        expect(map[CategoryFields.icon], '🚗');
        expect(map[CategoryFields.sortOrder], 2);
        expect(map[CategoryFields.isActive], 1);
        expect(map[CategoryFields.createdAt], '2026-03-18T14:30:00.000Z');
        expect(map[CategoryFields.updatedAt], '2026-03-18T14:30:00.000Z');
      });

      test('should exclude id from map when id is null', () {
        // Arrange - New category without ID
        final model = CategoryModel(
          name: 'Kategori Baru',
          type: 'income',
          color: '#FF34D399',
          createdAt: '2026-03-18T14:30:00.000Z',
          updatedAt: '2026-03-18T14:30:00.000Z',
        );

        // Act
        final map = model.toMap();

        // Assert
        expect(map.containsKey(CategoryFields.id), isFalse);
        expect(map[CategoryFields.name], 'Kategori Baru');
      });
    });

    group('toEntity', () {
      test('should convert to CategoryEntity with correct type conversions', () {
        // Arrange
        final model = CategoryModel(
          id: 1,
          name: 'Makan',
          type: 'expense',
          color: '#FF64748B',
          icon: '🍽️',
          sortOrder: 1,
          isActive: 1, // int → bool
          createdAt: '2026-03-18T14:30:00.000Z', // String → DateTime
          updatedAt: '2026-03-18T14:30:00.000Z',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.id, 1);
        expect(entity.name, 'Makan');
        expect(entity.type, CategoryType.expense); // String → CategoryType
        expect(entity.color, '#FF64748B');
        expect(entity.icon, '🍽️');
        expect(entity.sortOrder, 1);
        expect(entity.isActive, isTrue); // 1 → true
        expect(entity.createdAt, DateTime.parse('2026-03-18T14:30:00.000Z'));
        expect(entity.updatedAt, DateTime.parse('2026-03-18T14:30:00.000Z'));
      });

      test('should convert isActive=0 to false', () {
        // Arrange
        final model = CategoryModel(
          id: 1,
          name: 'Inactive',
          type: 'expense',
          color: '#6B7280',
          isActive: 0, // int 0 → bool false
          createdAt: '2026-03-18T14:30:00.000Z',
          updatedAt: '2026-03-18T14:30:00.000Z',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.isActive, isFalse);
      });

      test('should convert type string to CategoryType correctly', () {
        // Test income type
        final incomeModel = CategoryModel(
          id: 1,
          name: 'Gaji',
          type: 'income',
          color: '#FF34D399',
          isActive: 1,
          createdAt: '2026-03-18T14:30:00.000Z',
          updatedAt: '2026-03-18T14:30:00.000Z',
        );

        final incomeEntity = incomeModel.toEntity();
        expect(incomeEntity.type, CategoryType.income);

        // Test expense type
        final expenseModel = CategoryModel(
          id: 2,
          name: 'Makan',
          type: 'expense',
          color: '#FF64748B',
          isActive: 1,
          createdAt: '2026-03-18T14:30:00.000Z',
          updatedAt: '2026-03-18T14:30:00.000Z',
        );

        final expenseEntity = expenseModel.toEntity();
        expect(expenseEntity.type, CategoryType.expense);
      });
    });

    group('fromEntity', () {
      test('should convert from CategoryEntity to CategoryModel', () {
        // Arrange
        final entity = CategoryEntity(
          id: 1,
          name: 'Transport',
          type: CategoryType.expense,
          color: '#FF59E6C6',
          icon: '🚗',
          sortOrder: 2,
          isActive: true,
          createdAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
          updatedAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
        );

        // Act
        final model = CategoryModel.fromEntity(entity);

        // Assert
        expect(model.id, 1);
        expect(model.name, 'Transport');
        expect(model.type, 'expense'); // CategoryType → String
        expect(model.color, '#FF59E6C6');
        expect(model.icon, '🚗');
        expect(model.sortOrder, 2);
        expect(model.isActive, 1); // bool → int
        expect(model.createdAt, '2026-03-18T14:30:00.000Z'); // DateTime → String
        expect(model.updatedAt, '2026-03-18T14:30:00.000Z');
      });

      test('should convert isActive=false to 0', () {
        // Arrange
        final entity = CategoryEntity(
          id: 1,
          name: 'Inactive',
          type: CategoryType.expense,
          color: '#6B7280',
          isActive: false, // bool false → int 0
          createdAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
          updatedAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
        );

        // Act
        final model = CategoryModel.fromEntity(entity);

        // Assert
        expect(model.isActive, 0);
      });
    });

    group('Round-trip conversions', () {
      test('should maintain data integrity through fromMap→toEntity→fromEntity→toMap', () {
        // Arrange - Original database map
        final originalMap = {
          CategoryFields.id: 1,
          CategoryFields.name: 'Makan',
          CategoryFields.type: 'expense',
          CategoryFields.color: '#FF64748B',
          CategoryFields.icon: '🍽️',
          CategoryFields.sortOrder: 1,
          CategoryFields.isActive: 1,
          CategoryFields.createdAt: '2026-03-18T14:30:00.000Z',
          CategoryFields.updatedAt: '2026-03-18T14:30:00.000Z',
        };

        // Act - Full round-trip conversion
        final model = CategoryModel.fromMap(originalMap);
        final entity = model.toEntity();
        final backToModel = CategoryModel.fromEntity(entity);
        final finalMap = backToModel.toMap();

        // Assert - All fields should match
        expect(finalMap[CategoryFields.id], originalMap[CategoryFields.id]);
        expect(finalMap[CategoryFields.name], originalMap[CategoryFields.name]);
        expect(finalMap[CategoryFields.type], originalMap[CategoryFields.type]);
        expect(finalMap[CategoryFields.color], originalMap[CategoryFields.color]);
        expect(finalMap[CategoryFields.icon], originalMap[CategoryFields.icon]);
        expect(finalMap[CategoryFields.sortOrder], originalMap[CategoryFields.sortOrder]);
        expect(finalMap[CategoryFields.isActive], originalMap[CategoryFields.isActive]);
      });
    });
  });
}
