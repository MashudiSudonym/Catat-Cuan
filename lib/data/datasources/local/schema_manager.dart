import 'package:sqflite/sqflite.dart';
import 'package:catat_cuan/data/datasources/local/database_helper.dart';

/// Database schema manager following Single Responsibility Principle
///
/// This class is responsible only for database schema operations:
/// - Creating tables during initial database creation
/// - Handling schema migrations between versions
///
/// The DatabaseHelper handles connection and query operations.
class DatabaseSchemaManager {
  DatabaseSchemaManager._(); // Private constructor

  /// Current database version
  static const int currentVersion = 3;

  /// Creates all tables during initial database creation
  ///
  /// This is called when the database is first created.
  /// Tables are created in the correct order to satisfy foreign key constraints.
  static Future<void> onCreate(Database db, int version) async {
    // Create categories table first (transactions reference it)
    await _createCategoriesTable(db);
    await _createCategoriesIndexes(db);

    // Create transactions table
    await _createTransactionsTable(db);
    await _createTransactionsIndexes(db);

    // Phase 2+ tables (v3)
    await _createBudgetsTable(db);
    await _createBudgetsIndexes(db);
    await _createSavingsGoalsTable(db);
    await _createSavingsGoalsIndexes(db);
    await _createGoalContributionsTable(db);
    await _createGoalContributionsIndexes(db);
  }

  /// Handles database upgrades when version changes
  ///
  /// This is called when the database version is increased.
  /// Implement migration logic for each version step.
  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration from version 1 to 2: Add index for monthly aggregation
    if (oldVersion < 2) {
      await _createMonthlyAggregationIndex(db);
    }

