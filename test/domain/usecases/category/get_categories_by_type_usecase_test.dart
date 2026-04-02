import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/usecases/category/get_categories_by_type_usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
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
  group('GetCategoriesByTypeUseCase', () {
    test('should return expense categories when type is expense', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(type: CategoryType.expense),
        TestFixtures.categoryTransport(type: CategoryType.expense),
        TestFixtures.categorySalary(type: CategoryType.income),
      ];
      final fakeRepository = FakeCategoryReadRepository(categories: categories);
      final useCase = GetCategoriesByTypeUseCase(fakeRepository);

      // Act
      final result = await useCase(CategoryType.expense);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.length, equals(2));
      expect(result.data?.every((cat) => cat.type == CategoryType.expense), isTrue);
    });

    test('should return income categories when type is income', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(type: CategoryType.expense),
        TestFixtures.categoryTransport(type: CategoryType.expense),
        TestFixtures.categorySalary(type: CategoryType.income),
      ];
      final fakeRepository = FakeCategoryReadRepository(categories: categories);
      final useCase = GetCategoriesByTypeUseCase(fakeRepository);

      // Act
      final result = await useCase(CategoryType.income);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.length, equals(1));
      expect(result.data?.first.type, equals(CategoryType.income));
    });

    test('should return empty list when no categories exist for type', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(type: CategoryType.expense),
        TestFixtures.categoryTransport(type: CategoryType.expense),
      ];
      final fakeRepository = FakeCategoryReadRepository(categories: categories);
      final useCase = GetCategoriesByTypeUseCase(fakeRepository);

      // Act
      final result = await useCase(CategoryType.income);

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
      final useCase = GetCategoriesByTypeUseCase(fakeRepository);

      // Act
      final result = await useCase(CategoryType.expense);

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
      final useCase = GetCategoriesByTypeUseCase(fakeRepository);

      // Assert
      expect(useCase, isA<UseCase<List<CategoryEntity>, CategoryType>>());
    });
  });
}
