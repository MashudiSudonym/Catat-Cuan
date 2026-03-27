import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/usecases/category/get_category_by_id_usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import '../../../helpers/test_fixtures.dart';

class FakeCategoryReadRepository implements CategoryReadRepository {
  final List<CategoryEntity> categories;
  final CategoryEntity? notFoundCategory;

  FakeCategoryReadRepository({
    required this.categories,
    this.notFoundCategory,
  });

  @override
  Future<Result<List<CategoryEntity>>> getCategories() async {
    return Result.success(categories);
  }

  @override
  Future<Result<CategoryEntity>> getCategoryById(int id) async {
    final category = categories.cast<CategoryEntity?>().firstWhere(
      (cat) => cat?.id == id,
      orElse: () => notFoundCategory,
    );
    if (category != null) {
      return Result.success(category);
    }
    return Result.failure(NotFoundFailure('Category not found'));
  }

  @override
  Future<Result<List<CategoryEntity>>> getCategoriesByType(CategoryType type) async {
    final filtered = categories.where((cat) => cat.type == type).toList();
    return Result.success(filtered);
  }

  @override
  Future<Result<List<CategoryEntity>>> getCategoriesWithCount(CategoryType type) async {
    return Result.success(categories);
  }

  @override
  Future<Result<CategoryEntity?>> getCategoryByName(
    String name,
    CategoryType type, {
    int? excludeId,
  }) async {
    final category = categories.cast<CategoryEntity?>().firstWhere(
      (cat) => cat?.name == name && cat?.type == type && cat?.id != excludeId,
      orElse: () => null,
    );
    return Result.success(category);
  }

  @override
  Future<Result<int>> getTransactionCount(int categoryId) async {
    return Result.success(0);
  }
}

void main() {
  group('GetCategoryByIdUseCase', () {
    test('should return category when found by ID', () async {
      // Arrange
      final category = TestFixtures.categoryFood(id: 1);
      final fakeRepository = FakeCategoryReadRepository(categories: [category]);
      final useCase = GetCategoryByIdUseCase(fakeRepository);

      // Act
      final result = await useCase(1);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(category));
      expect(result.data?.id, equals(1));
      expect(result.data?.name, equals('Makan'));
    });

    test('should return NotFoundFailure when category does not exist', () async {
      // Arrange
      final fakeRepository = FakeCategoryReadRepository(
        categories: [],
        notFoundCategory: null,
      );
      final useCase = GetCategoryByIdUseCase(fakeRepository);

      // Act
      final result = await useCase(999);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<NotFoundFailure>());
      expect(result.failure?.message, contains('Category not found'));
    });

    test('should return income category when found', () async {
      // Arrange
      final category = TestFixtures.categorySalary(id: 3);
      final fakeRepository = FakeCategoryReadRepository(categories: [category]);
      final useCase = GetCategoryByIdUseCase(fakeRepository);

      // Act
      final result = await useCase(3);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.type, equals(CategoryType.income));
      expect(result.data?.name, equals('Gaji'));
    });

    test('should return expense category when found', () async {
      // Arrange
      final category = TestFixtures.categoryTransport(id: 2);
      final fakeRepository = FakeCategoryReadRepository(categories: [category]);
      final useCase = GetCategoryByIdUseCase(fakeRepository);

      // Act
      final result = await useCase(2);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.type, equals(CategoryType.expense));
      expect(result.data?.name, equals('Transport'));
    });

    test('should get inactive category', () async {
      // Arrange
      final inactiveCategory = TestFixtures.categoryFood(isActive: false);
      final fakeRepository = FakeCategoryReadRepository(categories: [inactiveCategory]);
      final useCase = GetCategoryByIdUseCase(fakeRepository);

      // Act
      final result = await useCase(1);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.isActive, isFalse);
    });

    test('should extend UseCase with correct types', () {
      // Arrange
      final fakeRepository = FakeCategoryReadRepository(
        categories: TestFixtures.defaultCategories,
      );
      final useCase = GetCategoryByIdUseCase(fakeRepository);

      // Assert
      expect(useCase, isA<UseCase<CategoryEntity, int>>());
    });

    test('should accept int as parameter type', () async {
      // Arrange
      final category = TestFixtures.categoryFood();
      final fakeRepository = FakeCategoryReadRepository(categories: [category]);
      final useCase = GetCategoryByIdUseCase(fakeRepository);

      // Act
      final result = await useCase(1);

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test('should handle large ID values', () async {
      // Arrange
      final category = TestFixtures.categoryFood(id: 999999);
      final fakeRepository = FakeCategoryReadRepository(categories: [category]);
      final useCase = GetCategoryByIdUseCase(fakeRepository);

      // Act
      final result = await useCase(999999);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.id, equals(999999));
    });
  });
}
