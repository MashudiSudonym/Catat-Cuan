import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/entities/savings_goal_entity.dart';
import 'package:catat_cuan/domain/entities/goal_contribution_entity.dart';
import 'package:catat_cuan/domain/entities/savings_goal_with_progress_entity.dart';

void main() {
  group('SavingsGoalEntity', () {
    test('creates with required fields and defaults', () {
      final now = DateTime(2026, 5, 9);
      final goal = SavingsGoalEntity(
        name: 'iPhone Baru',
        targetAmount: 15000000.0,
        createdAt: now,
        updatedAt: now,
      );

      expect(goal.name, equals('iPhone Baru'));
      expect(goal.targetAmount, equals(15000000.0));
      expect(goal.currentAmount, equals(0.0));
      expect(goal.status, equals('active'));
      expect(goal.targetDate, isNull);
      expect(goal.icon, isNull);
      expect(goal.color, isNull);
      expect(goal.id, isNull);
    });

    test('creates with all fields', () {
      final deadline = DateTime(2026, 12, 31);
      final now = DateTime(2026, 5, 9);
      final goal = SavingsGoalEntity(
        id: 1,
        name: 'Liburan Bali',
        targetAmount: 5000000.0,
        currentAmount: 2000000.0,
        targetDate: deadline,
        icon: 'savings',
        color: '#FF10B981',
        status: 'active',
        createdAt: now,
        updatedAt: now,
      );

      expect(goal.id, equals(1));
      expect(goal.name, equals('Liburan Bali'));
      expect(goal.targetAmount, equals(5000000.0));
      expect(goal.currentAmount, equals(2000000.0));
      expect(goal.targetDate, equals(deadline));
      expect(goal.icon, equals('savings'));
      expect(goal.color, equals('#FF10B981'));
      expect(goal.status, equals('active'));
    });

    test('targetAmount validation is enforced at repository/DB level', () {
      final zeroGoal = SavingsGoalEntity(
        name: 'Zero Goal',
        targetAmount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(zeroGoal.targetAmount, equals(0));
    });
  });

  group('SavingsGoalWithProgressEntity', () {
    SavingsGoalWithProgressEntity createProgressGoal({
      double targetAmount = 1000000.0,
      double currentAmount = 0.0,
      DateTime? targetDate,
    }) {
      final now = DateTime(2026, 5, 9);
      return SavingsGoalWithProgressEntity(
        goal: SavingsGoalEntity(
          id: 1,
          name: 'Test Goal',
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          targetDate: targetDate,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    test('progressPercentage is 0% when nothing saved', () {
      final progress = createProgressGoal();
      expect(progress.progressPercentage, equals(0.0));
    });

    test('progressPercentage calculates correctly at 50%', () {
      final progress = createProgressGoal(currentAmount: 500000.0);
      expect(progress.progressPercentage, equals(50.0));
    });

    test('progressPercentage is 100% when target met', () {
      final progress = createProgressGoal(currentAmount: 1000000.0);
      expect(progress.progressPercentage, equals(100.0));
    });

    test('progressPercentage capped at 100% when exceeded', () {
      final progress = createProgressGoal(currentAmount: 1500000.0);
      expect(progress.progressPercentage, equals(100.0));
    });

    test('progressColor returns red for 0-25%', () {
      final progress = createProgressGoal(currentAmount: 100000.0);
      final color = progress.getProgressColor(false);
      expect(color, equals(const Color(0xFFEF4444)));
    });

    test('progressColor returns orange for 25-50%', () {
      final progress = createProgressGoal(currentAmount: 300000.0);
      final color = progress.getProgressColor(false);
      expect(color, equals(const Color(0xFFF97316)));
    });

    test('progressColor returns yellow for 50-75%', () {
      final progress = createProgressGoal(currentAmount: 600000.0);
      final color = progress.getProgressColor(false);
      expect(color, equals(const Color(0xFFEAB308)));
    });

    test('progressColor returns green for 75-100%', () {
      final progress = createProgressGoal(currentAmount: 800000.0);
      final color = progress.getProgressColor(false);
      expect(color, equals(const Color(0xFF10B981)));
    });

    test('progressColor returns dark mode green for 75-100%', () {
      final progress = createProgressGoal(currentAmount: 800000.0);
      final color = progress.getProgressColor(true);
      expect(color, equals(const Color(0xFF34D399)));
    });

    test('progressColor returns dark mode red for 0-25%', () {
      final progress = createProgressGoal(currentAmount: 0.0);
      final color = progress.getProgressColor(true);
      expect(color, equals(const Color(0xFFF87171)));
    });

    test('isCompleted is true when current >= target', () {
      final progress = createProgressGoal(currentAmount: 1000000.0);
      expect(progress.isCompleted, isTrue);
    });

    test('isCompleted is false when current < target', () {
      final progress = createProgressGoal(currentAmount: 500000.0);
      expect(progress.isCompleted, isFalse);
    });

    test('daysRemaining returns positive value for future deadline', () {
      final deadline = DateTime.now().add(const Duration(days: 30));
      final progress = createProgressGoal(targetDate: deadline);
      expect(progress.daysRemaining, greaterThan(28));
      expect(progress.daysRemaining, lessThanOrEqualTo(30));
    });

    test('daysRemaining returns negative value for past deadline', () {
      final pastDeadline = DateTime.now().subtract(const Duration(days: 5));
      final progress = createProgressGoal(targetDate: pastDeadline);
      expect(progress.daysRemaining, lessThan(0));
    });

    test('daysRemaining is null when no deadline', () {
      final progress = createProgressGoal();
      expect(progress.daysRemaining, isNull);
    });

    test('isOverdue is true when daysRemaining is negative', () {
      final pastDeadline = DateTime.now().subtract(const Duration(days: 5));
      final progress = createProgressGoal(targetDate: pastDeadline);
      expect(progress.isOverdue, isTrue);
    });

    test('isOverdue is false when no deadline', () {
      final progress = createProgressGoal();
      expect(progress.isOverdue, isFalse);
    });
  });

  group('GoalContributionEntity', () {
    test('positive amount is a contribution', () {
      final contribution = GoalContributionEntity(
        id: 1,
        goalId: 1,
        amount: 500000.0,
        runningBalance: 500000.0,
        date: DateTime(2026, 5, 9),
        createdAt: DateTime(2026, 5, 9),
      );

      expect(contribution.isContribution, isTrue);
      expect(contribution.isWithdrawal, isFalse);
    });

    test('negative amount is a withdrawal', () {
      final withdrawal = GoalContributionEntity(
        id: 2,
        goalId: 1,
        amount: -200000.0,
        runningBalance: 300000.0,
        note: 'Emergency',
        date: DateTime(2026, 5, 10),
        createdAt: DateTime(2026, 5, 10),
      );

      expect(withdrawal.isContribution, isFalse);
      expect(withdrawal.isWithdrawal, isTrue);
      expect(withdrawal.note, equals('Emergency'));
    });

    test('zero amount validation is enforced at repository level', () {
      final zeroContrib = GoalContributionEntity(
        id: 3,
        goalId: 1,
        amount: 0,
        runningBalance: 0,
        date: DateTime(2026, 5, 9),
        createdAt: DateTime(2026, 5, 9),
      );
      expect(zeroContrib.isContribution, isFalse);
      expect(zeroContrib.isWithdrawal, isFalse);
    });
  });
}
