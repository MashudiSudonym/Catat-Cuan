import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/services/analyzers/financial_health_analyzer.dart';

void main() {
  group('FinancialHealthAnalyzer', () {
    group('calculateExpensePercentage', () {
      test('should return correct percentage when income > expense', () {
        final result = FinancialHealthAnalyzer.calculateExpensePercentage(
          totalExpense: 750,
          totalIncome: 1000,
        );
        expect(result, equals(75.0));
      });

      test('should return correct percentage when expense > income', () {
        final result = FinancialHealthAnalyzer.calculateExpensePercentage(
          totalExpense: 1200,
          totalIncome: 1000,
        );
        expect(result, equals(120.0));
      });

      test('should return 0 when totalIncome is 0', () {
        final result = FinancialHealthAnalyzer.calculateExpensePercentage(
          totalExpense: 100,
          totalIncome: 0,
        );
        expect(result, equals(0));
      });

      test('should return 0 when both are 0', () {
        final result = FinancialHealthAnalyzer.calculateExpensePercentage(
          totalExpense: 0,
          totalIncome: 0,
        );
        expect(result, equals(0));
      });

      test('should handle large values', () {
        final result = FinancialHealthAnalyzer.calculateExpensePercentage(
          totalExpense: 9999999,
          totalIncome: 10000000,
        );
        expect(result, closeTo(99.99999, 0.00001));
      });

      test('should return 100 when expense equals income', () {
        final result = FinancialHealthAnalyzer.calculateExpensePercentage(
          totalExpense: 1000,
          totalIncome: 1000,
        );
        expect(result, equals(100.0));
      });
    });

    group('calculateBalancePercentage', () {
      test('should return correct percentage when balance positive', () {
        final result = FinancialHealthAnalyzer.calculateBalancePercentage(
          balance: 250,
          totalIncome: 1000,
        );
        expect(result, equals(25.0));
      });

      test('should return 0 when totalIncome is 0', () {
        final result = FinancialHealthAnalyzer.calculateBalancePercentage(
          balance: 100,
          totalIncome: 0,
        );
        expect(result, equals(0));
      });

      test('should return 0 when both are 0', () {
        final result = FinancialHealthAnalyzer.calculateBalancePercentage(
          balance: 0,
          totalIncome: 0,
        );
        expect(result, equals(0));
      });

      test('should return negative percentage when balance negative', () {
        final result = FinancialHealthAnalyzer.calculateBalancePercentage(
          balance: -200,
          totalIncome: 1000,
        );
        expect(result, equals(-20.0));
      });

      test('should return 0 when balance is 0', () {
        final result = FinancialHealthAnalyzer.calculateBalancePercentage(
          balance: 0,
          totalIncome: 1000,
        );
        expect(result, equals(0));
      });
    });

    group('isHealthyFinancial', () {
      test('should return true when balance >= 20% of income', () {
        final result = FinancialHealthAnalyzer.isHealthyFinancial(
          balance: 200,
          totalIncome: 1000,
        );
        expect(result, isTrue);
      });

      test('should return true when balance equals exactly 20% threshold', () {
        final result = FinancialHealthAnalyzer.isHealthyFinancial(
          balance: 200,
          totalIncome: 1000,
        );
        expect(result, isTrue);
      });

      test('should return true when balance is well above threshold', () {
        final result = FinancialHealthAnalyzer.isHealthyFinancial(
          balance: 500,
          totalIncome: 1000,
        );
        expect(result, isTrue);
      });

      test('should return false when balance below 20% threshold', () {
        final result = FinancialHealthAnalyzer.isHealthyFinancial(
          balance: 150,
          totalIncome: 1000,
        );
        expect(result, isFalse);
      });

      test('should return false when balance is 0', () {
        final result = FinancialHealthAnalyzer.isHealthyFinancial(
          balance: 0,
          totalIncome: 1000,
        );
        expect(result, isFalse);
      });

      test('should return false when balance is negative', () {
        final result = FinancialHealthAnalyzer.isHealthyFinancial(
          balance: -100,
          totalIncome: 1000,
        );
        expect(result, isFalse);
      });

      test('should return false when totalIncome is 0', () {
        final result = FinancialHealthAnalyzer.isHealthyFinancial(
          balance: 100,
          totalIncome: 0,
        );
        expect(result, isFalse);
      });
    });

    group('hasImbalance', () {
      test('should return true when balance is negative', () {
        final result = FinancialHealthAnalyzer.hasImbalance(
          balance: -100,
        );
        expect(result, isTrue);
      });

      test('should return false when balance is 0', () {
        final result = FinancialHealthAnalyzer.hasImbalance(
          balance: 0,
        );
        expect(result, isFalse);
      });

      test('should return false when balance is positive', () {
        final result = FinancialHealthAnalyzer.hasImbalance(
          balance: 100,
        );
        expect(result, isFalse);
      });

      test('should return false when balance is large positive', () {
        final result = FinancialHealthAnalyzer.hasImbalance(
          balance: 999999,
        );
        expect(result, isFalse);
      });
    });

    group('healthyThreshold', () {
      test('should return 20.0 as healthy threshold', () {
        expect(FinancialHealthAnalyzer.healthyThreshold, equals(20.0));
      });
    });
  });
}
