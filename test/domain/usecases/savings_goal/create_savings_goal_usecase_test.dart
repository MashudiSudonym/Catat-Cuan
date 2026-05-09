import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/savings_goal_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/savings_goal/savings_goal_write_repository.dart';
import 'package:catat_cuan/domain/usecases/savings_goal/create_savings_goal_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<SavingsGoalWriteRepository>(),
])
import 'create_savings_goal_usecase_test.mocks.dart';

void main() {
  late CreateSavingsGoalUseCase useCase;
  late MockSavingsGoalWriteRepository mockRepository;

  setUp(() {
    mockRepository = MockSavingsGoalWriteRepository();
    useCase = CreateSavingsGoalUseCase(mockRepository);
  });

  group('CreateSavingsGoalUseCase', () {
    test('should create goal successfully with valid data', () async {
      final now = DateTime.now();
      const params = CreateSavingsGoalParams(
        name: 'Dana Darurat',
        targetAmount: 10000000.0,
        targetDate: null,
        icon: null,
        color: null,
      );

      final goal = SavingsGoalEntity(
        id: 1,
        name: 'Dana Darurat',
        targetAmount: 10000000.0,
        currentAmount: 0.0,
        status: 'active',
        createdAt: now,
        updatedAt: now,
      );

      when(mockRepository.createGoal(
        name: anyNamed('name'),
        targetAmount: anyNamed('targetAmount'),
        targetDate: anyNamed('targetDate'),
        icon: anyNamed('icon'),
        color: anyNamed('color'),
      )).thenAnswer((_) async => Result.success(goal));

      final result = await useCase(params);

      expect(result.isSuccess, isTrue);
      expect(result.data?.name, equals('Dana Darurat'));
      expect(result.data?.targetAmount, equals(10000000.0));
      verify(mockRepository.createGoal(
        name: 'Dana Darurat',
        targetAmount: 10000000.0,
        targetDate: null,
        icon: null,
        color: null,
      )).called(1);
    });

    test('should return ValidationFailure when name is empty', () async {
      const params = CreateSavingsGoalParams(
        name: '',
        targetAmount: 10000000.0,
      );

      final result = await useCase(params);

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      verifyNever(mockRepository.createGoal(
        name: anyNamed('name'),
        targetAmount: anyNamed('targetAmount'),
        targetDate: anyNamed('targetDate'),
        icon: anyNamed('icon'),
        color: anyNamed('color'),
      ));
    });

    test('should return ValidationFailure when name is whitespace only', () async {
      const params = CreateSavingsGoalParams(
        name: '   ',
        targetAmount: 10000000.0,
      );

      final result = await useCase(params);

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      verifyNever(mockRepository.createGoal(
        name: anyNamed('name'),
        targetAmount: anyNamed('targetAmount'),
        targetDate: anyNamed('targetDate'),
        icon: anyNamed('icon'),
        color: anyNamed('color'),
      ));
    });

    test('should return ValidationFailure when targetAmount is zero', () async {
      const params = CreateSavingsGoalParams(
        name: 'Dana Darurat',
        targetAmount: 0,
      );

      final result = await useCase(params);

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      verifyNever(mockRepository.createGoal(
        name: anyNamed('name'),
        targetAmount: anyNamed('targetAmount'),
        targetDate: anyNamed('targetDate'),
        icon: anyNamed('icon'),
        color: anyNamed('color'),
      ));
    });

    test('should return ValidationFailure when targetAmount is negative', () async {
      const params = CreateSavingsGoalParams(
        name: 'Dana Darurat',
        targetAmount: -500000.0,
      );

      final result = await useCase(params);

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      verifyNever(mockRepository.createGoal(
        name: anyNamed('name'),
        targetAmount: anyNamed('targetAmount'),
        targetDate: anyNamed('targetDate'),
        icon: anyNamed('icon'),
        color: anyNamed('color'),
      ));
    });

    test('should return DatabaseFailure on repository exception', () async {
      const params = CreateSavingsGoalParams(
        name: 'Dana Darurat',
        targetAmount: 10000000.0,
      );

      when(mockRepository.createGoal(
        name: anyNamed('name'),
        targetAmount: anyNamed('targetAmount'),
        targetDate: anyNamed('targetDate'),
        icon: anyNamed('icon'),
        color: anyNamed('color'),
      )).thenThrow(Exception('Database error'));

      final result = await useCase(params);

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
    });
  });
}
