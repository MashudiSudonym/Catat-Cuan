import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/entities/budget_entity.dart';
import 'package:catat_cuan/domain/entities/budget_with_spent_entity.dart';
import 'package:catat_cuan/domain/entities/budget_alert_status_entity.dart';

void main() {
  group('BudgetEntity', () {
    group('Entity creation', () {
      test('should create entity with all required fields', () {
        final now = DateTime.now();
        final entity = BudgetEntity(
          id: 1,
          categoryId: 5,
          year: 2026,
          month: 5,
          amount: 500000.0,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.id, equals(1));
        expect(entity.categoryId, equals(5));
        expect(entity.year, equals(2026));
        expect(entity.month, equals(5));
        expect(entity.amount, equals(500000.0));
        expect(entity.createdAt, equals(now));
        expect(entity.updatedAt, equals(now));
      });

      test('should create entity without ID (for new budgets)', () {
        final now = DateTime.now();
        final entity = BudgetEntity(
          categoryId: 3,
          year: 2026,
          month: 6,
          amount: 250000.0,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.id, isNull);
        expect(entity.categoryId, equals(3));
      });

      test('should be immutable with copyWith', () {
        final now = DateTime.now();
        final entity = BudgetEntity(
          id: 1,
          categoryId: 5,
          year: 2026,
          month: 5,
          amount: 500000.0,
          createdAt: now,
          updatedAt: now,
        );

        final updated = entity.copyWith(amount: 600000.0);

        expect(entity.amount, equals(500000.0));
        expect(updated.amount, equals(600000.0));
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        final now = DateTime.now();
        final entity1 = BudgetEntity(
          id: 1,
          categoryId: 5,
          year: 2026,
          month: 5,
          amount: 500000.0,
          createdAt: now,
          updatedAt: now,
        );

        final entity2 = BudgetEntity(
          id: 1,
          categoryId: 5,
          year: 2026,
          month: 5,
          amount: 500000.0,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity1, equals(entity2));
      });

      test('should not be equal when amount differs', () {
        final now = DateTime.now();
        final entity1 = BudgetEntity(
          id: 1,
          categoryId: 5,
          year: 2026,
          month: 5,
          amount: 500000.0,
          createdAt: now,
          updatedAt: now,
        );

        final entity2 = BudgetEntity(
          id: 1,
          categoryId: 5,
          year: 2026,
          month: 5,
          amount: 600000.0,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity1, isNot(equals(entity2)));
      });
    });

    group('Validation', () {
      test('should accept valid month values (1-12)', () {
        final now = DateTime.now();
        for (var month = 1; month <= 12; month++) {
          final entity = BudgetEntity(
            categoryId: 1,
            year: 2026,
            month: month,
            amount: 100000.0,
            createdAt: now,
            updatedAt: now,
          );
          expect(entity.month, equals(month));
        }
      });

      test('should accept positive amount', () {
        final now = DateTime.now();
        final entity = BudgetEntity(
          categoryId: 1,
          year: 2026,
          month: 5,
          amount: 0.01,
          createdAt: now,
          updatedAt: now,
        );

        expect(entity.amount, equals(0.01));
      });
    });
  });

  group('BudgetWithSpentEntity', () {
    group('Entity creation', () {
      test('should create entity with budget and spent info', () {
        final now = DateTime.now();
        final budget = BudgetEntity(
          id: 1,
          categoryId: 5,
          year: 2026,
          month: 5,
          amount: 500000.0,
          createdAt: now,
          updatedAt: now,
        );

        final entity = BudgetWithSpentEntity(
          budget: budget,
          spentAmount: 250000.0,
          progressPercent: 50.0,
          remainingAmount: 250000.0,
        );

        expect(entity.budget, equals(budget));
        expect(entity.spentAmount, equals(250000.0));
        expect(entity.progressPercent, equals(50.0));
        expect(entity.remainingAmount, equals(250000.0));
      });

      test('should default spent values to zero', () {
        final now = DateTime.now();
        final budget = BudgetEntity(
          id: 1,
          categoryId: 5,
          year: 2026,
          month: 5,
          amount: 500000.0,
          createdAt: now,
          updatedAt: now,
        );

        final entity = BudgetWithSpentEntity(budget: budget);

        expect(entity.spentAmount, equals(0.0));
        expect(entity.progressPercent, equals(0.0));
        expect(entity.remainingAmount, equals(0.0));
      });
    });

    group('progressColor', () {
      test('should return green when progress is 0-75%', () {
        final now = DateTime.now();
        final budget = BudgetEntity(
          id: 1,
          categoryId: 5,
          year: 2026,
          month: 5,
          amount: 500000.0,
          createdAt: now,
          updatedAt: now,
        );

        final entity = BudgetWithSpentEntity(
          budget: budget,
          spentAmount: 250000.0,
          progressPercent: 50.0,
          remainingAmount: 250000.0,
        );

        expect(entity.progressColor, equals('green'));
      });

      test('should return yellow when progress is 75-100%', () {
        final now = DateTime.now();
        final budget = BudgetEntity(
          id: 1,
          categoryId: 5,
          year: 2026,
          month: 5,
          amount: 500000.0,
          createdAt: now,
          updatedAt: now,
        );

        final entity = BudgetWithSpentEntity(
          budget: budget,
          spentAmount: 425000.0,
          progressPercent: 85.0,
          remainingAmount: 75000.0,
        );

        expect(entity.progressColor, equals('yellow'));
      });

      test('should return red when progress is over 100%', () {
        final now = DateTime.now();
        final budget = BudgetEntity(
          id: 1,
          categoryId: 5,
          year: 2026,
          month: 5,
          amount: 500000.0,
          createdAt: now,
          updatedAt: now,
        );

        final entity = BudgetWithSpentEntity(
          budget: budget,
          spentAmount: 550000.0,
          progressPercent: 110.0,
          remainingAmount: -50000.0,
        );

        expect(entity.progressColor, equals('red'));
      });

      test('should return green at exactly 0%', () {
        final now = DateTime.now();
        final budget = BudgetEntity(
          id: 1,
          categoryId: 5,
          year: 2026,
          month: 5,
          amount: 500000.0,
          createdAt: now,
          updatedAt: now,
        );

        final entity = BudgetWithSpentEntity(
          budget: budget,
          spentAmount: 0.0,
          progressPercent: 0.0,
          remainingAmount: 500000.0,
        );

        expect(entity.progressColor, equals('green'));
      });

      test('should return green at exactly 75%', () {
        final now = DateTime.now();
        final budget = BudgetEntity(
          id: 1,
          categoryId: 5,
          year: 2026,
          month: 5,
          amount: 500000.0,
          createdAt: now,
          updatedAt: now,
        );

        // Exactly 75% is still green (boundary: 75-100% is yellow, exclusive at lower bound)
        final entity = BudgetWithSpentEntity(
          budget: budget,
          spentAmount: 375000.0,
          progressPercent: 75.0,
          remainingAmount: 125000.0,
        );

        expect(entity.progressColor, equals('green'));
      });

      test('should return yellow at exactly 75.01%', () {
        final now = DateTime.now();
        final budget = BudgetEntity(
          id: 1,
          categoryId: 5,
          year: 2026,
          month: 5,
          amount: 500000.0,
          createdAt: now,
          updatedAt: now,
        );

        final entity = BudgetWithSpentEntity(
          budget: budget,
          spentAmount: 375050.0,
          progressPercent: 75.01,
          remainingAmount: 124950.0,
        );

        expect(entity.progressColor, equals('yellow'));
      });

      test('should return yellow at exactly 100%', () {
        final now = DateTime.now();
        final budget = BudgetEntity(
          id: 1,
          categoryId: 5,
          year: 2026,
          month: 5,
          amount: 500000.0,
          createdAt: now,
          updatedAt: now,
        );

        final entity = BudgetWithSpentEntity(
          budget: budget,
          spentAmount: 500000.0,
          progressPercent: 100.0,
          remainingAmount: 0.0,
        );

        expect(entity.progressColor, equals('yellow'));
      });

      test('should return red at exactly 100.01%', () {
        final now = DateTime.now();
        final budget = BudgetEntity(
          id: 1,
          categoryId: 5,
          year: 2026,
          month: 5,
          amount: 500000.0,
          createdAt: now,
          updatedAt: now,
        );

        final entity = BudgetWithSpentEntity(
          budget: budget,
          spentAmount: 500050.0,
          progressPercent: 100.01,
          remainingAmount: -50.0,
        );

        expect(entity.progressColor, equals('red'));
      });
    });
  });

  group('BudgetAlertStatus', () {
    group('Entity creation', () {
      test('should create entity with budgetId', () {
        final entity = BudgetAlertStatus(budgetId: 1);

        expect(entity.budgetId, equals(1));
        expect(entity.warningShownAt, isNull);
        expect(entity.limitShownAt, isNull);
        expect(entity.overShownAt, isNull);
      });

      test('should create entity with alert dates', () {
        final warningTime = DateTime(2026, 5, 7, 10, 0);
        final limitTime = DateTime(2026, 5, 7, 14, 0);
        final overTime = DateTime(2026, 5, 7, 16, 0);

        final entity = BudgetAlertStatus(
          budgetId: 1,
          warningShownAt: warningTime,
          limitShownAt: limitTime,
          overShownAt: overTime,
        );

        expect(entity.warningShownAt, equals(warningTime));
        expect(entity.limitShownAt, equals(limitTime));
        expect(entity.overShownAt, equals(overTime));
      });

      test('should be immutable with copyWith', () {
        final entity = BudgetAlertStatus(budgetId: 1);

        final updated = entity.copyWith(
          warningShownAt: DateTime(2026, 5, 7, 10, 0),
        );

        expect(entity.warningShownAt, isNull);
        expect(updated.warningShownAt, isNotNull);
      });
    });

    group('Default values', () {
      test('should have null alert dates by default', () {
        final entity = BudgetAlertStatus(budgetId: 5);

        expect(entity.warningShownAt, isNull);
        expect(entity.limitShownAt, isNull);
        expect(entity.overShownAt, isNull);
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        final warningTime = DateTime(2026, 5, 7, 10, 0);

        final entity1 = BudgetAlertStatus(
          budgetId: 1,
          warningShownAt: warningTime,
        );

        final entity2 = BudgetAlertStatus(
          budgetId: 1,
          warningShownAt: warningTime,
        );

        expect(entity1, equals(entity2));
      });

      test('should not be equal when budgetId differs', () {
        final entity1 = BudgetAlertStatus(budgetId: 1);
        final entity2 = BudgetAlertStatus(budgetId: 2);

        expect(entity1, isNot(equals(entity2)));
      });
    });
  });
}
