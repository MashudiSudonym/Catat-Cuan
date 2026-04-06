import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  group('MonthlySummaryEntity', () {
    group('Entity creation', () {
      test('should create entity with all required fields', () {
        final now = DateTime.now();
        final entity = MonthlySummaryEntity(
          yearMonth: '2024-03',
          totalIncome: 10000000,
          totalExpense: 7500000,
          balance: 2500000,
          transactionCount: 42,
          createdAt: now,
        );

        expect(entity.yearMonth, equals('2024-03'));
        expect(entity.totalIncome, equals(10000000));
        expect(entity.totalExpense, equals(7500000));
        expect(entity.balance, equals(2500000));
        expect(entity.transactionCount, equals(42));
        expect(entity.createdAt, equals(now));
      });

      test('should create entity with zero values', () {
        final now = DateTime.now();
        final entity = MonthlySummaryEntity(
          yearMonth: '2024-01',
          totalIncome: 0,
          totalExpense: 0,
          balance: 0,
          transactionCount: 0,
          createdAt: now,
        );

        expect(entity.totalIncome, equals(0));
        expect(entity.totalExpense, equals(0));
        expect(entity.balance, equals(0));
        expect(entity.transactionCount, equals(0));
      });

      test('should create entity with negative balance (imbalance)', () {
        final now = DateTime.now();
        final entity = MonthlySummaryEntity(
          yearMonth: '2024-02',
          totalIncome: 5000000,
          totalExpense: 7500000,
          balance: -2500000,
          transactionCount: 30,
          createdAt: now,
        );

        expect(entity.balance, equals(-2500000));
        expect(entity.isImbalance, isTrue);
      });
    });

    group('Immutability', () {
      test('should be immutable with copyWith', () {
        final now = DateTime.now();
        final entity = MonthlySummaryEntity(
          yearMonth: '2024-03',
          totalIncome: 10000000,
          totalExpense: 7500000,
          balance: 2500000,
          transactionCount: 42,
          createdAt: now,
        );

        final updated = entity.copyWith(
          totalIncome: 12000000,
          transactionCount: 50,
        );

        expect(entity.totalIncome, equals(10000000)); // Original unchanged
        expect(entity.transactionCount, equals(42));
        expect(updated.totalIncome, equals(12000000)); // Copy updated
        expect(updated.transactionCount, equals(50));
        expect(updated.totalExpense, equals(7500000)); // Unchanged field preserved
      });

      test('should copy with yearMonth', () {
        final now = DateTime.now();
        final entity = MonthlySummaryEntity(
          yearMonth: '2024-03',
          totalIncome: 10000000,
          totalExpense: 7500000,
          balance: 2500000,
          transactionCount: 42,
          createdAt: now,
        );

        final april = entity.copyWith(yearMonth: '2024-04');

        expect(entity.yearMonth, equals('2024-03'));
        expect(april.yearMonth, equals('2024-04'));
      });
    });

    group('Computed properties', () {
      group('expensePercentage', () {
        test('should calculate correct expense percentage', () {
          final entity = MonthlySummaryEntity(
            yearMonth: '2024-03',
            totalIncome: 10000000,
            totalExpense: 7500000,
            balance: 2500000,
            transactionCount: 42,
            createdAt: DateTime.now(),
          );

          expect(entity.expensePercentage, equals(75.0));
        });

        test('should return 0 when income is 0', () {
          final entity = MonthlySummaryEntity(
            yearMonth: '2024-03',
            totalIncome: 0,
            totalExpense: 1000000,
            balance: -1000000,
            transactionCount: 5,
            createdAt: DateTime.now(),
          );

          expect(entity.expensePercentage, equals(0));
        });

        test('should handle >100% when expense exceeds income', () {
          final entity = MonthlySummaryEntity(
            yearMonth: '2024-03',
            totalIncome: 5000000,
            totalExpense: 7500000,
            balance: -2500000,
            transactionCount: 30,
            createdAt: DateTime.now(),
          );

          expect(entity.expensePercentage, equals(150.0));
        });
      });

      group('balancePercentage', () {
        test('should calculate correct balance percentage', () {
          final entity = MonthlySummaryEntity(
            yearMonth: '2024-03',
            totalIncome: 10000000,
            totalExpense: 7500000,
            balance: 2500000,
            transactionCount: 42,
            createdAt: DateTime.now(),
          );

          expect(entity.balancePercentage, equals(25.0));
        });

        test('should return 0 when income is 0', () {
          final entity = MonthlySummaryEntity(
            yearMonth: '2024-03',
            totalIncome: 0,
            totalExpense: 0,
            balance: 0,
            transactionCount: 0,
            createdAt: DateTime.now(),
          );

          expect(entity.balancePercentage, equals(0));
        });

        test('should return negative percentage for negative balance', () {
          final entity = MonthlySummaryEntity(
            yearMonth: '2024-03',
            totalIncome: 10000000,
            totalExpense: 12000000,
            balance: -2000000,
            transactionCount: 35,
            createdAt: DateTime.now(),
          );

          expect(entity.balancePercentage, equals(-20.0));
        });
      });

      group('isHealthy', () {
        test('should return true when balance >= 20% of income', () {
          final entity = MonthlySummaryEntity(
            yearMonth: '2024-03',
            totalIncome: 10000000,
            totalExpense: 7500000,
            balance: 2500000, // 25%
            transactionCount: 42,
            createdAt: DateTime.now(),
          );

          expect(entity.isHealthy, isTrue);
        });

        test('should return true when balance exactly 20% threshold', () {
          final entity = MonthlySummaryEntity(
            yearMonth: '2024-03',
            totalIncome: 10000000,
            totalExpense: 8000000,
            balance: 2000000, // 20%
            transactionCount: 40,
            createdAt: DateTime.now(),
          );

          expect(entity.isHealthy, isTrue);
        });

        test('should return false when balance below 20% threshold', () {
          final entity = MonthlySummaryEntity(
            yearMonth: '2024-03',
            totalIncome: 10000000,
            totalExpense: 8500000,
            balance: 1500000, // 15%
            transactionCount: 38,
            createdAt: DateTime.now(),
          );

          expect(entity.isHealthy, isFalse);
        });

        test('should return false when balance is 0', () {
          final entity = MonthlySummaryEntity(
            yearMonth: '2024-03',
            totalIncome: 10000000,
            totalExpense: 10000000,
            balance: 0,
            transactionCount: 30,
            createdAt: DateTime.now(),
          );

          expect(entity.isHealthy, isFalse);
        });

        test('should return false when balance is negative', () {
          final entity = MonthlySummaryEntity(
            yearMonth: '2024-03',
            totalIncome: 10000000,
            totalExpense: 12000000,
            balance: -2000000,
            transactionCount: 35,
            createdAt: DateTime.now(),
          );

          expect(entity.isHealthy, isFalse);
        });
      });

      group('isImbalance', () {
        test('should return true when balance is negative', () {
          final entity = MonthlySummaryEntity(
            yearMonth: '2024-03',
            totalIncome: 10000000,
            totalExpense: 12000000,
            balance: -2000000,
            transactionCount: 35,
            createdAt: DateTime.now(),
          );

          expect(entity.isImbalance, isTrue);
        });

        test('should return false when balance is 0', () {
          final entity = MonthlySummaryEntity(
            yearMonth: '2024-03',
            totalIncome: 10000000,
            totalExpense: 10000000,
            balance: 0,
            transactionCount: 30,
            createdAt: DateTime.now(),
          );

          expect(entity.isImbalance, isFalse);
        });

        test('should return false when balance is positive', () {
          final entity = MonthlySummaryEntity(
            yearMonth: '2024-03',
            totalIncome: 10000000,
            totalExpense: 7500000,
            balance: 2500000,
            transactionCount: 42,
            createdAt: DateTime.now(),
          );

          expect(entity.isImbalance, isFalse);
        });
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        final now = DateTime.now();
        final entity1 = MonthlySummaryEntity(
          yearMonth: '2024-03',
          totalIncome: 10000000,
          totalExpense: 7500000,
          balance: 2500000,
          transactionCount: 42,
          createdAt: now,
        );

        final entity2 = MonthlySummaryEntity(
          yearMonth: '2024-03',
          totalIncome: 10000000,
          totalExpense: 7500000,
          balance: 2500000,
          transactionCount: 42,
          createdAt: now,
        );

        expect(entity1, equals(entity2));
      });

      test('should not be equal when yearMonth differs', () {
        final now = DateTime.now();
        final entity1 = MonthlySummaryEntity(
          yearMonth: '2024-03',
          totalIncome: 10000000,
          totalExpense: 7500000,
          balance: 2500000,
          transactionCount: 42,
          createdAt: now,
        );

        final entity2 = MonthlySummaryEntity(
          yearMonth: '2024-04',
          totalIncome: 10000000,
          totalExpense: 7500000,
          balance: 2500000,
          transactionCount: 42,
          createdAt: now,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when balance differs', () {
        final now = DateTime.now();
        final entity1 = MonthlySummaryEntity(
          yearMonth: '2024-03',
          totalIncome: 10000000,
          totalExpense: 7500000,
          balance: 2500000,
          transactionCount: 42,
          createdAt: now,
        );

        final entity2 = MonthlySummaryEntity(
          yearMonth: '2024-03',
          totalIncome: 10000000,
          totalExpense: 7500000,
          balance: 3000000,
          transactionCount: 42,
          createdAt: now,
        );

        expect(entity1, isNot(equals(entity2)));
      });
    });

    group('Real-world scenarios', () {
      test('should handle healthy financial month', () {
        final entity = TestFixtures.monthlySummaryHealthy();

        expect(entity.isHealthy, isTrue);
        expect(entity.isImbalance, isFalse);
        expect(entity.balancePercentage, greaterThanOrEqualTo(20.0));
      });

      test('should handle imbalanced financial month', () {
        final entity = TestFixtures.monthlySummaryImbalance();

        expect(entity.isImbalance, isTrue);
        expect(entity.isHealthy, isFalse);
        expect(entity.balance, lessThan(0));
      });

      test('should handle month with no transactions', () {
        final now = DateTime.now();
        final entity = MonthlySummaryEntity(
          yearMonth: '2024-01',
          totalIncome: 0,
          totalExpense: 0,
          balance: 0,
          transactionCount: 0,
          createdAt: now,
        );

        expect(entity.transactionCount, equals(0));
        expect(entity.isImbalance, isFalse); // 0 balance is not imbalance
        expect(entity.isHealthy, isFalse); // But not healthy either (no income)
      });
    });

    group('Edge cases', () {
      test('should handle very large amounts', () {
        final now = DateTime.now();
        final entity = MonthlySummaryEntity(
          yearMonth: '2024-12',
          totalIncome: 999999999,
          totalExpense: 888888888,
          balance: 111111111,
          transactionCount: 999,
          createdAt: now,
        );

        expect(entity.balance, equals(111111111));
        expect(entity.transactionCount, equals(999));
      });

      test('should handle single transaction', () {
        final now = DateTime.now();
        final entity = MonthlySummaryEntity(
          yearMonth: '2024-06',
          totalIncome: 500000,
          totalExpense: 0,
          balance: 500000,
          transactionCount: 1,
          createdAt: now,
        );

        expect(entity.transactionCount, equals(1));
        expect(entity.isHealthy, isTrue);
      });
    });
  });
}
