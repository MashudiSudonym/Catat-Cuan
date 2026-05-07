import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';

void main() {
  group('DatabaseHelper table name constants', () {
    test('tableBudgets equals "budgets"', () {
      expect(DatabaseHelper.tableBudgets, 'budgets');
    });

    test('tableSavingsGoals equals "savings_goals"', () {
      expect(DatabaseHelper.tableSavingsGoals, 'savings_goals');
    });

    test('tableGoalContributions equals "goal_contributions"', () {
      expect(DatabaseHelper.tableGoalContributions, 'goal_contributions');
    });
  });

  group('DatabaseSchemaManager version', () {
    test('currentVersion equals 3', () {
      expect(DatabaseSchemaManager.currentVersion, 3);
    });
  });

  group('BudgetFields', () {
    test('has all required fields', () {
      expect(BudgetFields.id, 'id');
      expect(BudgetFields.categoryId, 'category_id');
      expect(BudgetFields.year, 'year');
      expect(BudgetFields.month, 'month');
      expect(BudgetFields.amount, 'amount');
      expect(BudgetFields.createdAt, 'created_at');
      expect(BudgetFields.updatedAt, 'updated_at');
    });
  });

  group('SavingsGoalFields', () {
    test('has all required fields', () {
      expect(SavingsGoalFields.id, 'id');
      expect(SavingsGoalFields.name, 'name');
      expect(SavingsGoalFields.targetAmount, 'target_amount');
      expect(SavingsGoalFields.currentAmount, 'current_amount');
      expect(SavingsGoalFields.targetDate, 'target_date');
      expect(SavingsGoalFields.icon, 'icon');
      expect(SavingsGoalFields.color, 'color');
      expect(SavingsGoalFields.status, 'status');
      expect(SavingsGoalFields.createdAt, 'created_at');
      expect(SavingsGoalFields.updatedAt, 'updated_at');
    });
  });

  group('GoalContributionFields', () {
    test('has all required fields', () {
      expect(GoalContributionFields.id, 'id');
      expect(GoalContributionFields.goalId, 'goal_id');
      expect(GoalContributionFields.amount, 'amount');
      expect(GoalContributionFields.runningBalance, 'running_balance');
      expect(GoalContributionFields.note, 'note');
      expect(GoalContributionFields.date, 'date');
      expect(GoalContributionFields.createdAt, 'created_at');
    });
  });
}
