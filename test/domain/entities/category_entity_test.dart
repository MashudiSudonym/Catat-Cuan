import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  group('CategoryEntity', () {
    group('Entity creation', () {
      test('should create entity with all required fields', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: 1,
          name: 'Makan',
          type: CategoryType.expense,
          color: '#FF64748B',
          icon: '🍽️',
          sortOrder: 1,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.id, equals(1));
        expect(entity.name, equals('Makan'));
        expect(entity.type, equals(CategoryType.expense));
        expect(entity.color, equals('#FF64748B'));
        expect(entity.icon, equals('🍽️'));
        expect(entity.sortOrder, equals(1));
        expect(entity.isActive, isTrue);
      });

      test('should create entity without ID (for new categories)', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: null,
          name: 'New Category',
          type: CategoryType.expense,
          color: '#FF000000',
          icon: '📁',
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.id, isNull);
        expect(entity.name, equals('New Category'));
        expect(entity.sortOrder, equals(0)); // Default value
        expect(entity.isActive, isTrue); // Default value
      });

      test('should create entity with optional icon', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: 1,
          name: 'Transport',
          type: CategoryType.expense,
          color: '#FF59E6C6',
          icon: null,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.icon, isNull);
      });

      test('should use default values for sortOrder and isActive', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: 1,
          name: 'Test',
          type: CategoryType.expense,
          color: '#FF000000',
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.sortOrder, equals(0));
        expect(entity.isActive, isTrue);
      });
    });

    group('Immutability', () {
      test('should be immutable with copyWith', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: 1,
          name: 'Original',
          type: CategoryType.expense,
          color: '#FF64748B',
          icon: '🍽️',
          sortOrder: 1,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );

        final updated = entity.copyWith(name: 'Updated');

        expect(entity.name, equals('Original')); // Original unchanged
        expect(updated.name, equals('Updated')); // Copy updated
      });

      test('should copy with ID', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: null,
          name: 'New',
          type: CategoryType.expense,
          color: '#FF000000',
          createdAt: now,
          updatedAt: now,
        );

        final withId = entity.copyWith(id: 1);

        expect(entity.id, isNull);
        expect(withId.id, equals(1));
      });

      test('should copy with active status', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: 1,
          name: 'Test',
          type: CategoryType.expense,
          color: '#FF000000',
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );

        final deactivated = entity.copyWith(isActive: false);

        expect(entity.isActive, isTrue);
        expect(deactivated.isActive, isFalse);
      });

      test('should copy with sortOrder', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: 1,
          name: 'Test',
          type: CategoryType.expense,
          color: '#FF000000',
          sortOrder: 1,
          createdAt: now,
          updatedAt: now,
        );

        final reordered = entity.copyWith(sortOrder: 5);

        expect(entity.sortOrder, equals(1));
        expect(reordered.sortOrder, equals(5));
      });
    });

    group('Type validation', () {
      test('should accept income type', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: 1,
          name: 'Gaji',
          type: CategoryType.income,
          color: '#FF34D399',
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.type, equals(CategoryType.income));
        expect(entity.type.displayName, equals('Pemasukan'));
      });

      test('should accept expense type', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: 1,
          name: 'Makan',
          type: CategoryType.expense,
          color: '#FF64748B',
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.type, equals(CategoryType.expense));
        expect(entity.type.displayName, equals('Pengeluaran'));
      });
    });

    group('Color validation', () {
      test('should accept valid hex color', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: 1,
          name: 'Test',
          type: CategoryType.expense,
          color: '#FF64748B',
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.color, equals('#FF64748B'));
      });

      test('should accept short hex color', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: 1,
          name: 'Test',
          type: CategoryType.expense,
          color: '#F00',
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.color, equals('#F00'));
      });

      test('should accept RGB color', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: 1,
          name: 'Test',
          type: CategoryType.expense,
          color: 'rgb(100, 150, 200)',
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.color, equals('rgb(100, 150, 200)'));
      });
    });

    group('Icon validation', () {
      test('should accept emoji icon', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: 1,
          name: 'Makan',
          type: CategoryType.expense,
          color: '#FF64748B',
          icon: '🍽️',
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.icon, equals('🍽️'));
      });

      test('should accept text icon', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: 1,
          name: 'Test',
          type: CategoryType.expense,
          color: '#FF000000',
          icon: 'A',
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.icon, equals('A'));
      });

      test('should accept multiple emojis', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: 1,
          name: 'Test',
          type: CategoryType.expense,
          color: '#FF000000',
          icon: '🍽️🍕',
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.icon, equals('🍽️🍕'));
      });
    });

    group('Active status', () {
      test('should accept active status', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: 1,
          name: 'Test',
          type: CategoryType.expense,
          color: '#FF000000',
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.isActive, isTrue);
      });

      test('should accept inactive status', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: 1,
          name: 'Test',
          type: CategoryType.expense,
          color: '#FF000000',
          isActive: false,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.isActive, isFalse);
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        final now = DateTime.now();
        final entity1 = CategoryEntity(
          id: 1,
          name: 'Makan',
          type: CategoryType.expense,
          color: '#FF64748B',
          icon: '🍽️',
          sortOrder: 1,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );

        final entity2 = CategoryEntity(
          id: 1,
          name: 'Makan',
          type: CategoryType.expense,
          color: '#FF64748B',
          icon: '🍽️',
          sortOrder: 1,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity1, equals(entity2));
      });

      test('should not be equal when ID differs', () {
        final now = DateTime.now();
        final entity1 = CategoryEntity(
          id: 1,
          name: 'Makan',
          type: CategoryType.expense,
          color: '#FF64748B',
          createdAt: now,
          updatedAt: now,
        );

        final entity2 = CategoryEntity(
          id: 2,
          name: 'Makan',
          type: CategoryType.expense,
          color: '#FF64748B',
          createdAt: now,
          updatedAt: now,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when name differs', () {
        final now = DateTime.now();
        final entity1 = CategoryEntity(
          id: 1,
          name: 'Makan',
          type: CategoryType.expense,
          color: '#FF64748B',
          createdAt: now,
          updatedAt: now,
        );

        final entity2 = CategoryEntity(
          id: 1,
          name: 'Transport',
          type: CategoryType.expense,
          color: '#FF64748B',
          createdAt: now,
          updatedAt: now,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when type differs', () {
        final now = DateTime.now();
        final entity1 = CategoryEntity(
          id: 1,
          name: 'Gaji',
          type: CategoryType.income,
          color: '#FF34D399',
          createdAt: now,
          updatedAt: now,
        );

        final entity2 = CategoryEntity(
          id: 1,
          name: 'Gaji',
          type: CategoryType.expense,
          color: '#FF34D399',
          createdAt: now,
          updatedAt: now,
        );

        expect(entity1, isNot(equals(entity2)));
      });
    });

    group('Real-world scenarios', () {
      test('should create food category', () {
        final entity = TestFixtures.categoryFood();

        expect(entity.name, equals('Makan'));
        expect(entity.type, equals(CategoryType.expense));
        expect(entity.icon, equals('🍽️'));
        expect(entity.color, equals('#FF64748B'));
        expect(entity.sortOrder, equals(1));
        expect(entity.isActive, isTrue);
      });

      test('should create transport category', () {
        final entity = TestFixtures.categoryTransport();

        expect(entity.name, equals('Transport'));
        expect(entity.type, equals(CategoryType.expense));
        expect(entity.icon, equals('🚗'));
        expect(entity.color, equals('#FF59E6C6'));
        expect(entity.sortOrder, equals(2));
        expect(entity.isActive, isTrue);
      });

      test('should create salary category', () {
        final entity = TestFixtures.categorySalary();

        expect(entity.name, equals('Gaji'));
        expect(entity.type, equals(CategoryType.income));
        expect(entity.icon, equals('💰'));
        expect(entity.color, equals('#FF34D399'));
        expect(entity.sortOrder, equals(1));
        expect(entity.isActive, isTrue);
      });
    });

    group('Sort order scenarios', () {
      test('should handle zero sort order', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: 1,
          name: 'Test',
          type: CategoryType.expense,
          color: '#FF000000',
          sortOrder: 0,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.sortOrder, equals(0));
      });

      test('should handle large sort order', () {
        final now = DateTime.now();
        final entity = CategoryEntity(
          id: 1,
          name: 'Test',
          type: CategoryType.expense,
          color: '#FF000000',
          sortOrder: 999,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.sortOrder, equals(999));
      });
    });
  });

  group('CategoryType enum', () {
    group('fromString', () {
      test('should parse income', () {
        final type = CategoryType.fromString('income');
        expect(type, equals(CategoryType.income));
      });

      test('should parse expense', () {
        final type = CategoryType.fromString('expense');
        expect(type, equals(CategoryType.expense));
      });

      test('should not handle case insensitive (exact match required)', () {
        // CategoryType.fromString requires exact match, not case-insensitive
        expect(CategoryType.fromString('INCOME'), equals(CategoryType.expense)); // Falls back to default
        expect(CategoryType.fromString('Income'), equals(CategoryType.expense)); // Falls back to default
        expect(CategoryType.fromString('income'), equals(CategoryType.income)); // Exact match works
      });

      test('should default to expense for invalid value', () {
        final type = CategoryType.fromString('invalid');
        expect(type, equals(CategoryType.expense));
      });
    });

    group('displayName', () {
      test('should return Indonesian display name for income', () {
        expect(CategoryType.income.displayName, equals('Pemasukan'));
      });

      test('should return Indonesian display name for expense', () {
        expect(CategoryType.expense.displayName, equals('Pengeluaran'));
      });
    });

    group('value property', () {
      test('should return lowercase English value for income', () {
        expect(CategoryType.income.value, equals('income'));
      });

      test('should return lowercase English value for expense', () {
        expect(CategoryType.expense.value, equals('expense'));
      });
    });
  });
}
