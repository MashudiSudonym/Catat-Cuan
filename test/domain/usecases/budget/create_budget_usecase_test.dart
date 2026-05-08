import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/budget_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/budget/budget_write_repository.dart';
import 'package:catat_cuan/domain/usecases/budget/create_budget_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<BudgetWriteRepository>(),
])
import 'create_budget_usecase_test.mocks.dart';

void main() {
  late CreateBudgetUseCase useCase;
  late MockBudgetWriteRepository mockRepository;

  setUp(() {
    mockRepository = MockBudgetWriteRepository();
    useCase = CreateBudgetUseCase(mockRepository);
  });

  group('CreateBudgetUseCase', () {
    test('should create budget successfully with valid data', () async {
      // Arrange
      const params = CreateBudgetParams(
        categoryId: 1,
        year: 2026,
        month: 5,
        amount: 500000.0,
      );

      final budget = BudgetEntity(
        id: 1,
        categoryId: 1,
        year: 2026,
        month: 5,
        amount: 500000.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockRepository.createBudget(
        categoryId: anyNamed('categoryId'),
        year: anyNamed('year'),
        month: anyNamed('month'),
        amount: anyNamed('amount'),
      )).thenAnswer((_) async => Result.success(budget));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.categoryId, equals(1));
      expect(result.data?.amount, equals(500000.0));
      verify(mockRepository.createBudget(
        categoryId: 1,
        year: 2026,
        month: 5,
        amount: 500000.0,
      )).called(1);
    });

    test('should return ValidationFailure when amount is zero', () async {
      // Arrange
      const params = CreateBudgetParams(
        categoryId: 1,
        year: 2026,
        month: 5,
        amount: 0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      verifyNever(mockRepository.createBudget(
        categoryId: anyNamed('categoryId'),
        year: anyNamed('year'),
        month: anyNamed('month'),
        amount: anyNamed('amount'),
      ));
    });

    test('should return ValidationFailure when amount is negative', () async {
      // Arrange
      const params = CreateBudgetParams(
        categoryId: 1,
        year: 2026,
        month: 5,
        amount: -100000.0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      verifyNever(mockRepository.createBudget(
        categoryId: anyNamed('categoryId'),
        year: anyNamed('year'),
        month: anyNamed('month'),
        amount: anyNamed('amount'),
      ));
    });

    test('should return ValidationFailure when month is 0', () async {
      // Arrange
      const params = CreateBudgetParams(
        categoryId: 1,
        year: 2026,
        month: 0,
        amount: 500000.0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      verifyNever(mockRepository.createBudget(
        categoryId: anyNamed('categoryId'),
        year: anyNamed('year'),
        month: anyNamed('month'),
        amount: anyNamed('amount'),
      ));
    });

    test('should return ValidationFailure when month is 13', () async {
      // Arrange
      const params = CreateBudgetParams(
        categoryId: 1,
        year: 2026,
        month: 13,
        amount: 500000.0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      verifyNever(mockRepository.createBudget(
        categoryId: anyNamed('categoryId'),
        year: anyNamed('year'),
        month: anyNamed('month'),
        amount: anyNamed('amount'),
      ));
    });

    test('should return ValidationFailure when year is before 2020', () async {
      // Arrange
      const params = CreateBudgetParams(
        categoryId: 1,
        year: 2019,
        month: 5,
        amount: 500000.0,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      verifyNever(mockRepository.createBudget(
        categoryId: anyNamed('categoryId'),
        year: anyNamed('year'),
        month: anyNamed('month'),
        amount: anyNamed('amount'),
      ));
    });

    test('should accept boundary values: month 1 and 12', () async {
      // Arrange - month 1
      const params1 = CreateBudgetParams(
        categoryId: 1,
        year: 2026,
        month: 1,
        amount: 500000.0,
      );

      final budget = BudgetEntity(
        id: 1,
        categoryId: 1,
        year: 2026,
        month: 1,
        amount: 500000.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockRepository.createBudget(
        categoryId: anyNamed('categoryId'),
        year: anyNamed('year'),
        month: anyNamed('month'),
        amount: anyNamed('amount'),
      )).thenAnswer((_) async => Result.success(budget));

      // Act
      final result1 = await useCase(params1);

      // Assert
      expect(result1.isSuccess, isTrue);

      // Arrange - month 12
      const params12 = CreateBudgetParams(
        categoryId: 1,
        year: 2026,
        month: 12,
        amount: 500000.0,
      );

      final result12 = await useCase(params12);
      expect(result12.isSuccess, isTrue);
    });

    test('should accept boundary value: year 2020', () async {
      // Arrange
      const params = CreateBudgetParams(
        categoryId: 1,
        year: 2020,
        month: 1,
        amount: 500000.0,
      );

      final budget = BudgetEntity(
        id: 1,
        categoryId: 1,
        year: 2020,
        month: 1,
        amount: 500000.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockRepository.createBudget(
        categoryId: anyNamed('categoryId'),
        year: anyNamed('year'),
        month: anyNamed('month'),
        amount: anyNamed('amount'),
      )).thenAnswer((_) async => Result.success(budget));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test('should return DatabaseFailure on repository exception', () async {
      // Arrange
      const params = CreateBudgetParams(
        categoryId: 1,
        year: 2026,
        month: 5,
        amount: 500000.0,
      );

      when(mockRepository.createBudget(
        categoryId: anyNamed('categoryId'),
        year: anyNamed('year'),
        month: anyNamed('month'),
        amount: anyNamed('amount'),
      )).thenThrow(Exception('Database error'));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
    });
  });
}
