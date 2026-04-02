import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_write_repository.dart';
import 'package:catat_cuan/domain/usecases/deactivate_category_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../../helpers/test_fixtures.dart';

@GenerateNiceMocks([
  MockSpec<CategoryWriteRepository>(),
  MockSpec<CategoryReadRepository>(),
])
import 'deactivate_category_usecase_test.mocks.dart';

void main() {
  late DeactivateCategoryUseCase useCase;
  late MockCategoryWriteRepository mockWriteRepository;
  late MockCategoryReadRepository mockReadRepository;

  setUp(() {
    mockWriteRepository = MockCategoryWriteRepository();
    mockReadRepository = MockCategoryReadRepository();
    useCase = DeactivateCategoryUseCase(mockWriteRepository, mockReadRepository);
  });

  group('DeactivateCategoryUseCase', () {
    test('should deactivate category successfully when no transactions', () async {
      // Arrange
      final category = TestFixtures.categoryFood(id: 1, isActive: true);

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(category));

      when(mockReadRepository.getTransactionCount(1))
          .thenAnswer((_) async => Result.success(0));

      when(mockWriteRepository.deleteCategory(1))
          .thenAnswer((_) async => Result.success(null));

      // Act
      final result = await useCase(1);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockReadRepository.getCategoryById(1)).called(1);
      verify(mockReadRepository.getTransactionCount(1)).called(1);
      verify(mockWriteRepository.deleteCategory(1)).called(1);
    });

    test('should return not found failure when category does not exist', () async {
      // Arrange
      when(mockReadRepository.getCategoryById(999))
          .thenAnswer((_) async => Result.failure(NotFoundFailure('Kategori tidak ditemukan')));

      // Act
      final result = await useCase(999);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<NotFoundFailure>());
      verify(mockReadRepository.getCategoryById(999)).called(1);
      verifyNever(mockReadRepository.getTransactionCount(any));
      verifyNever(mockWriteRepository.deleteCategory(any));
    });

    test('should return validation failure when category is already inactive', () async {
      // Arrange
      final category = TestFixtures.categoryFood(id: 1, isActive: false);

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(category));

      // Act
      final result = await useCase(1);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('Kategori sudah tidak aktif'));
      verifyNever(mockReadRepository.getTransactionCount(any));
      verifyNever(mockWriteRepository.deleteCategory(any));
    });

    test('should return validation failure when category has transactions', () async {
      // Arrange
      final category = TestFixtures.categoryFood(id: 1, isActive: true);

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(category));

      when(mockReadRepository.getTransactionCount(1))
          .thenAnswer((_) async => Result.success(5));

      // Act
      final result = await useCase(1);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('tidak dapat dinonaktifkan karena masih digunakan'));
      expect(result.failure?.message, contains('5 transaksi'));
      verifyNever(mockWriteRepository.deleteCategory(any));
    });

    test('should return validation failure with singular form when category has 1 transaction', () async {
      // Arrange
      final category = TestFixtures.categoryFood(id: 1, isActive: true);

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(category));

      when(mockReadRepository.getTransactionCount(1))
          .thenAnswer((_) async => Result.success(1));

      // Act
      final result = await useCase(1);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('1 transaksi')); // singular form
      verifyNever(mockWriteRepository.deleteCategory(any));
    });

    test('should handle transaction count gracefully when getTransactionCount returns null', () async {
      // Arrange
      final category = TestFixtures.categoryFood(id: 1, isActive: true);

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(category));

      when(mockReadRepository.getTransactionCount(1))
          .thenAnswer((_) async => Result.success(0)); // 0 count

      when(mockWriteRepository.deleteCategory(1))
          .thenAnswer((_) async => Result.success(null));

      // Act
      final result = await useCase(1);

      // Assert
      expect(result.isSuccess, isTrue);
      // Should treat 0 as allowing deletion
      verify(mockWriteRepository.deleteCategory(1)).called(1);
    });

    test('should return database failure when repository throws exception', () async {
      // Arrange
      final category = TestFixtures.categoryFood(id: 1, isActive: true);

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(category));

      when(mockReadRepository.getTransactionCount(1))
          .thenAnswer((_) async => Result.success(0));

      when(mockWriteRepository.deleteCategory(1))
          .thenThrow(Exception('Database error'));

      // Act
      final result = await useCase(1);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
      expect(result.failure?.message, contains('Gagal menonaktifkan kategori'));
    });

    test('should return database failure when getTransactionCount fails', () async {
      // Arrange
      final category = TestFixtures.categoryFood(id: 1, isActive: true);

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(category));

      when(mockReadRepository.getTransactionCount(1))
          .thenThrow(Exception('Database error'));

      // Act
      final result = await useCase(1);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
      expect(result.failure?.message, contains('Gagal menonaktifkan kategori'));
      verifyNever(mockWriteRepository.deleteCategory(any));
    });

    test('should return database failure when getCategoryById fails', () async {
      // Arrange
      when(mockReadRepository.getCategoryById(1))
          .thenThrow(Exception('Database error'));

      // Act
      final result = await useCase(1);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
      expect(result.failure?.message, contains('Gagal menonaktifkan kategori'));
    });

    test('should extend UseCase with correct types', () {
      // Assert
      expect(useCase, isA<UseCase<void, int>>());
    });
  });
}
