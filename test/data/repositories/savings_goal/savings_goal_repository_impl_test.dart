import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/datasources/local/sqlite_data_source.dart';
import 'package:catat_cuan/data/models/savings_goal_model.dart';
import 'package:catat_cuan/data/models/goal_contribution_model.dart';
import 'package:catat_cuan/data/repositories/savings_goal/savings_goal_read_repository_impl.dart';
import 'package:catat_cuan/data/repositories/savings_goal/savings_goal_write_repository_impl.dart';
import 'package:catat_cuan/data/repositories/savings_goal/savings_goal_contribution_repository_impl.dart';
import 'package:catat_cuan/data/repositories/savings_goal/savings_goal_query_repository_impl.dart';
import 'package:catat_cuan/domain/entities/savings_goal_entity.dart';
import 'package:catat_cuan/domain/entities/goal_contribution_entity.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

void main() {
  late SqliteDataSource dataSource;
  late Database db;
  late SavingsGoalReadRepositoryImpl readRepo;
  late SavingsGoalWriteRepositoryImpl writeRepo;
  late SavingsGoalContributionRepositoryImpl contributionRepo;
  late SavingsGoalQueryRepositoryImpl queryRepo;

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
    readRepo = SavingsGoalReadRepositoryImpl(dataSource);
    writeRepo = SavingsGoalWriteRepositoryImpl(dataSource);
    contributionRepo = SavingsGoalContributionRepositoryImpl(dataSource);
    queryRepo = SavingsGoalQueryRepositoryImpl(dataSource);
  });

  tearDown(() async {
    if (db.isOpen) {
      await db.close();
    }
  });

  group('SavingsGoalModel', () {
    test('fromMap and toMap roundtrip preserves data', () {
      final now = DateTime(2026, 5, 9);
      final entity = SavingsGoalEntity(
        id: 1,
        name: 'iPhone Baru',
        targetAmount: 15000000.0,
        currentAmount: 5000000.0,
        targetDate: DateTime(2026, 12, 31),
        icon: 'savings',
        color: '#FF10B981',
        status: 'active',
        createdAt: now,
        updatedAt: now,
      );

      final model = SavingsGoalModel.fromEntity(entity);
      final map = model.toMap();

      expect(map['name'], equals('iPhone Baru'));
      expect(map['target_amount'], equals(15000000.0));
      expect(map['current_amount'], equals(5000000.0));
      expect(map['icon'], equals('savings'));

      final fromMap = SavingsGoalModel.fromMap(map);
      final backToEntity = fromMap.toEntity();

      expect(backToEntity.name, equals('iPhone Baru'));
      expect(backToEntity.targetAmount, equals(15000000.0));
      expect(backToEntity.currentAmount, equals(5000000.0));
    });

    test('handles nullable fields correctly', () {
      final now = DateTime(2026, 5, 9);
      final entity = SavingsGoalEntity(
        id: 1,
        name: 'Simple Goal',
        targetAmount: 1000000.0,
        createdAt: now,
        updatedAt: now,
      );

      final model = SavingsGoalModel.fromEntity(entity);
      final map = model.toMap();

      expect(map['target_date'], isNull);
      expect(map['icon'], isNull);
      expect(map['color'], isNull);

      final backToEntity = SavingsGoalModel.fromMap(map).toEntity();
      expect(backToEntity.targetDate, isNull);
      expect(backToEntity.icon, isNull);
    });
  });

  group('GoalContributionModel', () {
    test('fromMap and toMap roundtrip preserves data', () {
      final now = DateTime(2026, 5, 9);
      final entity = GoalContributionEntity(
        id: 1,
        goalId: 1,
        amount: 500000.0,
        runningBalance: 500000.0,
        note: 'First deposit',
        date: now,
        createdAt: now,
      );

      final model = GoalContributionModel.fromEntity(entity);
      final map = model.toMap();

      expect(map['goal_id'], equals(1));
      expect(map['amount'], equals(500000.0));
      expect(map['running_balance'], equals(500000.0));
      expect(map['note'], equals('First deposit'));

      final fromMap = GoalContributionModel.fromMap(map);
      final backToEntity = fromMap.toEntity();

      expect(backToEntity.goalId, equals(1));
      expect(backToEntity.amount, equals(500000.0));
      expect(backToEntity.runningBalance, equals(500000.0));
      expect(backToEntity.note, equals('First deposit'));
    });
  });

  group('SavingsGoalWriteRepository', () {
    test('createGoal inserts with status active and returns goal with id', () async {
      final result = await writeRepo.createGoal(
        name: 'iPhone Baru',
        targetAmount: 15000000.0,
      );

      expect(result.isSuccess, isTrue);
      expect(result.data!.name, equals('iPhone Baru'));
      expect(result.data!.targetAmount, equals(15000000.0));
      expect(result.data!.currentAmount, equals(0.0));
      expect(result.data!.status, equals('active'));
      expect(result.data!.id, isNotNull);
    });

    test('createGoal with optional fields', () async {
      final deadline = DateTime(2026, 12, 31);
      final result = await writeRepo.createGoal(
        name: 'Liburan',
        targetAmount: 5000000.0,
        targetDate: deadline,
        icon: 'savings',
        color: '#FF10B981',
      );

      expect(result.isSuccess, isTrue);
      expect(result.data!.targetDate, equals(deadline));
      expect(result.data!.icon, equals('savings'));
      expect(result.data!.color, equals('#FF10B981'));
    });

    test('updateGoal updates editable fields only (NOT currentAmount per SAV-03)', () async {
      final created = await writeRepo.createGoal(
        name: 'Original',
        targetAmount: 5000000.0,
      );
      expect(created.isSuccess, isTrue);
      final goalId = created.data!.id!;

      // Add a contribution to increase currentAmount
      await contributionRepo.addContribution(
        goalId: goalId,
        amount: 1000000.0,
        date: DateTime(2026, 5, 9),
      );

      // Update name and target
      final updated = await writeRepo.updateGoal(
        id: goalId,
        name: 'Updated Goal',
        targetAmount: 8000000.0,
      );

      expect(updated.isSuccess, isTrue);
      expect(updated.data!.name, equals('Updated Goal'));
      expect(updated.data!.targetAmount, equals(8000000.0));
      // currentAmount should NOT be changed by updateGoal (SAV-03)
      expect(updated.data!.currentAmount, equals(1000000.0));
    });

    test('softDeleteGoal sets status to cancelled per SAV-04', () async {
      final created = await writeRepo.createGoal(
        name: 'To Cancel',
        targetAmount: 3000000.0,
      );
      expect(created.isSuccess, isTrue);
      final goalId = created.data!.id!;

      final deleted = await writeRepo.softDeleteGoal(goalId);
      expect(deleted.isSuccess, isTrue);

      // Verify status is cancelled
      final fetched = await readRepo.getGoalById(goalId);
      expect(fetched.isSuccess, isTrue);
      expect(fetched.data!.status, equals('cancelled'));
    });
  });

  group('SavingsGoalReadRepository', () {
    test('getGoals filters by status', () async {
      await writeRepo.createGoal(name: 'Active 1', targetAmount: 1000000.0);
      await writeRepo.createGoal(name: 'Active 2', targetAmount: 2000000.0);
      final toCancel = await writeRepo.createGoal(name: 'Cancelled', targetAmount: 3000000.0);
      await writeRepo.softDeleteGoal(toCancel.data!.id!);

      final activeResult = await readRepo.getGoals(status: 'active');
      expect(activeResult.isSuccess, isTrue);
      expect(activeResult.data!.length, equals(2));

      final cancelledResult = await readRepo.getGoals(status: 'cancelled');
      expect(cancelledResult.isSuccess, isTrue);
      expect(cancelledResult.data!.length, equals(1));
    });

    test('getGoalById returns goal or failure', () async {
      final created = await writeRepo.createGoal(
        name: 'Find Me',
        targetAmount: 1000000.0,
      );
      final goalId = created.data!.id!;

      final found = await readRepo.getGoalById(goalId);
      expect(found.isSuccess, isTrue);
      expect(found.data!.name, equals('Find Me'));

      final notFound = await readRepo.getGoalById(9999);
      expect(notFound.isFailure, isTrue);
    });

    test('getActiveGoals returns only active goals', () async {
      await writeRepo.createGoal(name: 'Active', targetAmount: 1000000.0);
      final toCancel = await writeRepo.createGoal(name: 'To Cancel', targetAmount: 2000000.0);
      await writeRepo.softDeleteGoal(toCancel.data!.id!);

      final result = await readRepo.getActiveGoals();
      expect(result.isSuccess, isTrue);
      expect(result.data!.length, equals(1));
      expect(result.data!.first.name, equals('Active'));
    });
  });

  group('SavingsGoalContributionRepository', () {
    late int goalId;

    setUp(() async {
      final created = await writeRepo.createGoal(
        name: 'Test Goal',
        targetAmount: 5000000.0,
      );
      goalId = created.data!.id!;
    });

    test('addContribution inserts positive amount and atomically increases current_amount', () async {
      final result = await contributionRepo.addContribution(
        goalId: goalId,
        amount: 1000000.0,
        note: 'First savings',
        date: DateTime(2026, 5, 9),
      );

      expect(result.isSuccess, isTrue);
      expect(result.data!.amount, equals(1000000.0));
      expect(result.data!.runningBalance, equals(1000000.0));
      expect(result.data!.isContribution, isTrue);

      // Verify goal's current_amount was updated
      final goal = await readRepo.getGoalById(goalId);
      expect(goal.data!.currentAmount, equals(1000000.0));
    });

    test('addContribution calculates running_balance correctly', () async {
      await contributionRepo.addContribution(
        goalId: goalId,
        amount: 1000000.0,
        date: DateTime(2026, 5, 9),
      );

      final second = await contributionRepo.addContribution(
        goalId: goalId,
        amount: 500000.0,
        date: DateTime(2026, 5, 10),
      );

      expect(second.isSuccess, isTrue);
      expect(second.data!.runningBalance, equals(1500000.0));
    });

    test('withdrawFromGoal inserts negative amount and decreases current_amount', () async {
      await contributionRepo.addContribution(
        goalId: goalId,
        amount: 2000000.0,
        date: DateTime(2026, 5, 9),
      );

      final withdrawal = await contributionRepo.withdrawFromGoal(
        goalId: goalId,
        amount: 500000.0,
        note: 'Emergency',
        date: DateTime(2026, 5, 10),
      );

      expect(withdrawal.isSuccess, isTrue);
      expect(withdrawal.data!.amount, equals(-500000.0));
      expect(withdrawal.data!.isWithdrawal, isTrue);

      // Verify goal's current_amount was decreased
      final goal = await readRepo.getGoalById(goalId);
      expect(goal.data!.currentAmount, equals(1500000.0));
    });

    test('withdrawFromGoal rejects withdrawal exceeding current_amount', () async {
      await contributionRepo.addContribution(
        goalId: goalId,
        amount: 1000000.0,
        date: DateTime(2026, 5, 9),
      );

      final result = await contributionRepo.withdrawFromGoal(
        goalId: goalId,
        amount: 2000000.0,
        date: DateTime(2026, 5, 10),
      );

      expect(result.isFailure, isTrue);
    });

    test('getContributionsForGoal returns ordered by date desc', () async {
      await contributionRepo.addContribution(
        goalId: goalId,
        amount: 500000.0,
        date: DateTime(2026, 5, 1),
      );
      await contributionRepo.addContribution(
        goalId: goalId,
        amount: 300000.0,
        date: DateTime(2026, 5, 5),
      );

      final result = await contributionRepo.getContributionsForGoal(goalId);

      expect(result.isSuccess, isTrue);
      expect(result.data!.length, equals(2));
      expect(result.data!.first.date, equals(DateTime(2026, 5, 5)));
    });
  });

  group('SavingsGoalQueryRepository', () {
    test('getGoalsWithProgress returns SavingsGoalWithProgressEntity', () async {
      await writeRepo.createGoal(name: 'Goal 1', targetAmount: 1000000.0);
      final goal2 = await writeRepo.createGoal(name: 'Goal 2', targetAmount: 2000000.0);

      await contributionRepo.addContribution(
        goalId: goal2.data!.id!,
        amount: 1000000.0,
        date: DateTime(2026, 5, 9),
      );

      final result = await queryRepo.getGoalsWithProgress();

      expect(result.isSuccess, isTrue);
      expect(result.data!.length, equals(2));

      final goal2Progress = result.data!.firstWhere(
        (p) => p.goal.name == 'Goal 2',
      );
      expect(goal2Progress.progressPercentage, equals(50.0));
      expect(goal2Progress.isCompleted, isFalse);
    });

    test('getGoalWithProgressById returns single goal with progress', () async {
      final created = await writeRepo.createGoal(
        name: 'Single',
        targetAmount: 1000000.0,
      );
      final goalId = created.data!.id!;

      await contributionRepo.addContribution(
        goalId: goalId,
        amount: 750000.0,
        date: DateTime(2026, 5, 9),
      );

      final result = await queryRepo.getGoalWithProgressById(goalId);

      expect(result.isSuccess, isTrue);
      expect(result.data!.progressPercentage, equals(75.0));
      expect(result.data!.isCompleted, isFalse);
    });

    test('getOverallProgress returns total saved / total target', () async {
      await writeRepo.createGoal(name: 'A', targetAmount: 1000000.0);
      final goalB = await writeRepo.createGoal(name: 'B', targetAmount: 2000000.0);

      await contributionRepo.addContribution(
        goalId: goalB.data!.id!,
        amount: 1000000.0,
        date: DateTime(2026, 5, 9),
      );

      final result = await queryRepo.getOverallProgress();

      expect(result.isSuccess, isTrue);
      expect(result.data, closeTo(33.33, 0.1));
    });

    test('getOverallProgress returns 0 when no active goals', () async {
      final result = await queryRepo.getOverallProgress();

      expect(result.isSuccess, isTrue);
      expect(result.data, equals(0.0));
    });
  });
}