    // Migration from version 2 to 3: Add budgets, savings_goals, goal_contributions
    // Per D-18: simple incremental migration, no existing data modified
    if (oldVersion < 3) {
      await _createBudgetsTable(db);
      await _createBudgetsIndexes(db);
      await _createSavingsGoalsTable(db);
      await _createSavingsGoalsIndexes(db);
      await _createGoalContributionsTable(db);
      await _createGoalContributionsIndexes(db);
    }
  }

  /// Creates the categories table
  static Future<void> _createCategoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseHelper.tableCategories} (
        ${CategoryFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${CategoryFields.name} TEXT NOT NULL,
        ${CategoryFields.type} TEXT NOT NULL CHECK(${CategoryFields.type} IN ('income', 'expense')),
        ${CategoryFields.color} TEXT NOT NULL,
        ${CategoryFields.icon} TEXT,
        ${CategoryFields.sortOrder} INTEGER NOT NULL DEFAULT 0,
        ${CategoryFields.isActive} INTEGER NOT NULL DEFAULT 1,
        ${CategoryFields.createdAt} TEXT NOT NULL,
        ${CategoryFields.updatedAt} TEXT NOT NULL
      )
    ''');
  }

  /// Creates indexes for the categories table
  static Future<void> _createCategoriesIndexes(Database db) async {
    await db.execute('''
      CREATE INDEX idx_categories_type ON ${DatabaseHelper.tableCategories}(${CategoryFields.type})
    ''');
    await db.execute('''
      CREATE INDEX idx_categories_is_active ON ${DatabaseHelper.tableCategories}(${CategoryFields.isActive})
    ''');
  }

  /// Creates the transactions table
  static Future<void> _createTransactionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseHelper.tableTransactions} (
        ${TransactionFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${TransactionFields.amount} REAL NOT NULL CHECK(${TransactionFields.amount} > 0),
        ${TransactionFields.type} TEXT NOT NULL CHECK(${TransactionFields.type} IN ('income', 'expense')),
        ${TransactionFields.dateTime} TEXT NOT NULL,
        ${TransactionFields.categoryId} INTEGER NOT NULL,
        ${TransactionFields.note} TEXT,
        ${TransactionFields.createdAt} TEXT NOT NULL,
        ${TransactionFields.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${TransactionFields.categoryId}) REFERENCES ${DatabaseHelper.tableCategories}(${CategoryFields.id}) ON DELETE RESTRICT
      )
    ''');
  }

  /// Creates indexes for the transactions table
  ///
  /// Indexes are created following NFR-LOG-004 for query performance.
  static Future<void> _createTransactionsIndexes(Database db) async {
    await db.execute('''
      CREATE INDEX idx_transactions_date_time ON ${DatabaseHelper.tableTransactions}(${TransactionFields.dateTime} DESC)
    ''');
    await db.execute('''
      CREATE INDEX idx_transactions_category_id ON ${DatabaseHelper.tableTransactions}(${TransactionFields.categoryId})
    ''');
    await db.execute('''
      CREATE INDEX idx_transactions_type ON ${DatabaseHelper.tableTransactions}(${TransactionFields.type})
    ''');
    await db.execute('''
      CREATE INDEX idx_transactions_date_type ON ${DatabaseHelper.tableTransactions}(${TransactionFields.dateTime} DESC, ${TransactionFields.type})
    ''');
  }

  /// Creates index for monthly aggregation queries
  ///
  /// This index optimizes queries that aggregate transactions by month.
  static Future<void> _createMonthlyAggregationIndex(Database db) async {
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_transactions_month_type ON ${DatabaseHelper.tableTransactions}(strftime('%Y-%m', ${TransactionFields.dateTime}), ${TransactionFields.type} DESC)
    ''');
  }

  /// Creates the budgets table
  ///
  /// Per D-12: UNIQUE(category_id, year, month) prevents duplicate budgets.
  /// Per D-17: Expense-only constraint enforced at application/repository layer
  /// (SQLite does not support subqueries in CHECK constraints).
  static Future<void> _createBudgetsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseHelper.tableBudgets} (
        ${BudgetFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${BudgetFields.categoryId} INTEGER NOT NULL,
        ${BudgetFields.year} INTEGER NOT NULL,
        ${BudgetFields.month} INTEGER NOT NULL CHECK(${BudgetFields.month} BETWEEN 1 AND 12),
        ${BudgetFields.amount} REAL NOT NULL CHECK(${BudgetFields.amount} > 0),
        ${BudgetFields.createdAt} TEXT NOT NULL,
        ${BudgetFields.updatedAt} TEXT NOT NULL,
        FOREIGN KEY (${BudgetFields.categoryId}) REFERENCES ${DatabaseHelper.tableCategories}(${CategoryFields.id}) ON DELETE CASCADE,
        UNIQUE (${BudgetFields.categoryId}, ${BudgetFields.year}, ${BudgetFields.month})
      )
    ''');
  }

  /// Creates indexes for the budgets table
  static Future<void> _createBudgetsIndexes(Database db) async {
    await db.execute('''
      CREATE INDEX idx_budgets_year_month ON ${DatabaseHelper.tableBudgets}(${BudgetFields.year}, ${BudgetFields.month})
    ''');
  }

  /// Creates the savings_goals table
  ///
  /// Per D-13: current_amount is stored and kept in sync (not computed).
  /// Per D-15: status CHECK constraint limits to active, completed, cancelled.
  static Future<void> _createSavingsGoalsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseHelper.tableSavingsGoals} (
        ${SavingsGoalFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${SavingsGoalFields.name} TEXT NOT NULL,
        ${SavingsGoalFields.targetAmount} REAL NOT NULL CHECK(${SavingsGoalFields.targetAmount} > 0),
        ${SavingsGoalFields.currentAmount} REAL NOT NULL DEFAULT 0,
        ${SavingsGoalFields.targetDate} TEXT,
        ${SavingsGoalFields.icon} TEXT,
        ${SavingsGoalFields.color} TEXT,
        ${SavingsGoalFields.status} TEXT NOT NULL DEFAULT 'active' CHECK(${SavingsGoalFields.status} IN ('active', 'completed', 'cancelled')),
        ${SavingsGoalFields.createdAt} TEXT NOT NULL,
        ${SavingsGoalFields.updatedAt} TEXT NOT NULL
      )
    ''');
  }

  /// Creates indexes for the savings_goals table
  static Future<void> _createSavingsGoalsIndexes(Database db) async {
    await db.execute('''
      CREATE INDEX idx_savings_goals_status ON ${DatabaseHelper.tableSavingsGoals}(${SavingsGoalFields.status})
    ''');
  }

  /// Creates the goal_contributions table
  ///
  /// Per D-14: positive=contribution, negative=withdrawal.
  /// Per D-16: running_balance stored and updated atomically.
  static Future<void> _createGoalContributionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseHelper.tableGoalContributions} (
        ${GoalContributionFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${GoalContributionFields.goalId} INTEGER NOT NULL,
        ${GoalContributionFields.amount} REAL NOT NULL,
        ${GoalContributionFields.runningBalance} REAL NOT NULL,
        ${GoalContributionFields.note} TEXT,
        ${GoalContributionFields.date} TEXT NOT NULL,
        ${GoalContributionFields.createdAt} TEXT NOT NULL,
        FOREIGN KEY (${GoalContributionFields.goalId}) REFERENCES ${DatabaseHelper.tableSavingsGoals}(${SavingsGoalFields.id}) ON DELETE CASCADE
      )
    ''');
  }

  /// Creates indexes for the goal_contributions table
  static Future<void> _createGoalContributionsIndexes(Database db) async {
    await db.execute('''
      CREATE INDEX idx_goal_contributions_goal_id ON ${DatabaseHelper.tableGoalContributions}(${GoalContributionFields.goalId})
    ''');
  }
}

/// Field names for the transactions table
class TransactionFields {
  static const String id = 'id';
  static const String amount = 'amount';
  static const String type = 'type';
  static const String dateTime = 'date_time';
  static const String categoryId = 'category_id';
  static const String note = 'note';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

/// Field names for the categories table
class CategoryFields {
  static const String id = 'id';
  static const String name = 'name';
  static const String type = 'type';
  static const String color = 'color';
  static const String icon = 'icon';
  static const String sortOrder = 'sort_order';
  static const String isActive = 'is_active';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

/// Field names for the budgets table
class BudgetFields {
  static const String id = 'id';
  static const String categoryId = 'category_id';
  static const String year = 'year';
  static const String month = 'month';
  static const String amount = 'amount';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

/// Field names for the savings_goals table
class SavingsGoalFields {
  static const String id = 'id';
  static const String name = 'name';
  static const String targetAmount = 'target_amount';
  static const String currentAmount = 'current_amount';
  static const String targetDate = 'target_date';
  static const String icon = 'icon';
  static const String color = 'color';
  static const String status = 'status';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

/// Field names for the goal_contributions table
class GoalContributionFields {
  static const String id = 'id';
  static const String goalId = 'goal_id';
  static const String amount = 'amount';
  static const String runningBalance = 'running_balance';
  static const String note = 'note';
  static const String date = 'date';
  static const String createdAt = 'created_at';
}
