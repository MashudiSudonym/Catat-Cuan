import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_management_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'package:catat_cuan/domain/usecases/reorder_categories_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../../helpers/test_fixtures.dart';

@GenerateNiceMocks([
  MockSpec<CategoryManagementRepository>(),
  MockSpec<CategoryReadRepository>(),
])
import 'reorder_categories_usecase_test.mocks.dart';

void main() {
  late ReorderCategoriesUseCase useCase;
  late MockCategoryManagementRepository mockManagementRepository;
  late MockCategoryReadRepository mockReadRepository;

  setUp(() {
    mockManagementRepository = MockCategoryManagementRepository();
    mockReadRepository = MockCategoryReadRepository();
    useCase = ReorderCategoriesUseCase(mockManagementRepository, mockReadRepository);
  });

  group('ReorderCategoriesUseCase', () {
    test('should reorder categories successfully with valid IDs', () async {
      // Arrange
      final categoryIds = [1, 2, 3];
      final categories = [
        TestFixtures.categoryFood(id: 1),
        TestFixtures.categoryTransport(id: 2),
        TestFixtures.categorySalary(id: 3),
      ];

      for (var i = 0; i < categoryIds.length; i++) {
        when(mockReadRepository.getCategoryById(categoryIds[i]))
            .thenAnswer((_) async => Result.success(categories[i]));
      }

      when(mockManagementRepository.reorderCategories(categoryIds))
          .thenAnswer((_) async => Result.success(null));

      // Act
      final result = await useCase(categoryIds);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockReadRepository.getCategoryById(1)).called(1);
      verify(mockReadRepository.getCategoryById(2)).called(1);
      verify(mockReadRepository.getCategoryById(3)).called(1);
      verify(mockManagementRepository.reorderCategories(categoryIds)).called(1);
    });

    test('should return validation failure when list is empty', () async {
      // Arrange
      final categoryIds = <int>[];

      // Act
      final result = await useCase(categoryIds);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('Daftar kategori tidak boleh kosong'));
      verifyNever(mockReadRepository.getCategoryById(any));
      verifyNever(mockManagementRepository.reorderCategories(any));
    });

    test('should return validation failure when list contains duplicate IDs', () async {
      // Arrange
      final categoryIds = [1, 2, 1];

      // Act
      final result = await useCase(categoryIds);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('duplikasi ID kategori'));
      verifyNever(mockReadRepository.getCategoryById(any));
      verifyNever(mockManagementRepository.reorderCategories(any));
    });

    test('should return not found failure when category does not exist', () async {
      // Arrange
      final categoryIds = [1, 2, 999];

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(TestFixtures.categoryFood(id: 1)));

      when(mockReadRepository.getCategoryById(2))
          .thenAnswer((_) async => Result.success(TestFixtures.categoryTransport(id: 2)));

      when(mockReadRepository.getCategoryById(999))
          .thenAnswer((_) async => Result.failure(NotFoundFailure('Kategori tidak ditemukan')));

      // Act
      final result = await useCase(categoryIds);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<NotFoundFailure>());
      expect(result.failure?.message, contains('999'));
      verify(mockReadRepository.getCategoryById(1)).called(1);
      verify(mockReadRepository.getCategoryById(2)).called(1);
      verify(mockReadRepository.getCategoryById(999)).called(1);
      verifyNever(mockManagementRepository.reorderCategories(any));
    });

    test('should return not found failure when getCategoryById returns null', () async {
      // Arrange
      final categoryIds = [1, 2];

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(TestFixtures.categoryFood(id: 1)));

      when(mockReadRepository.getCategoryById(2))
          .thenAnswer((_) async => Result.failure(NotFoundFailure('Kategori tidak ditemukan')));

      // Act
      final result = await useCase(categoryIds);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<NotFoundFailure>());
      verifyNever(mockManagementRepository.reorderCategories(any));
    });

    test('should return database failure when management repository throws exception', () async {
      // Arrange
      final categoryIds = [1, 2, 3];

      for (var id in categoryIds) {
        when(mockReadRepository.getCategoryById(id))
            .thenAnswer((_) async => Result.success(TestFixtures.categoryFood(id: id)));
      }

      when(mockManagementRepository.reorderCategories(categoryIds))
          .thenThrow(Exception('Database error'));

      // Act
      final result = await useCase(categoryIds);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
      expect(result.failure?.message, contains('Gagal mengubah urutan kategori'));
    });

    test('should return database failure when read repository throws exception', () async {
      // Arrange
      final categoryIds = [1, 2];

      when(mockReadRepository.getCategoryById(1))
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(() => useCase(categoryIds), throwsA(isA<Exception>()));
    });

    test('should return failure when reorderCategories fails', () async {
      // Arrange
      final categoryIds = [1, 2];

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(TestFixtures.categoryFood(id: 1)));

      when(mockReadRepository.getCategoryById(2))
          .thenAnswer((_) async => Result.success(TestFixtures.categoryTransport(id: 2)));

      when(mockManagementRepository.reorderCategories(categoryIds))
          .thenAnswer((_) async => Result.failure(DatabaseFailure('Failed to reorder')));

      // Act
      final result = await useCase(categoryIds);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
    });

    test('should handle single item list', () async {
      // Arrange
      final categoryIds = [1];

      when(mockReadRepository.getCategoryById(1))
          .thenAnswer((_) async => Result.success(TestFixtures.categoryFood(id: 1)));

      when(mockManagementRepository.reorderCategories(categoryIds))
          .thenAnswer((_) async => Result.success(null));

      // Act
      final result = await useCase(categoryIds);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockManagementRepository.reorderCategories([1])).called(1);
    });

    test('should extend UseCase with correct types', () {
      // Assert
      expect(useCase, isA<UseCase<void, List<int>>>());
    });
  });
}
