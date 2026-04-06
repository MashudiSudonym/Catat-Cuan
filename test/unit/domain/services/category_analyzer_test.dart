import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/services/analyzers/category_analyzer.dart';

void main() {
  group('CategoryAnalyzer', () {
    group('isExcessiveCategory', () {
      group('with default threshold (40%)', () {
        test('should return true when percentage exceeds default threshold', () {
          final result = CategoryAnalyzer.isExcessiveCategory(
            percentage: 45.0,
          );
          expect(result, isTrue);
        });

        test('should return false when percentage equals default threshold', () {
          final result = CategoryAnalyzer.isExcessiveCategory(
            percentage: 40.0,
          );
          expect(result, isFalse);
        });

        test('should return false when percentage below default threshold', () {
          final result = CategoryAnalyzer.isExcessiveCategory(
            percentage: 35.0,
          );
          expect(result, isFalse);
        });

        test('should return true at 100%', () {
          final result = CategoryAnalyzer.isExcessiveCategory(
            percentage: 100.0,
          );
          expect(result, isTrue);
        });

        test('should return false at 0%', () {
          final result = CategoryAnalyzer.isExcessiveCategory(
            percentage: 0.0,
          );
          expect(result, isFalse);
        });

        test('should handle decimal values', () {
          final result = CategoryAnalyzer.isExcessiveCategory(
            percentage: 40.01,
          );
          expect(result, isTrue);
        });
      });

      group('with custom threshold', () {
        test('should use custom threshold when provided', () {
          final result = CategoryAnalyzer.isExcessiveCategory(
            percentage: 25.0,
            threshold: 30.0,
          );
          expect(result, isFalse);
        });

        test('should return true with custom threshold', () {
          final result = CategoryAnalyzer.isExcessiveCategory(
            percentage: 35.0,
            threshold: 30.0,
          );
          expect(result, isTrue);
        });

        test('should return false at exact custom threshold', () {
          final result = CategoryAnalyzer.isExcessiveCategory(
            percentage: 30.0,
            threshold: 30.0,
          );
          expect(result, isFalse);
        });

        test('should handle very low custom threshold', () {
          final result = CategoryAnalyzer.isExcessiveCategory(
            percentage: 5.0,
            threshold: 10.0,
          );
          expect(result, isFalse);
        });

        test('should handle very high custom threshold', () {
          final result = CategoryAnalyzer.isExcessiveCategory(
            percentage: 95.0,
            threshold: 90.0,
          );
          expect(result, isTrue);
        });
      });
    });

    group('calculateAveragePerTransaction', () {
      test('should return correct average for normal case', () {
        final result = CategoryAnalyzer.calculateAveragePerTransaction(
          totalAmount: 1000,
          transactionCount: 5,
        );
        expect(result, equals(200.0));
      });

      test('should return 0 when transactionCount is 0', () {
        final result = CategoryAnalyzer.calculateAveragePerTransaction(
          totalAmount: 1000,
          transactionCount: 0,
        );
        expect(result, equals(0));
      });

      test('should return totalAmount for single transaction', () {
        final result = CategoryAnalyzer.calculateAveragePerTransaction(
          totalAmount: 500,
          transactionCount: 1,
        );
        expect(result, equals(500.0));
      });

      test('should handle decimal amounts', () {
        final result = CategoryAnalyzer.calculateAveragePerTransaction(
          totalAmount: 100,
          transactionCount: 3,
        );
        expect(result, closeTo(33.33, 0.01));
      });

      test('should return 0 when both values are 0', () {
        final result = CategoryAnalyzer.calculateAveragePerTransaction(
          totalAmount: 0,
          transactionCount: 0,
        );
        expect(result, equals(0));
      });

      test('should return 0 when totalAmount is 0 but transactionCount > 0', () {
        final result = CategoryAnalyzer.calculateAveragePerTransaction(
          totalAmount: 0,
          transactionCount: 5,
        );
        expect(result, equals(0));
      });
    });

    group('formatPercentage', () {
      test('should format integer percentage', () {
        final result = CategoryAnalyzer.formatPercentage(50.0);
        expect(result, equals('50.0%'));
      });

      test('should format decimal percentage', () {
        final result = CategoryAnalyzer.formatPercentage(33.333);
        expect(result, equals('33.3%'));
      });

      test('should format 0%', () {
        final result = CategoryAnalyzer.formatPercentage(0.0);
        expect(result, equals('0.0%'));
      });

      test('should format 100%', () {
        final result = CategoryAnalyzer.formatPercentage(100.0);
        expect(result, equals('100.0%'));
      });

      test('should format very small percentage', () {
        final result = CategoryAnalyzer.formatPercentage(0.01);
        expect(result, equals('0.0%'));
      });

      test('should format very large percentage', () {
        final result = CategoryAnalyzer.formatPercentage(999.99);
        expect(result, equals('1000.0%'));
      });

      test('should round correctly', () {
        final result = CategoryAnalyzer.formatPercentage(45.456);
        expect(result, equals('45.5%'));
      });

      test('should round down correctly', () {
        final result = CategoryAnalyzer.formatPercentage(45.449);
        expect(result, equals('45.4%'));
      });
    });

    group('excessiveThreshold', () {
      test('should return 40.0 as excessive threshold', () {
        expect(CategoryAnalyzer.excessiveThreshold, equals(40.0));
      });
    });
  });
}
