import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/usecases/category/get_categories_by_type_with_count_usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/entities/category_with_count_entity.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import '../../../helpers/test_fixtures.dart';

class FakeCategoryReadRepository implements CategoryReadRepository {
  final List<CategoryEntity> categories;
  final Map<int, int> transactionCounts;
  final String? errorMessage;

  FakeCategoryReadRepository({
    required this.categories,
    required this.transactionCounts,
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
    if (errorMessage != null) {
      return Result.failure(DatabaseFailure(errorMessage!));
    }
    final filtered = categories.where((cat) => cat.type == type).toList();
    return Result.success(filtered);
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
    if (errorMessage != null) {
      return Result.failure(DatabaseFailure(errorMessage!));
    }
    return Result.success(transactionCounts[categoryId] ?? 0);
  }
}

void main() {
  group('GetCategoriesByTypeWithCountUseCase', () {
    test('should return expense categories with transaction counts', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(id: 1, type: CategoryType.expense),
        TestFixtures.categoryTransport(id: 2, type: CategoryType.expense),
        TestFixtures.categorySalary(id: 3, type: CategoryType.income),
      ];
      final transactionCounts = {1: 10, 2: 5, 3: 2};
      final fakeRepository = FakeCategoryReadRepository(
        categories: categories,
        transactionCounts: transactionCounts,
      );
      final useCase = GetCategoriesByTypeWithCountUseCase(fakeRepository);

      // Act
      final result = await useCase(CategoryType.expense);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.length, equals(2));
      expect(result.data?.first.transactionCount, equals(10));
      expect(result.data?.last.transactionCount, equals(5));
    });

    test('should return income categories with transaction counts', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(id: 1, type: CategoryType.expense),
        TestFixtures.categorySalary(id: 3, type: CategoryType.income),
      ];
      final transactionCounts = {1: 10, 3: 2};
      final fakeRepository = FakeCategoryReadRepository(
        categories: categories,
        transactionCounts: transactionCounts,
      );
      final useCase = GetCategoriesByTypeWithCountUseCase(fakeRepository);

      // Act
      final result = await useCase(CategoryType.income);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.length, equals(1));
      expect(result.data?.first.category.id, equals(3));
      expect(result.data?.first.transactionCount, equals(2));
    });

    test('should return empty list when no categories exist for type', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(id: 1, type: CategoryType.expense),
      ];
      final fakeRepository = FakeCategoryReadRepository(
        categories: categories,
        transactionCounts: {1: 10},
      );
      final useCase = GetCategoriesByTypeWithCountUseCase(fakeRepository);

      // Act
      final result = await useCase(CategoryType.income);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
    });

    test('should handle categories with zero transaction count', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(id: 1, type: CategoryType.expense),
      ];
      final fakeRepository = FakeCategoryReadRepository(
        categories: categories,
        transactionCounts: {}, // Empty map means no transactions
      );
      final useCase = GetCategoriesByTypeWithCountUseCase(fakeRepository);

      // Act
      final result = await useCase(CategoryType.expense);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.length, equals(1));
      expect(result.data?.first.transactionCount, equals(0));
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final fakeRepository = FakeCategoryReadRepository(
        categories: [],
        transactionCounts: {},
        errorMessage: 'Database error',
      );
      final useCase = GetCategoriesByTypeWithCountUseCase(fakeRepository);

      // Act
      final result = await useCase(CategoryType.expense);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
    });

    test('should return failure when getCategoriesWithCount fails', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(id: 1, type: CategoryType.expense),
      ];
      final fakeRepository = FakeCategoryReadRepository(
        categories: categories,
        transactionCounts: {1: 10},
        errorMessage: 'Database error', // This will make getCategoriesWithCount fail
      );
      final useCase = GetCategoriesByTypeWithCountUseCase(fakeRepository);

      // Act
      final result = await useCase(CategoryType.expense);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
    });

    test('should extend UseCase with correct types', () {
      // Arrange
      final fakeRepository = FakeCategoryReadRepository(
        categories: [],
        transactionCounts: {},
      );
      final useCase = GetCategoriesByTypeWithCountUseCase(fakeRepository);

      // Assert
      expect(useCase, isA<UseCase<List<CategoryWithCountEntity>, CategoryType>>());
    });
  });
}
