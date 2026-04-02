import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/usecases/category/get_categories_with_count_usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/entities/category_with_count_entity.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_management_repository.dart';
import 'package:catat_cuan/domain/usecases/category/categories_with_count_result.dart';
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
    if (errorMessage != null) {
      return Result.failure(DatabaseFailure(errorMessage!));
    }
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

class FakeCategoryManagementRepository implements CategoryManagementRepository {
  final List<CategoryEntity> inactiveCategories;
  final String? errorMessage;

  FakeCategoryManagementRepository({
    required this.inactiveCategories,
    this.errorMessage,
  });

  @override
  Future<Result<List<CategoryEntity>>> getInactiveCategories() async {
    if (errorMessage != null) {
      return Result.failure(DatabaseFailure(errorMessage!));
    }
    return Result.success(inactiveCategories);
  }

  @override
  Future<Result<void>> reactivateCategory(int id) async {
    return Result.success(null);
  }

  @override
  Future<Result<void>> reorderCategories(List<int> categoryIds) async {
    return Result.success(null);
  }
}

void main() {
  group('GetCategoriesWithCountUseCase', () {
    test('should return categories grouped by type with transaction counts', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(id: 1, type: CategoryType.expense),
        TestFixtures.categoryTransport(id: 2, type: CategoryType.expense),
        TestFixtures.categorySalary(id: 3, type: CategoryType.income),
      ];
      final transactionCounts = {1: 10, 2: 5, 3: 2};
      final fakeReadRepo = FakeCategoryReadRepository(
        categories: categories,
        transactionCounts: transactionCounts,
      );
      final fakeMgmtRepo = FakeCategoryManagementRepository(
        inactiveCategories: [],
      );
      final useCase = GetCategoriesWithCountUseCase(fakeReadRepo, fakeMgmtRepo);

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.incomeCategories.length, equals(1));
      expect(result.data?.expenseCategories.length, equals(2));
      expect(result.data?.incomeCategories.first.transactionCount, equals(2));
      expect(result.data?.expenseCategories.first.transactionCount, equals(10));
    });

    test('should include inactive categories in result', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(id: 1, type: CategoryType.expense),
      ];
      final inactiveCategories = [
        TestFixtures.categoryTransport(id: 2, type: CategoryType.expense, isActive: false),
      ];
      final transactionCounts = {1: 10, 2: 3};
      final fakeReadRepo = FakeCategoryReadRepository(
        categories: categories,
        transactionCounts: transactionCounts,
      );
      final fakeMgmtRepo = FakeCategoryManagementRepository(
        inactiveCategories: inactiveCategories,
      );
      final useCase = GetCategoriesWithCountUseCase(fakeReadRepo, fakeMgmtRepo);

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.inactiveCategories.length, equals(1));
      expect(result.data?.inactiveCategories.first.category.id, equals(2));
      expect(result.data?.inactiveCategories.first.transactionCount, equals(3));
    });

    test('should return empty lists when no categories exist', () async {
      // Arrange
      final fakeReadRepo = FakeCategoryReadRepository(
        categories: [],
        transactionCounts: {},
      );
      final fakeMgmtRepo = FakeCategoryManagementRepository(
        inactiveCategories: [],
      );
      final useCase = GetCategoriesWithCountUseCase(fakeReadRepo, fakeMgmtRepo);

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.incomeCategories, isEmpty);
      expect(result.data?.expenseCategories, isEmpty);
      expect(result.data?.inactiveCategories, isEmpty);
    });

    test('should return failure when read repository fails', () async {
      // Arrange
      final fakeReadRepo = FakeCategoryReadRepository(
        categories: [],
        transactionCounts: {},
        errorMessage: 'Database error',
      );
      final fakeMgmtRepo = FakeCategoryManagementRepository(
        inactiveCategories: [],
      );
      final useCase = GetCategoriesWithCountUseCase(fakeReadRepo, fakeMgmtRepo);

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
    });

    test('should return failure when management repository fails', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(id: 1, type: CategoryType.expense),
      ];
      final fakeReadRepo = FakeCategoryReadRepository(
        categories: categories,
        transactionCounts: {1: 10},
      );
      final fakeMgmtRepo = FakeCategoryManagementRepository(
        inactiveCategories: [],
        errorMessage: 'Database error',
      );
      final useCase = GetCategoriesWithCountUseCase(fakeReadRepo, fakeMgmtRepo);

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
    });

    test('should provide allCategories getter combining all types', () async {
      // Arrange
      final categories = [
        TestFixtures.categoryFood(id: 1, type: CategoryType.expense),
      ];
      final inactiveCategories = [
        TestFixtures.categoryTransport(id: 2, type: CategoryType.expense, isActive: false),
      ];
      final fakeReadRepo = FakeCategoryReadRepository(
        categories: categories,
        transactionCounts: {1: 10, 2: 3},
      );
      final fakeMgmtRepo = FakeCategoryManagementRepository(
        inactiveCategories: inactiveCategories,
      );
      final useCase = GetCategoriesWithCountUseCase(fakeReadRepo, fakeMgmtRepo);

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.allCategories.length, equals(2));
    });

    test('should extend UseCase with correct types', () {
      // Arrange
      final fakeReadRepo = FakeCategoryReadRepository(
        categories: [],
        transactionCounts: {},
      );
      final fakeMgmtRepo = FakeCategoryManagementRepository(
        inactiveCategories: [],
      );
      final useCase = GetCategoriesWithCountUseCase(fakeReadRepo, fakeMgmtRepo);

      // Assert
      expect(useCase, isA<UseCase<CategoriesWithCountResult, NoParams>>());
    });
  });
}
