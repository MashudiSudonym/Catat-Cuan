import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_write_repository.dart';
import 'package:catat_cuan/domain/usecases/add_category_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../../helpers/test_fixtures.dart';

@GenerateNiceMocks([
  MockSpec<CategoryWriteRepository>(),
  MockSpec<CategoryReadRepository>(),
])
import 'add_category_usecase_test.mocks.dart';

void main() {
  late AddCategoryUseCase useCase;
  late MockCategoryWriteRepository mockWriteRepository;
  late MockCategoryReadRepository mockReadRepository;

  setUp(() {
    mockWriteRepository = MockCategoryWriteRepository();
    mockReadRepository = MockCategoryReadRepository();
    useCase = AddCategoryUseCase(mockWriteRepository, mockReadRepository);
  });

  group('AddCategoryUseCase', () {
    test('should add category successfully with valid data', () async {
      // Arrange
      final category = CategoryEntity(
        name: 'Makan',
        type: CategoryType.expense,
        color: '#FF0000',
        icon: '🍽️',
        sortOrder: 1,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockReadRepository.getCategoryByName('Makan', CategoryType.expense))
          .thenAnswer((_) async => Result.success(null));

      when(mockWriteRepository.addCategory(any))
          .thenAnswer((_) async => Result.success(category.copyWith(id: 1)));

      // Act
      final result = await useCase(category);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.id, equals(1));
      expect(result.data?.name, equals('Makan'));
      verify(mockReadRepository.getCategoryByName('Makan', CategoryType.expense)).called(1);
      verify(mockWriteRepository.addCategory(any)).called(1);
    });

    test('should return validation failure when name is empty', () async {
      // Arrange
      final category = TestFixtures.categoryFood(name: '   ');

      // Act
      final result = await useCase(category);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('Nama kategori tidak boleh kosong'));
      verifyNever(mockReadRepository.getCategoryByName(any, any));
      verifyNever(mockWriteRepository.addCategory(any));
    });

    test('should return validation failure when name is less than 2 characters', () async {
      // Arrange
      final category = TestFixtures.categoryFood(name: 'M');

      // Act
      final result = await useCase(category);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('Nama kategori minimal 2 karakter'));
      verifyNever(mockReadRepository.getCategoryByName(any, any));
      verifyNever(mockWriteRepository.addCategory(any));
    });

    test('should return validation failure when name is more than 50 characters', () async {
      // Arrange
      final category = TestFixtures.categoryFood(name: 'A' * 51);

      // Act
      final result = await useCase(category);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('Nama kategori maksimal 50 karakter'));
      verifyNever(mockReadRepository.getCategoryByName(any, any));
      verifyNever(mockWriteRepository.addCategory(any));
    });

    test('should return validation failure when category name already exists', () async {
      // Arrange
      final category = TestFixtures.categoryFood(name: 'Makan');
      final existingCategory = TestFixtures.categoryFood(id: 1, name: 'Makan');

      when(mockReadRepository.getCategoryByName('Makan', CategoryType.expense))
          .thenAnswer((_) async => Result.success(existingCategory));

      // Act
      final result = await useCase(category);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('sudah ada'));
      verify(mockReadRepository.getCategoryByName('Makan', CategoryType.expense)).called(1);
      verifyNever(mockWriteRepository.addCategory(any));
    });

    test('should allow same name for different category types', () async {
      // Arrange
      final incomeCategory = TestFixtures.categorySalary(name: 'Makan', type: CategoryType.income);

      when(mockReadRepository.getCategoryByName('Makan', CategoryType.income))
          .thenAnswer((_) async => Result.success(null));

      when(mockWriteRepository.addCategory(any))
          .thenAnswer((_) async => Result.success(incomeCategory.copyWith(id: 2)));

      // Act
      final result = await useCase(incomeCategory);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockReadRepository.getCategoryByName('Makan', CategoryType.income)).called(1);
      verify(mockWriteRepository.addCategory(any)).called(1);
    });

    test('should auto-assign color when not provided', () async {
      // Arrange
      final category = CategoryEntity(
        name: 'Test',
        type: CategoryType.expense,
        color: '',
        icon: null,
        sortOrder: 0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockReadRepository.getCategoryByName('Test', CategoryType.expense))
          .thenAnswer((_) async => Result.success(null));

      when(mockWriteRepository.addCategory(any))
          .thenAnswer((_) async => Result.success(category.copyWith(id: 1)));

      // Act
      final result = await useCase(category);

      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(mockWriteRepository.addCategory(captureAny)).captured.single as CategoryEntity;
      expect(captured.color, isNotEmpty);
    });

    test('should auto-assign icon when not provided', () async {
      // Arrange
      final category = CategoryEntity(
        name: 'Test',
        type: CategoryType.expense,
        color: '#FF0000',
        icon: null,
        sortOrder: 0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockReadRepository.getCategoryByName('Test', CategoryType.expense))
          .thenAnswer((_) async => Result.success(null));

      when(mockWriteRepository.addCategory(any))
          .thenAnswer((_) async => Result.success(category.copyWith(id: 1)));

      // Act
      final result = await useCase(category);

      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(mockWriteRepository.addCategory(captureAny)).captured.single as CategoryEntity;
      expect(captured.icon, isNotNull);
      expect(captured.icon?.isNotEmpty, isTrue);
    });

    test('should trim whitespace from name', () async {
      // Arrange
      final category = TestFixtures.categoryFood(name: '  Makan  ');

      when(mockReadRepository.getCategoryByName('Makan', CategoryType.expense))
          .thenAnswer((_) async => Result.success(null));

      when(mockWriteRepository.addCategory(any))
          .thenAnswer((_) async => Result.success(category.copyWith(id: 1)));

      // Act
      final result = await useCase(category);

      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(mockWriteRepository.addCategory(captureAny)).captured.single as CategoryEntity;
      expect(captured.name, equals('Makan'));
      expect(captured.name, isNot(contains(' ')));
    });

    test('should return database failure when repository throws exception', () async {
      // Arrange
      final category = TestFixtures.categoryFood();

      when(mockReadRepository.getCategoryByName('Makan', CategoryType.expense))
          .thenAnswer((_) async => Result.success(null));

      when(mockWriteRepository.addCategory(any))
          .thenThrow(Exception('Database error'));

      // Act
      final result = await useCase(category);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
      expect(result.failure?.message, contains('Gagal menambah kategori'));
    });
  });
}
