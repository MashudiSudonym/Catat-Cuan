import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/goal_contribution_entity.dart';
import 'package:catat_cuan/domain/entities/savings_goal_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_contribution_repository.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_read_repository.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_write_repository.dart';
import 'package:catat_cuan/domain/usecases/savings_goal/add_contribution_usecase.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<SavingsGoalContributionRepository>(),
  MockSpec<SavingsGoalReadRepository>(),
  MockSpec<SavingsGoalWriteRepository>(),
])
import 'add_contribution_usecase_test.mocks.dart';

void main() {
  late AddContributionUseCase useCase;
  late MockSavingsGoalContributionRepository mockContributionRepo;
  late MockSavingsGoalReadRepository mockReadRepo;
  late MockSavingsGoalWriteRepository mockWriteRepo;

  setUp(() {
    AppLogger.initialize();
    mockContributionRepo = MockSavingsGoalContributionRepository();
    mockReadRepo = MockSavingsGoalReadRepository();
    mockWriteRepo = MockSavingsGoalWriteRepository();
    useCase = AddContributionUseCase(
      contributionRepository: mockContributionRepo,
      readRepository: mockReadRepo,
      writeRepository: mockWriteRepo,
    );
  });

  group('AddContributionUseCase', () {
    test('should add contribution successfully and return completion status false', () async {
      final now = DateTime.now();
      const params = AddContributionParams(
        goalId: 1,
        amount: 500000.0,
        note: 'Setoran bulanan',
        date: null,
      );

      final contribution = GoalContributionEntity(
        id: 1,
        goalId: 1,
        amount: 500000.0,
        runningBalance: 500000.0,
        note: 'Setoran bulanan',
        date: now,
        createdAt: now,
      );

      final goal = SavingsGoalEntity(
        id: 1,
        name: 'Dana Darurat',
        targetAmount: 10000000.0,
        currentAmount: 500000.0,
        status: 'active',
        createdAt: now,
        updatedAt: now,
      );

      when(mockContributionRepo.addContribution(
        goalId: anyNamed('goalId'),
        amount: anyNamed('amount'),
        note: anyNamed('note'),
        date: anyNamed('date'),
      )).thenAnswer((_) async => Result.success(contribution));

      when(mockReadRepo.getGoalById(any)).thenAnswer((_) async => Result.success(goal));

      final result = await useCase(params);

      expect(result.isSuccess, isTrue);
      expect(result.data?.contribution.amount, equals(500000.0));
      expect(result.data?.isGoalCompleted, isFalse);
      verify(mockContributionRepo.addContribution(
        goalId: 1,
        amount: 500000.0,
        note: 'Setoran bulanan',
        date: anyNamed('date'),
      )).called(1);
      verify(mockReadRepo.getGoalById(1)).called(1);
    });

    test('should detect goal completion when currentAmount reaches target', () async {
      final now = DateTime.now();
      const params = AddContributionParams(
        goalId: 1,
        amount: 500000.0,
      );

      final contribution = GoalContributionEntity(
        id: 1,
        goalId: 1,
        amount: 500000.0,
        runningBalance: 10000000.0,
        date: now,
        createdAt: now,
      );

      final goalAfterContribution = SavingsGoalEntity(
        id: 1,
        name: 'Dana Darurat',
        targetAmount: 10000000.0,
        currentAmount: 10000000.0,
        status: 'active',
        createdAt: now,
        updatedAt: now,
      );

      final completedGoal = SavingsGoalEntity(
        id: 1,
        name: 'Dana Darurat',
        targetAmount: 10000000.0,
        currentAmount: 10000000.0,
        status: 'completed',
        createdAt: now,
        updatedAt: now,
      );

      when(mockContributionRepo.addContribution(
        goalId: anyNamed('goalId'),
        amount: anyNamed('amount'),
        note: anyNamed('note'),
        date: anyNamed('date'),
      )).thenAnswer((_) async => Result.success(contribution));

      when(mockReadRepo.getGoalById(any)).thenAnswer((_) async => Result.success(goalAfterContribution));
      when(mockWriteRepo.updateGoal(
        id: anyNamed('id'),
        name: anyNamed('name'),
        targetAmount: anyNamed('targetAmount'),
        targetDate: anyNamed('targetDate'),
        icon: anyNamed('icon'),
        color: anyNamed('color'),
      )).thenAnswer((_) async => Result.success(completedGoal));

      final result = await useCase(params);

      expect(result.isSuccess, isTrue);
      expect(result.data?.isGoalCompleted, isTrue);
      verify(mockWriteRepo.updateGoal(
        id: 1,
        name: 'Dana Darurat',
        targetAmount: 10000000.0,
        targetDate: null,
        icon: null,
        color: null,
      )).called(1);
    });

    test('should not complete already completed goal', () async {
      final now = DateTime.now();
      const params = AddContributionParams(
        goalId: 1,
        amount: 100000.0,
      );

      final contribution = GoalContributionEntity(
        id: 1,
        goalId: 1,
        amount: 100000.0,
        runningBalance: 10100000.0,
        date: now,
        createdAt: now,
      );

      final alreadyCompleted = SavingsGoalEntity(
        id: 1,
        name: 'Dana Darurat',
        targetAmount: 10000000.0,
        currentAmount: 10100000.0,
        status: 'completed',
        createdAt: now,
        updatedAt: now,
      );

      when(mockContributionRepo.addContribution(
        goalId: anyNamed('goalId'),
        amount: anyNamed('amount'),
        note: anyNamed('note'),
        date: anyNamed('date'),
      )).thenAnswer((_) async => Result.success(contribution));

      when(mockReadRepo.getGoalById(any)).thenAnswer((_) async => Result.success(alreadyCompleted));

      final result = await useCase(params);

      expect(result.isSuccess, isTrue);
      expect(result.data?.isGoalCompleted, isFalse);
      verifyNever(mockWriteRepo.updateGoal(
        id: anyNamed('id'),
        name: anyNamed('name'),
        targetAmount: anyNamed('targetAmount'),
        targetDate: anyNamed('targetDate'),
        icon: anyNamed('icon'),
        color: anyNamed('color'),
      ));
    });

    test('should return ValidationFailure when amount is zero', () async {
      const params = AddContributionParams(
        goalId: 1,
        amount: 0,
      );

      final result = await useCase(params);

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      verifyNever(mockContributionRepo.addContribution(
        goalId: anyNamed('goalId'),
        amount: anyNamed('amount'),
        note: anyNamed('note'),
        date: anyNamed('date'),
      ));
    });

    test('should return ValidationFailure when amount is negative', () async {
      const params = AddContributionParams(
        goalId: 1,
        amount: -100.0,
      );

      final result = await useCase(params);

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      verifyNever(mockContributionRepo.addContribution(
        goalId: anyNamed('goalId'),
        amount: anyNamed('amount'),
        note: anyNamed('note'),
        date: anyNamed('date'),
      ));
    });

    test('should return contribution even when completion check fails', () async {
      final now = DateTime.now();
      const params = AddContributionParams(
        goalId: 1,
        amount: 500000.0,
      );

      final contribution = GoalContributionEntity(
        id: 1,
        goalId: 1,
        amount: 500000.0,
        runningBalance: 500000.0,
        date: now,
        createdAt: now,
      );

      when(mockContributionRepo.addContribution(
        goalId: anyNamed('goalId'),
        amount: anyNamed('amount'),
        note: anyNamed('note'),
        date: anyNamed('date'),
      )).thenAnswer((_) async => Result.success(contribution));

      when(mockReadRepo.getGoalById(any)).thenThrow(Exception('DB error'));

      final result = await useCase(params);

      expect(result.isSuccess, isTrue);
      expect(result.data?.contribution.amount, equals(500000.0));
      expect(result.data?.isGoalCompleted, isFalse);
    });

    test('should return DatabaseFailure on contribution repo exception', () async {
      const params = AddContributionParams(
        goalId: 1,
        amount: 500000.0,
      );

      when(mockContributionRepo.addContribution(
        goalId: anyNamed('goalId'),
        amount: anyNamed('amount'),
        note: anyNamed('note'),
        date: anyNamed('date'),
      )).thenThrow(Exception('Database error'));

      final result = await useCase(params);

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
    });
  });
}
