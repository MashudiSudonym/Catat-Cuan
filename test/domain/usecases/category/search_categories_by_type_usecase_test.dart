import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/usecases/category/search_categories_by_type_usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/usecases/category/search_categories_params.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
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
    if (errorMessage != null) {
      return Result.failure(DatabaseFailure(errorMessage!));
    }
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
  group('SearchCategoriesByTypeUseCase', () {
    test('should return validation failure when typeFilter is null', () async {
      // Arrange
      final fakeRepository = FakeCategoryReadRepository(
        categories: TestFixtures.defaultCategories,
      );
      final useCase = SearchCategoriesByTypeUseCase(fakeRepository);

      // Act
      final result = await useCase(const SearchCategoriesParams(query: 'test'));

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('Tipe kategori wajib ditentukan'));
    });

    test('should return all expense categories when query is empty', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(type: CategoryType.expense),
        TestFixtures.categoryTransport(type: CategoryType.expense),
        TestFixtures.categorySalary(type: CategoryType.income),
      ];
      final fakeRepository = FakeCategoryReadRepository(categories: categories);
      final useCase = SearchCategoriesByTypeUseCase(fakeRepository);

      // Act
      final result = await useCase(
        const SearchCategoriesParams(
          query: '',
          typeFilter: CategoryType.expense,
        ),
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.length, equals(2));
      expect(result.data?.every((cat) => cat.type == CategoryType.expense), isTrue);
    });

    test('should filter categories by query case-insensitively', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(name: 'Makan', type: CategoryType.expense),
        TestFixtures.categoryTransport(name: 'Transport', type: CategoryType.expense),
      ];
      final fakeRepository = FakeCategoryReadRepository(categories: categories);
      final useCase = SearchCategoriesByTypeUseCase(fakeRepository);

      // Act
      final result = await useCase(
        const SearchCategoriesParams(
          query: 'mak',
          typeFilter: CategoryType.expense,
        ),
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.length, equals(1));
      expect(result.data?.first.name, equals('Makan'));
    });

    test('should trim whitespace from query', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(name: 'Makan', type: CategoryType.expense),
      ];
      final fakeRepository = FakeCategoryReadRepository(categories: categories);
      final useCase = SearchCategoriesByTypeUseCase(fakeRepository);

      // Act
      final result = await useCase(
        const SearchCategoriesParams(
          query: '  Makan  ',
          typeFilter: CategoryType.expense,
        ),
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.length, equals(1));
    });

    test('should return empty list when no match found', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(name: 'Makan', type: CategoryType.expense),
      ];
      final fakeRepository = FakeCategoryReadRepository(categories: categories);
      final useCase = SearchCategoriesByTypeUseCase(fakeRepository);

      // Act
      final result = await useCase(
        const SearchCategoriesParams(
          query: 'xyz',
          typeFilter: CategoryType.expense,
        ),
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
    });

    test('should only return categories of specified type', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(name: 'Makan', type: CategoryType.expense),
        TestFixtures.categorySalary(name: 'Makanan', type: CategoryType.income),
      ];
      final fakeRepository = FakeCategoryReadRepository(categories: categories);
      final useCase = SearchCategoriesByTypeUseCase(fakeRepository);

      // Act
      final result = await useCase(
        const SearchCategoriesParams(
          query: 'mak',
          typeFilter: CategoryType.expense,
        ),
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.length, equals(1));
      expect(result.data?.first.type, equals(CategoryType.expense));
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final fakeRepository = FakeCategoryReadRepository(
        categories: [],
        errorMessage: 'Database error',
      );
      final useCase = SearchCategoriesByTypeUseCase(fakeRepository);

      // Act
      final result = await useCase(
        const SearchCategoriesParams(
          query: 'test',
          typeFilter: CategoryType.expense,
        ),
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
    });

    test('should extend UseCase with correct types', () {
      // Arrange
      final fakeRepository = FakeCategoryReadRepository(
        categories: TestFixtures.defaultCategories,
      );
      final useCase = SearchCategoriesByTypeUseCase(fakeRepository);

      // Assert
      expect(useCase, isA<UseCase<List<CategoryEntity>, SearchCategoriesParams>>());
    });
  });
}
