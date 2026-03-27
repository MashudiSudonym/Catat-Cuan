import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/usecases/category/get_categories_usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import '../../../helpers/test_fixtures.dart';

class FakeCategoryReadRepository implements CategoryReadRepository {
  final List<CategoryEntity> categories;
  final String? errorMessage;

  FakeCategoryReadRepository({
    required this.categories,
    this.errorMessage,
  });

  @override
  Future<Result<List<CategoryEntity>>> getCategories() async {
    if (errorMessage != null) {
      return Result.failure(DatabaseFailure(errorMessage!));
    }
    return Result.success(categories);
  }

  @override
  Future<Result<CategoryEntity>> getCategoryById(int id) async {
    final category = categories.cast<CategoryEntity?>().firstWhere(
      (cat) => cat?.id == id,
      orElse: () => null,
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
  group('GetCategoriesUseCase', () {
    test('should return all categories when repository returns data', () async {
      // Arrange
      final categories = TestFixtures.defaultCategories;
      final fakeRepository = FakeCategoryReadRepository(categories: categories);
      final useCase = GetCategoriesUseCase(fakeRepository);

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(categories));
      expect(result.data?.length, equals(3));
    });

    test('should return empty list when no categories exist', () async {
      // Arrange
      final fakeRepository = FakeCategoryReadRepository(categories: []);
      final useCase = GetCategoriesUseCase(fakeRepository);

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
    });

    test('should return failure when repository throws exception', () async {
      // Arrange
      final fakeRepository = FakeCategoryReadRepository(
        categories: [],
        errorMessage: 'Database connection failed',
      );
      final useCase = GetCategoriesUseCase(fakeRepository);

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
      expect(result.failure?.message, contains('Database connection failed'));
    });

    test('should extend UseCase with correct types', () {
      // Arrange
      final fakeRepository = FakeCategoryReadRepository(
        categories: TestFixtures.defaultCategories,
      );
      final useCase = GetCategoriesUseCase(fakeRepository);

      // Assert
      expect(useCase, isA<UseCase<List<CategoryEntity>, NoParams>>());
    });

    test('should accept NoParams as parameter type', () async {
      // Arrange
      final fakeRepository = FakeCategoryReadRepository(
        categories: TestFixtures.defaultCategories,
      );
      final useCase = GetCategoriesUseCase(fakeRepository);

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
    });
  });
}
