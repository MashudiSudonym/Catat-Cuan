import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/usecases/category/get_inactive_categories_with_count_usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/entities/category_with_count_entity.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_management_repository.dart';
import '../../../helpers/test_fixtures.dart';

class FakeCategoryReadRepository implements CategoryReadRepository {
  final Map<int, int> transactionCounts;
  final String? errorMessage;

  FakeCategoryReadRepository({
    required this.transactionCounts,
    this.errorMessage,
  });

  @override
  Future<Result<List<CategoryEntity>>> getCategories() async {
    return Result.success([]);
  }

  @override
  Future<Result<CategoryEntity>> getCategoryById(int id) async {
    return Result.success(TestFixtures.categoryFood(id: id));
  }

  @override
  Future<Result<List<CategoryEntity>>> getCategoriesByType(CategoryType type) async {
    return Result.success([]);
  }

  @override
  Future<Result<List<CategoryEntity>>> getCategoriesWithCount(CategoryType type) async {
    return Result.success([]);
  }

  @override
  Future<Result<CategoryEntity?>> getCategoryByName(
    String name,
    CategoryType type, {
    int? excludeId,
  }) async {
    return Result.success(null);
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
  group('GetInactiveCategoriesWithCountUseCase', () {
    test('should return inactive categories with transaction counts', () async {
      // Arrange
      final inactiveCategories = [
        TestFixtures.categoryFood(id: 1, isActive: false),
        TestFixtures.categoryTransport(id: 2, isActive: false),
      ];
      final transactionCounts = {1: 5, 2: 3};
      final fakeReadRepo = FakeCategoryReadRepository(
        transactionCounts: transactionCounts,
      );
      final fakeMgmtRepo = FakeCategoryManagementRepository(
        inactiveCategories: inactiveCategories,
      );
      final useCase = GetInactiveCategoriesWithCountUseCase(fakeReadRepo, fakeMgmtRepo);

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.length, equals(2));
      expect(result.data?.first.transactionCount, equals(5));
      expect(result.data?.last.transactionCount, equals(3));
    });

    test('should return empty list when no inactive categories exist', () async {
      // Arrange
      final fakeReadRepo = FakeCategoryReadRepository(
        transactionCounts: {},
      );
      final fakeMgmtRepo = FakeCategoryManagementRepository(
        inactiveCategories: [],
      );
      final useCase = GetInactiveCategoriesWithCountUseCase(fakeReadRepo, fakeMgmtRepo);

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
    });

    test('should handle categories with zero transaction count', () async {
      // Arrange
      final inactiveCategories = [
        TestFixtures.categoryFood(id: 1, isActive: false),
      ];
      final fakeReadRepo = FakeCategoryReadRepository(
        transactionCounts: {}, // Empty map means no transactions
      );
      final fakeMgmtRepo = FakeCategoryManagementRepository(
        inactiveCategories: inactiveCategories,
      );
      final useCase = GetInactiveCategoriesWithCountUseCase(fakeReadRepo, fakeMgmtRepo);

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.length, equals(1));
      expect(result.data?.first.transactionCount, equals(0));
    });

    test('should return failure when management repository fails', () async {
      // Arrange
      final fakeReadRepo = FakeCategoryReadRepository(
        transactionCounts: {},
      );
      final fakeMgmtRepo = FakeCategoryManagementRepository(
        inactiveCategories: [],
        errorMessage: 'Database error',
      );
      final useCase = GetInactiveCategoriesWithCountUseCase(fakeReadRepo, fakeMgmtRepo);

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<DatabaseFailure>());
    });

    test('should handle getTransactionCount failure gracefully', () async {
      // Arrange
      final inactiveCategories = [
        TestFixtures.categoryFood(id: 1, isActive: false),
      ];
      final fakeReadRepo = FakeCategoryReadRepository(
        transactionCounts: {1: 5},
        errorMessage: 'Database error', // This will make getTransactionCount fail
      );
      final fakeMgmtRepo = FakeCategoryManagementRepository(
        inactiveCategories: inactiveCategories,
      );
      final useCase = GetInactiveCategoriesWithCountUseCase(fakeReadRepo, fakeMgmtRepo);

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.length, equals(1));
      expect(result.data?.first.transactionCount, equals(0)); // Should default to 0 on failure
    });

    test('should extend UseCase with correct types', () {
      // Arrange
      final fakeReadRepo = FakeCategoryReadRepository(
        transactionCounts: {},
      );
      final fakeMgmtRepo = FakeCategoryManagementRepository(
        inactiveCategories: [],
      );
      final useCase = GetInactiveCategoriesWithCountUseCase(fakeReadRepo, fakeMgmtRepo);

      // Assert
      expect(useCase, isA<UseCase<List<CategoryWithCountEntity>, NoParams>>());
    });
  });
}
