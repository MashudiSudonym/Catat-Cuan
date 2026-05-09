import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/savings_goal_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_read_repository.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_write_repository.dart';
import 'package:catat_cuan/domain/usecases/savings_goal/check_goal_completion_usecase.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<SavingsGoalReadRepository>(),
  MockSpec<SavingsGoalWriteRepository>(),
])
import 'check_goal_completion_usecase_test.mocks.dart';

void main() {
  late CheckGoalCompletionUseCase useCase;
  late MockSavingsGoalReadRepository mockReadRepo;
  late MockSavingsGoalWriteRepository mockWriteRepo;

  setUp(() {
    AppLogger.initialize();
    mockReadRepo = MockSavingsGoalReadRepository();
    mockWriteRepo = MockSavingsGoalWriteRepository();
    useCase = CheckGoalCompletionUseCase(
      readRepository: mockReadRepo,
      writeRepository: mockWriteRepo,
    );
  });

  group('CheckGoalCompletionUseCase', () {
    test('should detect completion when currentAmount equals targetAmount', () async {
      final now = DateTime.now();
      final goal = SavingsGoalEntity(
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

      when(mockReadRepo.getGoalById(any)).thenAnswer((_) async => Result.success(goal));
      when(mockWriteRepo.updateGoal(
        id: anyNamed('id'),
        name: anyNamed('name'),
        targetAmount: anyNamed('targetAmount'),
        targetDate: anyNamed('targetDate'),
        icon: anyNamed('icon'),
        color: anyNamed('color'),
      )).thenAnswer((_) async => Result.success(completedGoal));

      final result = await useCase(1);

      expect(result.isSuccess, isTrue);
      expect(result.data, isTrue);
      verify(mockWriteRepo.updateGoal(
        id: 1,
        name: 'Dana Darurat',
        targetAmount: 10000000.0,
        targetDate: null,
        icon: null,
        color: null,
      )).called(1);
    });

    test('should detect completion when currentAmount exceeds targetAmount', () async {
      final now = DateTime.now();
      final goal = SavingsGoalEntity(
        id: 1,
        name: 'Dana Darurat',
        targetAmount: 10000000.0,
        currentAmount: 10500000.0,
        status: 'active',
        createdAt: now,
        updatedAt: now,
      );

      when(mockReadRepo.getGoalById(any)).thenAnswer((_) async => Result.success(goal));
      when(mockWriteRepo.updateGoal(
        id: anyNamed('id'),
        name: anyNamed('name'),
        targetAmount: anyNamed('targetAmount'),
        targetDate: anyNamed('targetDate'),
        icon: anyNamed('icon'),
        color: anyNamed('color'),
      )).thenAnswer((_) async => Result.success(goal));

      final result = await useCase(1);

      expect(result.isSuccess, isTrue);
      expect(result.data, isTrue);
      verify(mockWriteRepo.updateGoal(
        id: 1,
        name: 'Dana Darurat',
        targetAmount: 10000000.0,
        targetDate: null,
        icon: null,
        color: null,
      )).called(1);
    });

    test('should return false when goal is not yet completed', () async {
      final now = DateTime.now();
      final goal = SavingsGoalEntity(
        id: 1,
        name: 'Dana Darurat',
        targetAmount: 10000000.0,
        currentAmount: 5000000.0,
        status: 'active',
        createdAt: now,
        updatedAt: now,
      );

      when(mockReadRepo.getGoalById(any)).thenAnswer((_) async => Result.success(goal));

      final result = await useCase(1);

      expect(result.isSuccess, isTrue);
      expect(result.data, isFalse);
      verifyNever(mockWriteRepo.updateGoal(
        id: anyNamed('id'),
        name: anyNamed('name'),
        targetAmount: anyNamed('targetAmount'),
        targetDate: anyNamed('targetDate'),
        icon: anyNamed('icon'),
        color: anyNamed('color'),
      ));
    });

    test('should return false for already completed goal (idempotent)', () async {
      final now = DateTime.now();
      final goal = SavingsGoalEntity(
        id: 1,
        name: 'Dana Darurat',
        targetAmount: 10000000.0,
        currentAmount: 10000000.0,
        status: 'completed',
        createdAt: now,
        updatedAt: now,
      );

      when(mockReadRepo.getGoalById(any)).thenAnswer((_) async => Result.success(goal));

      final result = await useCase(1);

      expect(result.isSuccess, isTrue);
      expect(result.data, isFalse);
      verifyNever(mockWriteRepo.updateGoal(
        id: anyNamed('id'),
        name: anyNamed('name'),
        targetAmount: anyNamed('targetAmount'),
        targetDate: anyNamed('targetDate'),
        icon: anyNamed('icon'),
        color: anyNamed('color'),
      ));
    });

    test('should return false when goal not found', () async {
      when(mockReadRepo.getGoalById(any)).thenAnswer((_) async => Result.failure(const NotFoundFailure('Not found')));

      final result = await useCase(999);

      expect(result.isSuccess, isTrue);
      expect(result.data, isFalse);
      verifyNever(mockWriteRepo.updateGoal(
        id: anyNamed('id'),
        name: anyNamed('name'),
        targetAmount: anyNamed('targetAmount'),
        targetDate: anyNamed('targetDate'),
        icon: anyNamed('icon'),
        color: anyNamed('color'),
      ));
    });

    test('should return false on exception (never blocks contribution flow)', () async {
      when(mockReadRepo.getGoalById(any)).thenThrow(Exception('DB error'));

      final result = await useCase(1);

      expect(result.isSuccess, isTrue);
      expect(result.data, isFalse);
      verifyNever(mockWriteRepo.updateGoal(
        id: anyNamed('id'),
        name: anyNamed('name'),
        targetAmount: anyNamed('targetAmount'),
        targetDate: anyNamed('targetDate'),
        icon: anyNamed('icon'),
        color: anyNamed('color'),
      ));
    });
  });
}
