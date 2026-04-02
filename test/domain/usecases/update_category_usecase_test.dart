import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_write_repository.dart';
import 'package:catat_cuan/domain/usecases/update_category_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../../helpers/test_fixtures.dart';

@GenerateNiceMocks([
  MockSpec<CategoryWriteRepository>(),
  MockSpec<CategoryReadRepository>(),
])
import 'update_category_usecase_test.mocks.dart';

void main() {
  late UpdateCategoryUseCase useCase;
  late MockCategoryWriteRepository mockWriteRepository;
  late MockCategoryReadRepository mockReadRepository;

  setUp(() {
    mockWriteRepository = MockCategoryWriteRepository();
    mockReadRepository = MockCategoryReadRepository();
    useCase = UpdateCategoryUseCase(mockWriteRepository, mockReadRepository);
  });

  group('UpdateCategoryUseCase', () {
    test('should update category successfully with valid data', () async {
      // Arrange
      final existingCategory = TestFixtures.categoryFood(id: 1, name: 'Makan');
      final updatedCategory = TestFixtures.categoryFood(id: 1, name: 'Makanan');

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(existingCategory));

      when(mockReadRepository.getCategoryByName('Makanan', CategoryType.expense, excludeId: 1))
          .thenAnswer((_) async => Result.success(null));

      when(mockWriteRepository.updateCategory(any))
          .thenAnswer((_) async => Result.success(updatedCategory));

      // Act
      final result = await useCase(updatedCategory);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.name, equals('Makanan'));
      verify(mockReadRepository.getCategoryById(1)).called(1);
      verify(mockReadRepository.getCategoryByName('Makanan', CategoryType.expense, excludeId: 1)).called(1);
      verify(mockWriteRepository.updateCategory(any)).called(1);
    });

    test('should return validation failure when id is null', () async {
      // Arrange
      final category = TestFixtures.categoryFood(id: null);

      // Act
      final result = await useCase(category);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('ID kategori wajib diisi'));
      verifyNever(mockReadRepository.getCategoryById(any));
      verifyNever(mockWriteRepository.updateCategory(any));
    });

    test('should return not found failure when category does not exist', () async {
      // Arrange
      final category = TestFixtures.categoryFood(id: 999);

      when(mockReadRepository.getCategoryById(999))
          .thenAnswer((_) async => Result.failure(NotFoundFailure('Kategori tidak ditemukan')));

      // Act
      final result = await useCase(category);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<NotFoundFailure>());
      verify(mockReadRepository.getCategoryById(999)).called(1);
      verifyNever(mockWriteRepository.updateCategory(any));
    });

    test('should return validation failure when trying to change category type', () async {
      // Arrange
      final existingCategory = TestFixtures.categoryFood(id: 1, type: CategoryType.expense);
      final updatedCategory = TestFixtures.categoryFood(id: 1, type: CategoryType.income);

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(existingCategory));

      // Act
      final result = await useCase(updatedCategory);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('Tipe kategori tidak dapat diubah'));
      verifyNever(mockWriteRepository.updateCategory(any));
    });

    test('should return validation failure when name is empty', () async {
      // Arrange
      final existingCategory = TestFixtures.categoryFood(id: 1);
      final updatedCategory = TestFixtures.categoryFood(id: 1, name: '   ');

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(existingCategory));

      // Act
      final result = await useCase(updatedCategory);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('Nama kategori tidak boleh kosong'));
      verifyNever(mockWriteRepository.updateCategory(any));
    });

    test('should return validation failure when name is less than 2 characters', () async {
      // Arrange
      final existingCategory = TestFixtures.categoryFood(id: 1);
      final updatedCategory = TestFixtures.categoryFood(id: 1, name: 'M');

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(existingCategory));

      // Act
      final result = await useCase(updatedCategory);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('Nama kategori minimal 2 karakter'));
    });

    test('should return validation failure when name is more than 50 characters', () async {
      // Arrange
      final existingCategory = TestFixtures.categoryFood(id: 1);
      final updatedCategory = TestFixtures.categoryFood(id: 1, name: 'A' * 51);

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(existingCategory));

      // Act
      final result = await useCase(updatedCategory);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('Nama kategori maksimal 50 karakter'));
    });

    test('should return validation failure when new name already exists', () async {
      // Arrange
      final existingCategory = TestFixtures.categoryFood(id: 1, name: 'Makan');
      final updatedCategory = TestFixtures.categoryFood(id: 1, name: 'Transport');
      final duplicateCategory = TestFixtures.categoryTransport(id: 2, name: 'Transport');

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(existingCategory));

      when(mockReadRepository.getCategoryByName('Transport', CategoryType.expense, excludeId: 1))
          .thenAnswer((_) async => Result.success(duplicateCategory));

      // Act
      final result = await useCase(updatedCategory);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('sudah ada'));
      verifyNever(mockWriteRepository.updateCategory(any));
    });

    test('should preserve existing type when updating', () async {
      // Arrange
      final existingCategory = TestFixtures.categoryFood(id: 1, type: CategoryType.expense);
      final updatedCategory = TestFixtures.categoryFood(id: 1, name: 'Makanan');

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(existingCategory));

      when(mockReadRepository.getCategoryByName('Makanan', CategoryType.expense, excludeId: 1))
          .thenAnswer((_) async => Result.success(null));

      when(mockWriteRepository.updateCategory(any))
          .thenAnswer((_) async => Result.success(updatedCategory));

      // Act
      final result = await useCase(updatedCategory);

      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(mockWriteRepository.updateCategory(captureAny)).captured.single as CategoryEntity;
      expect(captured.type, equals(CategoryType.expense));
    });

    test('should preserve existing color when new color is empty', () async {
      // Arrange
      final existingCategory = TestFixtures.categoryFood(id: 1, color: '#FF0000');
      final updatedCategory = TestFixtures.categoryFood(id: 1, color: '');

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(existingCategory));

      when(mockReadRepository.getCategoryByName('Makan', CategoryType.expense, excludeId: 1))
          .thenAnswer((_) async => Result.success(null));

      when(mockWriteRepository.updateCategory(any))
          .thenAnswer((_) async => Result.success(updatedCategory));

      // Act
      final result = await useCase(updatedCategory);

      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(mockWriteRepository.updateCategory(captureAny)).captured.single as CategoryEntity;
      expect(captured.color, equals('#FF0000'));
    });

    test('should preserve existing icon when new icon is empty', () async {
      // Arrange
      final existingCategory = TestFixtures.categoryFood(id: 1, icon: '🍽️');
      final updatedCategory = TestFixtures.categoryFood(id: 1, icon: null);

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(existingCategory));

      when(mockReadRepository.getCategoryByName('Makan', CategoryType.expense, excludeId: 1))
          .thenAnswer((_) async => Result.success(null));

      when(mockWriteRepository.updateCategory(any))
          .thenAnswer((_) async => Result.success(updatedCategory));

      // Act
      final result = await useCase(updatedCategory);

      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(mockWriteRepository.updateCategory(captureAny)).captured.single as CategoryEntity;
      expect(captured.icon, equals('🍽️'));
    });

    test('should trim whitespace from name', () async {
      // Arrange
      final existingCategory = TestFixtures.categoryFood(id: 1, name: 'Makan');
      final updatedCategory = TestFixtures.categoryFood(id: 1, name: '  Makanan  ');

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(existingCategory));

      when(mockReadRepository.getCategoryByName('Makanan', CategoryType.expense, excludeId: 1))
          .thenAnswer((_) async => Result.success(null));

      when(mockWriteRepository.updateCategory(any))
          .thenAnswer((_) async => Result.success(updatedCategory));

      // Act
      final result = await useCase(updatedCategory);

      // Assert
      expect(result.isSuccess, isTrue);
      final captured = verify(mockWriteRepository.updateCategory(captureAny)).captured.single as CategoryEntity;
      expect(captured.name, equals('Makanan'));
    });

    test('should return database failure when repository throws exception', () async {
      // Arrange
      final existingCategory = TestFixtures.categoryFood(id: 1);
      final updatedCategory = TestFixtures.categoryFood(id: 1, name: 'Makanan');

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(existingCategory));

      when(mockReadRepository.getCategoryByName('Makanan', CategoryType.expense, excludeId: 1))
          .thenAnswer((_) async => Result.success(null));

      when(mockWriteRepository.updateCategory(any))
          .thenThrow(Exception('Database error'));

      // Act
      final result = await useCase(updatedCategory);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
      expect(result.failure?.message, contains('Gagal mengupdate kategori'));
    });
  });
}
