import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_write_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_management_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_seeding_repository.dart';
import 'package:catat_cuan/domain/repositories/category_repository.dart';

/// Adapter that combines segregated category repositories
/// to provide the legacy CategoryRepository interface
///
/// This allows gradual migration from the monolithic CategoryRepository
/// to the segregated interfaces while maintaining backward compatibility
///
/// Following SRP: Only adapts between interfaces, no business logic
class CategoryRepositoryAdapter implements CategoryRepository {
  final CategoryReadRepository _readRepository;
  final CategoryWriteRepository _writeRepository;
  final CategoryManagementRepository _managementRepository;
  final CategorySeedingRepository _seedingRepository;

  CategoryRepositoryAdapter(
    this._readRepository,
    this._writeRepository,
    this._managementRepository,
    this._seedingRepository,
  );

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final result = await _readRepository.getCategories();
    if (result.isSuccess && result.data != null) {
      return result.data!;
    }
    throw Exception(result.failure?.message ?? 'Failed to get categories');
  }

  @override
  Future<List<CategoryEntity>> getCategoriesByType(CategoryType type) async {
    final result = await _readRepository.getCategoriesByType(type);
    if (result.isSuccess && result.data != null) {
      return result.data!;
    }
    throw Exception(result.failure?.message ?? 'Failed to get categories by type');
  }

  @override
  Future<CategoryEntity?> getCategoryById(int id) async {
    final result = await _readRepository.getCategoryById(id);
    if (result.isSuccess) {
      return result.data;
    }
    if (result.failure is NotFoundFailure) {
      return null;
    }
    throw Exception(result.failure?.message ?? 'Failed to get category');
  }

  @override
  Future<CategoryEntity> addCategory(CategoryEntity category) async {
    final result = await _writeRepository.addCategory(category);
    if (result.isSuccess && result.data != null) {
      return result.data!;
    }
    throw Exception(result.failure?.message ?? 'Failed to add category');
  }

  @override
  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    final result = await _writeRepository.updateCategory(category);
    if (result.isSuccess && result.data != null) {
      return result.data!;
    }
    throw Exception(result.failure?.message ?? 'Failed to update category');
  }

  @override
  Future<bool> deleteCategory(int id) async {
    final result = await _writeRepository.deleteCategory(id);
    return result.isSuccess;
  }

  @override
  Future<bool> needsSeed() async {
    final result = await _seedingRepository.needsSeed();
    if (result.isSuccess && result.data != null) {
      return result.data!;
    }
    throw Exception(result.failure?.message ?? 'Failed to check seed status');
  }

  @override
  Future<void> seedDefaultCategories() async {
    final result = await _seedingRepository.seedDefaultCategories();
    if (result.isFailure) {
      throw Exception(result.failure?.message ?? 'Failed to seed categories');
    }
  }

  @override
  Future<List<CategoryEntity>> getCategoriesWithCount(CategoryType type) async {
    final result = await _readRepository.getCategoriesWithCount(type);
    if (result.isSuccess && result.data != null) {
      return result.data!;
    }
    throw Exception(result.failure?.message ?? 'Failed to get categories with count');
  }

  @override
  Future<List<CategoryEntity>> getInactiveCategories() async {
    final result = await _managementRepository.getInactiveCategories();
    if (result.isSuccess && result.data != null) {
      return result.data!;
    }
    throw Exception(result.failure?.message ?? 'Failed to get inactive categories');
  }

  @override
  Future<bool> reactivateCategory(int id) async {
    final result = await _managementRepository.reactivateCategory(id);
    return result.isSuccess;
  }

  @override
  Future<void> reorderCategories(List<int> categoryIds) async {
    final result = await _managementRepository.reorderCategories(categoryIds);
    if (result.isFailure) {
      throw Exception(result.failure?.message ?? 'Failed to reorder categories');
    }
  }

  @override
  Future<CategoryEntity?> getCategoryByName(
    String name,
    CategoryType type, {
    int? excludeId,
  }) async {
    final result = await _readRepository.getCategoryByName(name, type, excludeId: excludeId);
    if (result.isSuccess) {
      return result.data;
    }
    throw Exception(result.failure?.message ?? 'Failed to get category by name');
  }

  @override
  Future<int> getTransactionCount(int categoryId) async {
    final result = await _readRepository.getTransactionCount(categoryId);
    if (result.isSuccess && result.data != null) {
      return result.data!;
    }
    throw Exception(result.failure?.message ?? 'Failed to get transaction count');
  }
}
