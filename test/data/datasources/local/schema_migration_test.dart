import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';

void main() {
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    if (db.isOpen) {
      await db.close();
    }
  });

  group('Schema v3 onCreate', () {
    setUp(() async {
      db = await openDatabase(
        inMemoryDatabasePath,
        version: DatabaseSchemaManager.currentVersion,
        onCreate: DatabaseSchemaManager.onCreate,
      );
    });

    test('creates all 5 tables on fresh install', () async {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
      );
      final tableNames = tables.map((t) => t['name'] as String).toList();

      expect(tableNames, contains('categories'));
      expect(tableNames, contains('transactions'));
      expect(tableNames, contains('budgets'));
      expect(tableNames, contains('savings_goals'));
      expect(tableNames, contains('goal_contributions'));
    });

    test('budgets table has correct columns', () async {
      final columns = await db.rawQuery("PRAGMA table_info(budgets)");
      final columnNames = columns.map((c) => c['name'] as String).toList();

      expect(columnNames, containsAll([
        'id', 'category_id', 'year', 'month', 'amount', 'created_at', 'updated_at',
      ]));
    });

    test('savings_goals table has correct columns', () async {
      final columns = await db.rawQuery("PRAGMA table_info(savings_goals)");
      final columnNames = columns.map((c) => c['name'] as String).toList();

      expect(columnNames, containsAll([
        'id', 'name', 'target_amount', 'current_amount', 'target_date',
        'icon', 'color', 'status', 'created_at', 'updated_at',
      ]));
    });

    test('goal_contributions table has correct columns', () async {
      final columns = await db.rawQuery("PRAGMA table_info(goal_contributions)");
      final columnNames = columns.map((c) => c['name'] as String).toList();

      expect(columnNames, containsAll([
        'id', 'goal_id', 'amount', 'running_balance', 'note', 'date', 'created_at',
      ]));
    });

    test('budgets table has UNIQUE constraint on (category_id, year, month)', () async {
      // Insert a category first
      await db.insert('categories', {
        'name': 'Food',
        'type': 'expense',
        'color': '#FF0000',
        'icon': 'restaurant',
        'sort_order': 0,
        'is_active': 1,
        'created_at': '2026-01-01T00:00:00',
        'updated_at': '2026-01-01T00:00:00',
      });

      await db.insert('budgets', {
        'category_id': 1,
        'year': 2026,
        'month': 5,
        'amount': 500000.0,
        'created_at': '2026-01-01T00:00:00',
        'updated_at': '2026-01-01T00:00:00',
      });

      // Second insert with same (category_id, year, month) should fail
      expect(
        () => db.insert('budgets', {
          'category_id': 1,
          'year': 2026,
          'month': 5,
          'amount': 750000.0,
          'created_at': '2026-01-01T00:00:00',
          'updated_at': '2026-01-01T00:00:00',
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('savings_goals table has status CHECK constraint', () async {
      // Valid status should work
      await db.insert('savings_goals', {
        'name': 'Emergency Fund',
        'target_amount': 10000000.0,
        'current_amount': 0.0,
        'status': 'active',
        'created_at': '2026-01-01T00:00:00',
        'updated_at': '2026-01-01T00:00:00',
      });

      // Invalid status should fail
      expect(
        () => db.insert('savings_goals', {
          'name': 'Test Goal',
          'target_amount': 5000000.0,
          'current_amount': 0.0,
          'status': 'invalid_status',
          'created_at': '2026-01-01T00:00:00',
          'updated_at': '2026-01-01T00:00:00',
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('goal_contributions has foreign key to savings_goals', () async {
      // Enable foreign keys
      await db.execute('PRAGMA foreign_keys = ON');

      // Insert a savings goal first
      await db.insert('savings_goals', {
        'name': 'Test Goal',
        'target_amount': 5000000.0,
        'current_amount': 0.0,
        'status': 'active',
        'created_at': '2026-01-01T00:00:00',
        'updated_at': '2026-01-01T00:00:00',
      });

      // Valid goal_id should work
      await db.insert('goal_contributions', {
        'goal_id': 1,
        'amount': 100000.0,
        'running_balance': 100000.0,
        'date': '2026-01-15',
        'created_at': '2026-01-15T00:00:00',
      });

      // Invalid goal_id should fail
      expect(
        () => db.insert('goal_contributions', {
          'goal_id': 999,
          'amount': 50000.0,
          'running_balance': 50000.0,
          'date': '2026-01-15',
          'created_at': '2026-01-15T00:00:00',
        }),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('Schema v2→v3 migration', () {
    test('onUpgrade from v2 to v3 creates 3 new tables without data loss', () async {
      // Use a temporary file-based database that persists across opens
      final dbPath = await getDatabasesPath();
      final testDbPath = join(dbPath, 'test_migration_v2tov3.db');

      // Clean up any previous test database
      final file = File(testDbPath);
      if (await file.exists()) {
        await file.delete();
      }

      // Create a v2 database (only categories + transactions)
      db = await openDatabase(
        testDbPath,
        version: 2,
        onCreate: (db, version) async {
          // Create v2 schema (categories + transactions only)
          await db.execute('''
            CREATE TABLE categories (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              type TEXT NOT NULL CHECK(type IN ('income', 'expense')),
              color TEXT NOT NULL,
              icon TEXT,
              sort_order INTEGER NOT NULL DEFAULT 0,
              is_active INTEGER NOT NULL DEFAULT 1,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
          await db.execute('CREATE INDEX idx_categories_type ON categories(type)');
          await db.execute('CREATE INDEX idx_categories_is_active ON categories(is_active)');
          await db.execute('''
            CREATE TABLE transactions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              amount REAL NOT NULL CHECK(amount > 0),
              type TEXT NOT NULL CHECK(type IN ('income', 'expense')),
              date_time TEXT NOT NULL,
              category_id INTEGER NOT NULL,
              note TEXT,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
            )
          ''');
          await db.execute('CREATE INDEX idx_transactions_date_time ON transactions(date_time DESC)');
          await db.execute('CREATE INDEX idx_transactions_category_id ON transactions(category_id)');
          await db.execute('CREATE INDEX idx_transactions_type ON transactions(type)');
          await db.execute('CREATE INDEX idx_transactions_date_type ON transactions(date_time DESC, type)');
        },
      );

      // Insert existing data to verify it survives migration
      await db.insert('categories', {
        'name': 'Food',
        'type': 'expense',
        'color': '#FF0000',
        'icon': 'restaurant',
        'sort_order': 0,
        'is_active': 1,
        'created_at': '2026-01-01T00:00:00',
        'updated_at': '2026-01-01T00:00:00',
      });
      await db.close();

      // Now open with v3 using only onUpgrade (the file already exists at v2)
      db = await openDatabase(
        testDbPath,
        version: 3,
        onUpgrade: DatabaseSchemaManager.onUpgrade,
      );

      // Verify new tables exist
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
      );
      final tableNames = tables.map((t) => t['name'] as String).toList();

      expect(tableNames, contains('budgets'));
      expect(tableNames, contains('savings_goals'));
      expect(tableNames, contains('goal_contributions'));

      // Verify existing data survived
      final categories = await db.query('categories');
      expect(categories.length, 1);
      expect(categories.first['name'], 'Food');

      // Clean up
      await db.close();
      if (await file.exists()) {
        await file.delete();
      }
    });
  });
}
