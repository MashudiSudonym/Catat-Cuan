import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/datasources/local/sqlite_data_source.dart';
import 'package:catat_cuan/data/models/budget_model.dart';
import 'package:catat_cuan/data/repositories/budget/budget_read_repository_impl.dart';
import 'package:catat_cuan/data/repositories/budget/budget_write_repository_impl.dart';
import 'package:catat_cuan/data/repositories/budget/budget_query_repository_impl.dart';
import 'package:catat_cuan/domain/entities/budget_entity.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

void main() {
  late SqliteDataSource dataSource;
  late Database db;
  late BudgetReadRepositoryImpl readRepo;
  late BudgetWriteRepositoryImpl writeRepo;
  late BudgetQueryRepositoryImpl queryRepo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    AppLogger.initialize();
  });

  setUp(() async {
    db = await openDatabase(
      inMemoryDatabasePath,
      version: DatabaseSchemaManager.currentVersion,
      onCreate: DatabaseSchemaManager.onCreate,
    );
    dataSource = SqliteDataSource.fromDatabase(db);
    readRepo = BudgetReadRepositoryImpl(dataSource);
    writeRepo = BudgetWriteRepositoryImpl(dataSource);
    queryRepo = BudgetQueryRepositoryImpl(dataSource);

    // Seed categories
    await db.insert('categories', {
      'name': 'Makan',
      'type': 'expense',
      'color': '#FF64748B',
      'icon': '🍽️',
      'sort_order': 1,
      'is_active': 1,
      'created_at': '2026-05-01T00:00:00',
      'updated_at': '2026-05-01T00:00:00',
    });
    await db.insert('categories', {
      'name': 'Transport',
      'type': 'expense',
      'color': '#FF59E6C6',
      'icon': '🚗',
      'sort_order': 2,
      'is_active': 1,
      'created_at': '2026-05-01T00:00:00',
      'updated_at': '2026-05-01T00:00:00',
    });
    await db.insert('categories', {
      'name': 'Gaji',
      'type': 'income',
      'color': '#FF34D399',
      'icon': '💰',
      'sort_order': 1,
      'is_active': 1,
      'created_at': '2026-05-01T00:00:00',
      'updated_at': '2026-05-01T00:00:00',
    });
  });

  tearDown(() async {
    if (db.isOpen) {
      await db.close();
    }
  });

  group('BudgetWriteRepository', () {
    test('create budget for expense category succeeds', () async {
      final result = await writeRepo.createBudget(
        categoryId: 1,
        year: 2026,
        month: 5,
        amount: 500000.0,
      );

      expect(result.isSuccess, isTrue);
      expect(result.data!.categoryId, equals(1));
      expect(result.data!.year, equals(2026));
      expect(result.data!.month, equals(5));
      expect(result.data!.amount, equals(500000.0));
      expect(result.data!.id, isNotNull);
    });

    test('create budget for income category fails (expense-only validation)', () async {
      final result = await writeRepo.createBudget(
        categoryId: 3, // income category
        year: 2026,
        month: 5,
        amount: 1000000.0,
      );

      expect(result.isFailure, isTrue);
    });

    test('create duplicate budget fails (UNIQUE constraint per BUD-07)', () async {
      // First budget
      final first = await writeRepo.createBudget(
        categoryId: 1,
        year: 2026,
        month: 5,
        amount: 500000.0,
      );
      expect(first.isSuccess, isTrue);

      // Duplicate budget (same category + year + month)
      final duplicate = await writeRepo.createBudget(
        categoryId: 1,
        year: 2026,
        month: 5,
        amount: 600000.0,
      );
      expect(duplicate.isFailure, isTrue);
    });

    test('update budget amount succeeds', () async {
      final created = await writeRepo.createBudget(
        categoryId: 1,
        year: 2026,
        month: 6,
        amount: 300000.0,
      );
      expect(created.isSuccess, isTrue);

      final updated = await writeRepo.updateBudget(
        id: created.data!.id!,
        amount: 400000.0,
      );

      expect(updated.isSuccess, isTrue);
      expect(updated.data!.amount, equals(400000.0));
    });

    test('delete budget succeeds', () async {
      final created = await writeRepo.createBudget(
        categoryId: 1,
        year: 2026,
        month: 7,
        amount: 250000.0,
      );
      expect(created.isSuccess, isTrue);
      final budgetId = created.data!.id!;

      final deleted = await writeRepo.deleteBudget(budgetId);
      expect(deleted.isSuccess, isTrue);

      // Verify it's gone
      final fetched = await readRepo.getBudgetById(budgetId);
      expect(fetched.isFailure, isTrue);
    });
  });

  group('BudgetReadRepository', () {
    test('get budgets for month returns created budgets', () async {
      await writeRepo.createBudget(
        categoryId: 1,
        year: 2026,
        month: 8,
        amount: 500000.0,
      );
      await writeRepo.createBudget(
        categoryId: 2,
        year: 2026,
        month: 8,
        amount: 300000.0,
      );

      final result = await readRepo.getBudgetsForMonth(2026, 8);

      expect(result.isSuccess, isTrue);
      expect(result.data!.length, equals(2));
    });

    test('get budgets for empty month returns empty list', () async {
      final result = await readRepo.getBudgetsForMonth(2025, 1);

      expect(result.isSuccess, isTrue);
      expect(result.data!.length, equals(0));
    });

    test('get budget by ID succeeds', () async {
      final created = await writeRepo.createBudget(
        categoryId: 1,
        year: 2026,
        month: 9,
        amount: 200000.0,
      );
      final budgetId = created.data!.id!;

      final result = await readRepo.getBudgetById(budgetId);

      expect(result.isSuccess, isTrue);
      expect(result.data!.id, equals(budgetId));
      expect(result.data!.amount, equals(200000.0));
    });
  });

  group('BudgetQueryRepository', () {
    test('get budgets with spent calculates spent from existing transactions', () async {
      // Create budget
      await writeRepo.createBudget(
        categoryId: 1,
        year: 2026,
        month: 5,
        amount: 500000.0,
      );

      // Add expense transactions
      await db.insert('transactions', {
        'amount': 150000.0,
        'type': 'expense',
        'date_time': '2026-05-10T12:00:00',
        'category_id': 1,
        'note': 'Lunch',
        'created_at': '2026-05-10T12:00:00',
        'updated_at': '2026-05-10T12:00:00',
      });
      await db.insert('transactions', {
        'amount': 100000.0,
        'type': 'expense',
        'date_time': '2026-05-15T18:30:00',
        'category_id': 1,
        'note': 'Dinner',
        'created_at': '2026-05-15T18:30:00',
        'updated_at': '2026-05-15T18:30:00',
      });

      final result = await queryRepo.getBudgetsWithSpent(2026, 5);

      expect(result.isSuccess, isTrue);
      expect(result.data!.length, equals(1));
      expect(result.data!.first.spentAmount, equals(250000.0));
      expect(result.data!.first.progressPercent, closeTo(50.0, 0.01));
      expect(result.data!.first.remainingAmount, equals(250000.0));
    });

    test('get budgets with no transactions returns spent of 0.0', () async {
      await writeRepo.createBudget(
        categoryId: 2,
        year: 2026,
        month: 11,
        amount: 400000.0,
      );

      final result = await queryRepo.getBudgetsWithSpent(2026, 11);

      expect(result.isSuccess, isTrue);
      expect(result.data!.length, equals(1));
      expect(result.data!.first.spentAmount, equals(0.0));
      expect(result.data!.first.progressPercent, equals(0.0));
    });

    test('getBudgetSpentForCategory returns sum of expense transactions', () async {
      // Create budget to set up the month
      await writeRepo.createBudget(
        categoryId: 1,
        year: 2026,
        month: 10,
        amount: 500000.0,
      );

      // Add transactions
      await db.insert('transactions', {
        'amount': 75000.0,
        'type': 'expense',
        'date_time': '2026-10-05T08:00:00',
        'category_id': 1,
        'note': 'Breakfast',
        'created_at': '2026-10-05T08:00:00',
        'updated_at': '2026-10-05T08:00:00',
      });

      final result = await queryRepo.getBudgetSpentForCategory(
        categoryId: 1,
        year: 2026,
        month: 10,
      );

      expect(result.isSuccess, isTrue);
      expect(result.data, equals(75000.0));
    });

    test('income transactions are not counted in spent calculation', () async {
      await writeRepo.createBudget(
        categoryId: 1,
        year: 2026,
        month: 12,
        amount: 500000.0,
      );

      // Add income transaction for same category (shouldn't count)
      await db.insert('transactions', {
        'amount': 5000000.0,
        'type': 'income',
        'date_time': '2026-12-01T09:00:00',
        'category_id': 3, // income category
        'note': 'Salary',
        'created_at': '2026-12-01T09:00:00',
        'updated_at': '2026-12-01T09:00:00',
      });

      final result = await queryRepo.getBudgetsWithSpent(2026, 12);

      expect(result.isSuccess, isTrue);
      // Budget for category 1 should have 0 spent (no expense transactions)
      expect(result.data!.first.spentAmount, equals(0.0));
    });
  });

  group('BudgetModel', () {
    test('fromMap and toMap roundtrip preserves data', () {
      final now = DateTime(2026, 5, 7, 10, 30);
      final entity = BudgetEntity(
        id: 1,
        categoryId: 5,
        year: 2026,
        month: 5,
        amount: 500000.0,
        createdAt: now,
        updatedAt: now,
      );

      final model = BudgetModel.fromEntity(entity);
      final map = model.toMap();

      expect(map['category_id'], equals(5));
      expect(map['year'], equals(2026));
      expect(map['month'], equals(5));
      expect(map['amount'], equals(500000.0));

      final fromMap = BudgetModel.fromMap(map);
      final backToEntity = fromMap.toEntity();

      expect(backToEntity.categoryId, equals(5));
      expect(backToEntity.year, equals(2026));
      expect(backToEntity.month, equals(5));
      expect(backToEntity.amount, equals(500000.0));
    });
  });
}
