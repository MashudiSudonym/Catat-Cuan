import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/entities/category_with_count_entity.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  group('CategoryWithCountEntity', () {
    late CategoryEntity testCategory;

    setUp(() {
      testCategory = CategoryEntity(
        id: 1,
        name: 'Makan',
        type: CategoryType.expense,
        color: '#FF64748B',
        icon: '🍽️',
        sortOrder: 1,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    group('Entity creation', () {
      test('should create entity with all required fields', () {
        final entity = CategoryWithCountEntity(
          category: testCategory,
          transactionCount: 15,
        );

        expect(entity.category, equals(testCategory));
        expect(entity.transactionCount, equals(15));
      });

      test('should create with zero transaction count', () {
        final entity = CategoryWithCountEntity(
          category: testCategory,
          transactionCount: 0,
        );

        expect(entity.transactionCount, equals(0));
      });

      test('should create with large transaction count', () {
        final entity = CategoryWithCountEntity(
          category: testCategory,
          transactionCount: 9999,
        );

        expect(entity.transactionCount, equals(9999));
      });

      test('should create with inactive category', () {
        final inactiveCategory = CategoryEntity(
          id: 2,
          name: 'Unused',
          type: CategoryType.expense,
          color: '#FF9CA3AF',
          icon: '📁',
          sortOrder: 99,
          isActive: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final entity = CategoryWithCountEntity(
          category: inactiveCategory,
          transactionCount: 0,
        );

        expect(entity.category.isActive, isFalse);
        expect(entity.transactionCount, equals(0));
      });

      test('should create with income category', () {
        final incomeCategory = CategoryEntity(
          id: 3,
          name: 'Gaji',
          type: CategoryType.income,
          color: '#FF34D399',
          icon: '💰',
          sortOrder: 1,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final entity = CategoryWithCountEntity(
          category: incomeCategory,
          transactionCount: 12,
        );

        expect(entity.category.type, equals(CategoryType.income));
        expect(entity.transactionCount, equals(12));
      });
    });

    group('Immutability', () {
      test('should be immutable with copyWith', () {
        final entity = CategoryWithCountEntity(
          category: testCategory,
          transactionCount: 15,
        );

        final updated = entity.copyWith(transactionCount: 20);

        expect(entity.transactionCount, equals(15)); // Original unchanged
        expect(updated.transactionCount, equals(20)); // Copy updated
        expect(updated.category, equals(testCategory)); // Unchanged field preserved
      });

      test('should copy with new category', () {
        final newCategory = CategoryEntity(
          id: 2,
          name: 'Transport',
          type: CategoryType.expense,
          color: '#FF59E6C6',
          icon: '🚗',
          sortOrder: 2,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final entity = CategoryWithCountEntity(
          category: testCategory,
          transactionCount: 15,
        );

        final updated = entity.copyWith(category: newCategory);

        expect(entity.category.name, equals('Makan')); // Original unchanged
        expect(updated.category.name, equals('Transport')); // Copy updated
        expect(updated.transactionCount, equals(15)); // Unchanged field preserved
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        final entity1 = CategoryWithCountEntity(
          category: testCategory,
          transactionCount: 15,
        );

        final entity2 = CategoryWithCountEntity(
          category: testCategory,
          transactionCount: 15,
        );

        expect(entity1, equals(entity2));
      });

      test('should not be equal when category differs', () {
        final otherCategory = CategoryEntity(
          id: 2,
          name: 'Transport',
          type: CategoryType.expense,
          color: '#FF59E6C6',
          icon: '🚗',
          sortOrder: 2,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final entity1 = CategoryWithCountEntity(
          category: testCategory,
          transactionCount: 15,
        );

        final entity2 = CategoryWithCountEntity(
          category: otherCategory,
          transactionCount: 15,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when transactionCount differs', () {
        final entity1 = CategoryWithCountEntity(
          category: testCategory,
          transactionCount: 15,
        );

        final entity2 = CategoryWithCountEntity(
          category: testCategory,
          transactionCount: 20,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when both differ', () {
        final otherCategory = CategoryEntity(
          id: 2,
          name: 'Transport',
          type: CategoryType.expense,
          color: '#FF59E6C6',
          icon: '🚗',
          sortOrder: 2,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final entity1 = CategoryWithCountEntity(
          category: testCategory,
          transactionCount: 15,
        );

        final entity2 = CategoryWithCountEntity(
          category: otherCategory,
          transactionCount: 20,
        );

        expect(entity1, isNot(equals(entity2)));
      });
    });

    group('Category delegation', () {
      test('should provide access to category properties', () {
        final entity = CategoryWithCountEntity(
          category: testCategory,
          transactionCount: 15,
        );

        expect(entity.category.id, equals(testCategory.id));
        expect(entity.category.name, equals(testCategory.name));
        expect(entity.category.type, equals(testCategory.type));
        expect(entity.category.color, equals(testCategory.color));
        expect(entity.category.icon, equals(testCategory.icon));
        expect(entity.category.sortOrder, equals(testCategory.sortOrder));
        expect(entity.category.isActive, equals(testCategory.isActive));
      });

      test('should delegate category type displayName', () {
        final entity = CategoryWithCountEntity(
          category: testCategory,
          transactionCount: 15,
        );

        expect(entity.category.type.displayName, equals('Pengeluaran'));
      });

      test('should delegate category icon', () {
        final entity = CategoryWithCountEntity(
          category: testCategory,
          transactionCount: 15,
        );

        expect(entity.category.icon, equals('🍽️'));
      });
    });

    group('Real-world scenarios', () {
      test('should represent category with usage count', () {
        final foodCategory = CategoryEntity(
          id: 1,
          name: 'Makan',
          type: CategoryType.expense,
          color: '#FF64748B',
          icon: '🍽️',
          sortOrder: 1,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final entity = CategoryWithCountEntity(
          category: foodCategory,
          transactionCount: 42,
        );

        expect(entity.category.name, equals('Makan'));
        expect(entity.transactionCount, equals(42));
      });

      test('should represent unused category', () {
        final unusedCategory = CategoryEntity(
          id: 5,
          name: 'Hiburan',
          type: CategoryType.expense,
          color: '#FFA78BFA',
          icon: '🎬',
          sortOrder: 5,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final entity = CategoryWithCountEntity(
          category: unusedCategory,
          transactionCount: 0,
        );

        expect(entity.category.name, equals('Hiburan'));
        expect(entity.transactionCount, equals(0));
      });

      test('should represent frequently used income category', () {
        final salaryCategory = CategoryEntity(
          id: 10,
          name: 'Gaji',
          type: CategoryType.income,
          color: '#FF34D399',
          icon: '💰',
          sortOrder: 1,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final entity = CategoryWithCountEntity(
          category: salaryCategory,
          transactionCount: 6, // 6 months of salary
        );

        expect(entity.category.type, equals(CategoryType.income));
        expect(entity.transactionCount, equals(6));
      });
    });

    group('Edge cases', () {
      test('should handle very large transaction count', () {
        final entity = CategoryWithCountEntity(
          category: testCategory,
          transactionCount: 2147483647, // max int32
        );

        expect(entity.transactionCount, equals(2147483647));
      });

      test('should handle category with null icon', () {
        final noIconCategory = CategoryEntity(
          id: 1,
          name: 'Other',
          type: CategoryType.expense,
          color: '#FF9CA3AF',
          icon: null,
          sortOrder: 99,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final entity = CategoryWithCountEntity(
          category: noIconCategory,
          transactionCount: 5,
        );

        expect(entity.category.icon, isNull);
        expect(entity.transactionCount, equals(5));
      });

      test('should handle category with emoji icon', () {
        final emojiCategory = CategoryEntity(
          id: 1,
          name: 'Shopping',
          type: CategoryType.expense,
          color: '#FFA78BFA',
          icon: '🛍️',
          sortOrder: 3,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final entity = CategoryWithCountEntity(
          category: emojiCategory,
          transactionCount: 10,
        );

        expect(entity.category.icon, equals('🛍️'));
      });
    });

    group('Integration with TestFixtures', () {
      test('should work with TestFixtures.categoryFood()', () {
        final foodCategory = TestFixtures.categoryFood();
        final entity = CategoryWithCountEntity(
          category: foodCategory,
          transactionCount: 25,
        );

        expect(entity.category.name, equals('Makan'));
        expect(entity.transactionCount, equals(25));
      });

      test('should work with TestFixtures.categoryTransport()', () {
        final transportCategory = TestFixtures.categoryTransport();
        final entity = CategoryWithCountEntity(
          category: transportCategory,
          transactionCount: 8,
        );

        expect(entity.category.name, equals('Transport'));
        expect(entity.transactionCount, equals(8));
      });

      test('should work with TestFixtures.categorySalary()', () {
        final salaryCategory = TestFixtures.categorySalary();
        final entity = CategoryWithCountEntity(
          category: salaryCategory,
          transactionCount: 3,
        );

        expect(entity.category.type, equals(CategoryType.income));
        expect(entity.transactionCount, equals(3));
      });
    });
  });
}
