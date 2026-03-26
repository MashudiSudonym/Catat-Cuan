import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/entities/category_breakdown_entity.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/services/insight/insight_rule_engine.dart';

void main() {
  group('InsightRuleEngine', () {
    late MonthlySummaryEntity healthySummary;
    late MonthlySummaryEntity imbalanceSummary;
    late List<CategoryBreakdownEntity> breakdownWithExcessive;
    late List<CategoryBreakdownEntity> normalBreakdown;

    setUp(() {
      final now = DateTime.now();

      healthySummary = MonthlySummaryEntity(
        yearMonth: '2024-03',
        totalIncome: 1000000,
        totalExpense: 700000,
        balance: 300000,
        transactionCount: 25,
        createdAt: now,
      );

      imbalanceSummary = MonthlySummaryEntity(
        yearMonth: '2024-03',
        totalIncome: 500000,
        totalExpense: 600000,
        balance: -100000,
        transactionCount: 15,
        createdAt: now,
      );

      breakdownWithExcessive = [
        CategoryBreakdownEntity(
          categoryId: 1,
          categoryName: 'Makan',
          categoryIcon: '🍽️',
          categoryColor: '#FF64748B',
          totalAmount: 450000,
          percentage: 45.0,
          transactionCount: 10,
        ),
        CategoryBreakdownEntity(
          categoryId: 2,
          categoryName: 'Transport',
          categoryIcon: '🚗',
          categoryColor: '#FF59E6C6',
          totalAmount: 250000,
          percentage: 25.0,
          transactionCount: 5,
        ),
      ];

      normalBreakdown = [
        CategoryBreakdownEntity(
          categoryId: 1,
          categoryName: 'Makan',
          categoryIcon: '🍽️',
          categoryColor: '#FF64748B',
          totalAmount: 200000,
          percentage: 20.0,
          transactionCount: 5,
        ),
        CategoryBreakdownEntity(
          categoryId: 2,
          categoryName: 'Transport',
          categoryIcon: '🚗',
          categoryColor: '#FF59E6C6',
          totalAmount: 150000,
          percentage: 15.0,
          transactionCount: 3,
        ),
      ];
    });

    group('isNewUser', () {
      test('should return true for transaction count below threshold', () {
        final result = InsightRuleEngine.isNewUser(3);
        expect(result, isTrue);
      });

      test('should return false for transaction count at or above threshold', () {
        final result = InsightRuleEngine.isNewUser(5);
        expect(result, isFalse);
      });

      test('should use custom threshold when provided', () {
        final result = InsightRuleEngine.isNewUser(3, minTransactionCount: 10);
        expect(result, isTrue);
      });
    });

    group('hasImbalance', () {
      test('should return true for negative balance', () {
        final result = InsightRuleEngine.hasImbalance(imbalanceSummary);
        expect(result, isTrue);
      });

      test('should return false for positive balance', () {
        final result = InsightRuleEngine.hasImbalance(healthySummary);
        expect(result, isFalse);
      });
    });

    group('checkExcessiveCategories', () {
      test('should identify excessive categories above threshold', () {
        final result = InsightRuleEngine.checkExcessiveCategories(breakdownWithExcessive);

        expect(result.length, equals(1));
        expect(result.first.categoryName, equals('Makan'));
        expect(result.first.percentage, equals(45.0));
      });

      test('should return empty list when no excessive categories', () {
        final result = InsightRuleEngine.checkExcessiveCategories(normalBreakdown);

        expect(result, isEmpty);
      });

      test('should use custom threshold when provided', () {
        final result = InsightRuleEngine.checkExcessiveCategories(
          normalBreakdown,
          threshold: 15.0,
        );

        expect(result.length, equals(1));
      });
    });

    group('isHealthyFinance', () {
      test('should return true when healthy with no excessive categories', () {
        final result = InsightRuleEngine.isHealthyFinance(
          healthySummary,
          hasExcessiveCategories: false,
        );

        expect(result, isTrue);
      });

      test('should return false when has excessive categories', () {
        final result = InsightRuleEngine.isHealthyFinance(
          healthySummary,
          hasExcessiveCategories: true,
        );

        expect(result, isFalse);
      });

      test('should return false when imbalance', () {
        final result = InsightRuleEngine.isHealthyFinance(
          imbalanceSummary,
          hasExcessiveCategories: false,
        );

        expect(result, isFalse);
      });
    });

    group('checkSavingsPotential', () {
      test('should return savings percentage when potential exists', () {
        final result = InsightRuleEngine.checkSavingsPotential(healthySummary);

        expect(result, isNotNull);
        expect(result!, greaterThan(0));
      });

      test('should return null when no income', () {
        final noIncome = MonthlySummaryEntity(
          yearMonth: '2024-03',
          totalIncome: 0,
          totalExpense: 0,
          balance: 0,
          transactionCount: 5,
          createdAt: DateTime.now(),
        );

        final result = InsightRuleEngine.checkSavingsPotential(noIncome);
        expect(result, isNull);
      });

      test('should return null when negative balance', () {
        final result = InsightRuleEngine.checkSavingsPotential(imbalanceSummary);
        expect(result, isNull);
      });
    });

    group('calculateExpenseRatio', () {
      test('should calculate expense ratio correctly', () {
        final result = InsightRuleEngine.calculateExpenseRatio(healthySummary);

        // 700000 / 1000000 = 0.7 = 70%
        expect(result, equals(70.0));
      });

      test('should return 0 when no income', () {
        final noIncome = MonthlySummaryEntity(
          yearMonth: '2024-03',
          totalIncome: 0,
          totalExpense: 50000,
          balance: -50000,
          transactionCount: 5,
          createdAt: DateTime.now(),
        );

        final result = InsightRuleEngine.calculateExpenseRatio(noIncome);
        expect(result, equals(0.0));
      });
    });

    group('getExpenseLevel', () {
      test('should return nearEmpty for ratio >= 90', () {
        final result = InsightRuleEngine.getExpenseLevel(95.0);
        expect(result, equals(ExpenseLevel.nearEmpty));
      });

      test('should return high for ratio >= 70', () {
        final result = InsightRuleEngine.getExpenseLevel(75.0);
        expect(result, equals(ExpenseLevel.high));
      });

      test('should return moderate for ratio >= 50', () {
        final result = InsightRuleEngine.getExpenseLevel(60.0);
        expect(result, equals(ExpenseLevel.moderate));
      });

      test('should return low for ratio < 50', () {
        final result = InsightRuleEngine.getExpenseLevel(30.0);
        expect(result, equals(ExpenseLevel.low));
      });
    });
  });
}
