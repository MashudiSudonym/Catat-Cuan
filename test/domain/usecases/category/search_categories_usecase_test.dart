import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/usecases/category/search_categories_usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/usecases/category/search_categories_params.dart';
import 'package:catat_cuan/domain/usecases/category/search_result.dart';
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
  group('SearchCategoriesUseCase', () {
    test('should return all categories when query is empty', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(type: CategoryType.expense),
        TestFixtures.categoryTransport(type: CategoryType.expense),
        TestFixtures.categorySalary(type: CategoryType.income),
      ];
      final fakeRepository = FakeCategoryReadRepository(categories: categories);
      final useCase = SearchCategoriesUseCase(fakeRepository);

      // Act
      final result = await useCase(const SearchCategoriesParams(query: ''));

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.incomeCategories.length, equals(1));
      expect(result.data?.expenseCategories.length, equals(2));
      expect(result.data?.totalCount, equals(3));
    });

    test('should filter categories by query case-insensitively', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(name: 'Makan', type: CategoryType.expense),
        TestFixtures.categoryTransport(name: 'Transport', type: CategoryType.expense),
        TestFixtures.categorySalary(name: 'Gaji', type: CategoryType.income),
      ];
      final fakeRepository = FakeCategoryReadRepository(categories: categories);
      final useCase = SearchCategoriesUseCase(fakeRepository);

      // Act
      final result = await useCase(const SearchCategoriesParams(query: 'mak'));

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.expenseCategories.length, equals(1));
      expect(result.data?.expenseCategories.first.name, equals('Makan'));
      expect(result.data?.incomeCategories, isEmpty);
    });

    test('should filter categories by type when typeFilter is provided', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(type: CategoryType.expense),
        TestFixtures.categoryTransport(type: CategoryType.expense),
        TestFixtures.categorySalary(type: CategoryType.income),
      ];
      final fakeRepository = FakeCategoryReadRepository(categories: categories);
      final useCase = SearchCategoriesUseCase(fakeRepository);

      // Act
      final result = await useCase(
        const SearchCategoriesParams(
          query: '',
          typeFilter: CategoryType.expense,
        ),
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.expenseCategories.length, equals(2));
      expect(result.data?.incomeCategories, isEmpty);
    });

    test('should combine query and typeFilter', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(name: 'Makan Siang', type: CategoryType.expense),
        TestFixtures.categoryTransport(name: 'Transport', type: CategoryType.expense),
        TestFixtures.categorySalary(name: 'Makanan', type: CategoryType.income),
      ];
      final fakeRepository = FakeCategoryReadRepository(categories: categories);
      final useCase = SearchCategoriesUseCase(fakeRepository);

      // Act
      final result = await useCase(
        const SearchCategoriesParams(
          query: 'mak',
          typeFilter: CategoryType.expense,
        ),
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.expenseCategories.length, equals(1));
      expect(result.data?.expenseCategories.first.name, equals('Makan Siang'));
      expect(result.data?.incomeCategories, isEmpty);
    });

    test('should trim whitespace from query', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(name: 'Makan', type: CategoryType.expense),
      ];
      final fakeRepository = FakeCategoryReadRepository(categories: categories);
      final useCase = SearchCategoriesUseCase(fakeRepository);

      // Act
      final result = await useCase(const SearchCategoriesParams(query: '  Makan  '));

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.expenseCategories.length, equals(1));
    });

    test('should return empty results when no match found', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(name: 'Makan', type: CategoryType.expense),
      ];
      final fakeRepository = FakeCategoryReadRepository(categories: categories);
      final useCase = SearchCategoriesUseCase(fakeRepository);

      // Act
      final result = await useCase(const SearchCategoriesParams(query: 'xyz'));

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.expenseCategories, isEmpty);
      expect(result.data?.incomeCategories, isEmpty);
      expect(result.data?.totalCount, equals(0));
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final fakeRepository = FakeCategoryReadRepository(
        categories: [],
        errorMessage: 'Database error',
      );
      final useCase = SearchCategoriesUseCase(fakeRepository);

      // Act
      final result = await useCase(const SearchCategoriesParams(query: 'test'));

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
    });

    test('should extend UseCase with correct types', () {
      // Arrange
      final fakeRepository = FakeCategoryReadRepository(
        categories: TestFixtures.defaultCategories,
      );
      final useCase = SearchCategoriesUseCase(fakeRepository);

      // Assert
      expect(useCase, isA<UseCase<SearchResult, SearchCategoriesParams>>());
    });
  });
}
