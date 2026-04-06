import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/entities/category_breakdown_entity.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  group('CategoryBreakdownEntity', () {
    group('Entity creation', () {
      test('should create entity with all required fields', () {
        final entity = CategoryBreakdownEntity(
          categoryId: 1,
          categoryName: 'Makan',
          categoryIcon: '🍽️',
          categoryColor: '#FF64748B',
          totalAmount: 1500000,
          percentage: 30.0,
          transactionCount: 15,
        );

        expect(entity.categoryId, equals(1));
        expect(entity.categoryName, equals('Makan'));
        expect(entity.categoryIcon, equals('🍽️'));
        expect(entity.categoryColor, equals('#FF64748B'));
        expect(entity.totalAmount, equals(1500000));
        expect(entity.percentage, equals(30.0));
        expect(entity.transactionCount, equals(15));
      });

      test('should create entity with zero values', () {
        final entity = CategoryBreakdownEntity(
          categoryId: 1,
          categoryName: 'Test',
          categoryIcon: '📁',
          categoryColor: '#FF000000',
          totalAmount: 0,
          percentage: 0.0,
          transactionCount: 0,
        );

        expect(entity.totalAmount, equals(0));
        expect(entity.percentage, equals(0.0));
        expect(entity.transactionCount, equals(0));
      });

      test('should create entity with 100% percentage', () {
        final entity = CategoryBreakdownEntity(
          categoryId: 1,
          categoryName: 'Only Category',
          categoryIcon: '📊',
          categoryColor: '#FF34D399',
          totalAmount: 5000000,
          percentage: 100.0,
          transactionCount: 50,
        );

        expect(entity.percentage, equals(100.0));
        expect(entity.isExcessive, isTrue); // > 40% threshold
      });
    });

    group('Immutability', () {
      test('should be immutable with copyWith', () {
        final entity = CategoryBreakdownEntity(
          categoryId: 1,
          categoryName: 'Makan',
          categoryIcon: '🍽️',
          categoryColor: '#FF64748B',
          totalAmount: 1500000,
          percentage: 30.0,
          transactionCount: 15,
        );

        final updated = entity.copyWith(
          totalAmount: 2000000,
          transactionCount: 20,
        );

        expect(entity.totalAmount, equals(1500000)); // Original unchanged
        expect(entity.transactionCount, equals(15));
        expect(updated.totalAmount, equals(2000000)); // Copy updated
        expect(updated.transactionCount, equals(20));
        expect(updated.categoryName, equals('Makan')); // Unchanged field preserved
      });

      test('should copy with percentage', () {
        final entity = CategoryBreakdownEntity(
          categoryId: 1,
          categoryName: 'Makan',
          categoryIcon: '🍽️',
          categoryColor: '#FF64748B',
          totalAmount: 1500000,
          percentage: 30.0,
          transactionCount: 15,
        );

        final updated = entity.copyWith(percentage: 45.0);

        expect(entity.percentage, equals(30.0));
        expect(updated.percentage, equals(45.0));
      });
    });

    group('Computed properties', () {
      group('isExcessive', () {
        test('should return true when percentage exceeds 40% threshold', () {
          final entity = CategoryBreakdownEntity(
            categoryId: 1,
            categoryName: 'Makan',
            categoryIcon: '🍽️',
            categoryColor: '#FF64748B',
            totalAmount: 1500000,
            percentage: 45.0,
            transactionCount: 15,
          );

          expect(entity.isExcessive, isTrue);
        });

        test('should return false when percentage equals 40% threshold', () {
          final entity = CategoryBreakdownEntity(
            categoryId: 1,
            categoryName: 'Transport',
            categoryIcon: '🚗',
            categoryColor: '#FF59E6C6',
            totalAmount: 2000000,
            percentage: 40.0,
            transactionCount: 20,
          );

          expect(entity.isExcessive, isFalse);
        });

        test('should return false when percentage below 40% threshold', () {
          final entity = CategoryBreakdownEntity(
            categoryId: 1,
            categoryName: 'Hiburan',
            categoryIcon: '🎬',
            categoryColor: '#FFA78BFA',
            totalAmount: 500000,
            percentage: 10.0,
            transactionCount: 5,
          );

          expect(entity.isExcessive, isFalse);
        });

        test('should return false at 0%', () {
          final entity = CategoryBreakdownEntity(
            categoryId: 1,
            categoryName: 'Test',
            categoryIcon: '📁',
            categoryColor: '#FF000000',
            totalAmount: 0,
            percentage: 0.0,
            transactionCount: 0,
          );

          expect(entity.isExcessive, isFalse);
        });

        test('should return true at 100%', () {
          final entity = CategoryBreakdownEntity(
            categoryId: 1,
            categoryName: 'Only',
            categoryIcon: '📊',
            categoryColor: '#FF34D399',
            totalAmount: 5000000,
            percentage: 100.0,
            transactionCount: 50,
          );

          expect(entity.isExcessive, isTrue);
        });

        test('should handle decimal threshold boundary', () {
          final entity = CategoryBreakdownEntity(
            categoryId: 1,
            categoryName: 'Test',
            categoryIcon: '📁',
            categoryColor: '#FF000000',
            totalAmount: 1000000,
            percentage: 40.01,
            transactionCount: 10,
          );

          expect(entity.isExcessive, isTrue);
        });
      });

      group('percentageDisplay', () {
        test('should format integer percentage', () {
          final entity = CategoryBreakdownEntity(
            categoryId: 1,
            categoryName: 'Makan',
            categoryIcon: '🍽️',
            categoryColor: '#FF64748B',
            totalAmount: 1500000,
            percentage: 30.0,
            transactionCount: 15,
          );

          expect(entity.percentageDisplay, equals('30.0%'));
        });

        test('should format decimal percentage', () {
          final entity = CategoryBreakdownEntity(
            categoryId: 1,
            categoryName: 'Transport',
            categoryIcon: '🚗',
            categoryColor: '#FF59E6C6',
            totalAmount: 1833333,
            percentage: 36.666,
            transactionCount: 11,
          );

          expect(entity.percentageDisplay, equals('36.7%'));
        });

        test('should format 0%', () {
          final entity = CategoryBreakdownEntity(
            categoryId: 1,
            categoryName: 'Test',
            categoryIcon: '📁',
            categoryColor: '#FF000000',
            totalAmount: 0,
            percentage: 0.0,
            transactionCount: 0,
          );

          expect(entity.percentageDisplay, equals('0.0%'));
        });

        test('should format 100%', () {
          final entity = CategoryBreakdownEntity(
            categoryId: 1,
            categoryName: 'Only',
            categoryIcon: '📊',
            categoryColor: '#FF34D399',
            totalAmount: 5000000,
            percentage: 100.0,
            transactionCount: 50,
          );

          expect(entity.percentageDisplay, equals('100.0%'));
        });

        test('should round correctly', () {
          final entity = CategoryBreakdownEntity(
            categoryId: 1,
            categoryName: 'Test',
            categoryIcon: '📁',
            categoryColor: '#FF000000',
            totalAmount: 1000000,
            percentage: 33.333,
            transactionCount: 10,
          );

          expect(entity.percentageDisplay, equals('33.3%'));
        });
      });

      group('averagePerTransaction', () {
        test('should calculate correct average', () {
          final entity = CategoryBreakdownEntity(
            categoryId: 1,
            categoryName: 'Makan',
            categoryIcon: '🍽️',
            categoryColor: '#FF64748B',
            totalAmount: 1500000,
            percentage: 30.0,
            transactionCount: 15,
          );

          expect(entity.averagePerTransaction, equals(100000.0));
        });

        test('should return 0 when transactionCount is 0', () {
          final entity = CategoryBreakdownEntity(
            categoryId: 1,
            categoryName: 'Unused',
            categoryIcon: '📁',
            categoryColor: '#FF000000',
            totalAmount: 0,
            percentage: 0.0,
            transactionCount: 0,
          );

          expect(entity.averagePerTransaction, equals(0));
        });

        test('should return totalAmount for single transaction', () {
          final entity = CategoryBreakdownEntity(
            categoryId: 1,
            categoryName: 'One Time',
            categoryIcon: '💰',
            categoryColor: '#FF34D399',
            totalAmount: 500000,
            percentage: 10.0,
            transactionCount: 1,
          );

          expect(entity.averagePerTransaction, equals(500000.0));
        });

        test('should handle decimal amounts', () {
          final entity = CategoryBreakdownEntity(
            categoryId: 1,
            categoryName: 'Test',
            categoryIcon: '📁',
            categoryColor: '#FF000000',
            totalAmount: 100000,
            percentage: 2.0,
            transactionCount: 3,
          );

          expect(entity.averagePerTransaction, closeTo(33333.33, 0.01));
        });

        test('should return 0 when totalAmount is 0 but transactionCount > 0', () {
          final entity = CategoryBreakdownEntity(
            categoryId: 1,
            categoryName: 'Free',
            categoryIcon: '🎁',
            categoryColor: '#FF34D399',
            totalAmount: 0,
            percentage: 0.0,
            transactionCount: 5,
          );

          expect(entity.averagePerTransaction, equals(0));
        });
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        final entity1 = CategoryBreakdownEntity(
          categoryId: 1,
          categoryName: 'Makan',
          categoryIcon: '🍽️',
          categoryColor: '#FF64748B',
          totalAmount: 1500000,
          percentage: 30.0,
          transactionCount: 15,
        );

        final entity2 = CategoryBreakdownEntity(
          categoryId: 1,
          categoryName: 'Makan',
          categoryIcon: '🍽️',
          categoryColor: '#FF64748B',
          totalAmount: 1500000,
          percentage: 30.0,
          transactionCount: 15,
        );

        expect(entity1, equals(entity2));
      });

      test('should not be equal when categoryId differs', () {
        final entity1 = CategoryBreakdownEntity(
          categoryId: 1,
          categoryName: 'Makan',
          categoryIcon: '🍽️',
          categoryColor: '#FF64748B',
          totalAmount: 1500000,
          percentage: 30.0,
          transactionCount: 15,
        );

        final entity2 = CategoryBreakdownEntity(
          categoryId: 2,
          categoryName: 'Makan',
          categoryIcon: '🍽️',
          categoryColor: '#FF64748B',
          totalAmount: 1500000,
          percentage: 30.0,
          transactionCount: 15,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when categoryName differs', () {
        final entity1 = CategoryBreakdownEntity(
          categoryId: 1,
          categoryName: 'Makan',
          categoryIcon: '🍽️',
          categoryColor: '#FF64748B',
          totalAmount: 1500000,
          percentage: 30.0,
          transactionCount: 15,
        );

        final entity2 = CategoryBreakdownEntity(
          categoryId: 1,
          categoryName: 'Transport',
          categoryIcon: '🍽️',
          categoryColor: '#FF64748B',
          totalAmount: 1500000,
          percentage: 30.0,
          transactionCount: 15,
        );

        expect(entity1, isNot(equals(entity2)));
      });
    });

    group('Real-world scenarios', () {
      test('should handle food category breakdown', () {
        final entity = TestFixtures.categoryBreakdownFood();

        expect(entity.categoryName, equals('Makan'));
        expect(entity.categoryIcon, equals('🍽️'));
        expect(entity.totalAmount, greaterThan(0));
        expect(entity.transactionCount, greaterThan(0));
      });

      test('should handle transport category breakdown', () {
        final entity = TestFixtures.categoryBreakdownTransport();

        expect(entity.categoryName, equals('Transport'));
        expect(entity.categoryIcon, equals('🚗'));
        expect(entity.totalAmount, greaterThan(0));
      });

      test('should identify excessive category in real scenario', () {
        final entity = CategoryBreakdownEntity(
          categoryId: 1,
          categoryName: 'Makan',
          categoryIcon: '🍽️',
          categoryColor: '#FF64748B',
          totalAmount: 4000000, // 40% of 10M
          percentage: 40.0,
          transactionCount: 40,
        );

        // At exactly 40%, not excessive (threshold is exclusive)
        expect(entity.isExcessive, isFalse);
      });
    });

    group('Edge cases', () {
      test('should handle very large amounts', () {
        final entity = CategoryBreakdownEntity(
          categoryId: 1,
          categoryName: 'Big Spender',
          categoryIcon: '💰',
          categoryColor: '#FFEF4444',
          totalAmount: 999999999,
          percentage: 99.9,
          transactionCount: 999,
        );

        expect(entity.totalAmount, equals(999999999));
        expect(entity.isExcessive, isTrue);
      });

      test('should handle very small amounts', () {
        final entity = CategoryBreakdownEntity(
          categoryId: 1,
          categoryName: 'Small',
          categoryIcon: '🪙',
          categoryColor: '#FF34D399',
          totalAmount: 100,
          percentage: 0.001,
          transactionCount: 1,
        );

        expect(entity.totalAmount, equals(100));
        expect(entity.isExcessive, isFalse);
      });

      test('should handle category with emoji icon', () {
        final entity = CategoryBreakdownEntity(
          categoryId: 1,
          categoryName: 'Shopping',
          categoryIcon: '🛍️',
          categoryColor: '#FFA78BFA',
          totalAmount: 500000,
          percentage: 10.0,
          transactionCount: 3,
        );

        expect(entity.categoryIcon, equals('🛍️'));
      });

      test('should handle category with null equivalent empty string icon', () {
        final entity = CategoryBreakdownEntity(
          categoryId: 1,
          categoryName: 'Other',
          categoryIcon: '',
          categoryColor: '#FF9CA3AF',
          totalAmount: 100000,
          percentage: 2.0,
          transactionCount: 2,
        );

        expect(entity.categoryIcon, isEmpty);
      });
    });
  });
}
