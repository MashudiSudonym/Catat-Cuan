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
  static const int currentVersion = 2;

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

    // Add future migrations here
    // if (oldVersion < 3) { ... }
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
