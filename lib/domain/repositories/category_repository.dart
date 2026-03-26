import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/repositories/category/category_repositories.dart';

/// Legacy monolithic CategoryRepository interface
///
/// This interface combines all category operations in one place.
/// It violates the Interface Segregation Principle (ISP) because clients
/// are forced to depend on methods they don't use.
///
/// MIGRATION GUIDE:
/// Instead of using this monolithic interface, depend on the specific
/// segregated interfaces you actually need:
///
/// - For reading categories: `CategoryReadRepository`
/// - For writing categories: `CategoryWriteRepository`
/// - For reordering/activation: `CategoryManagementRepository`
/// - For seeding: `CategorySeedingRepository`
///
/// Example migration:
/// ```dart
/// // OLD - depends on everything
/// class MyService {
///   final CategoryRepository _repo;
/// }
///
/// // NEW - depends only on what's needed
/// class MyService {
///   final CategoryReadRepository _readRepo;
///   final CategoryWriteRepository _writeRepo;
/// }
/// ```
@Deprecated('Use segregated interfaces from category/category_repositories.dart instead')
abstract class CategoryRepository {
  /// @deprecated Use CategoryReadRepository.getCategories() instead
  @deprecated
  Future<List<CategoryEntity>> getCategories();

  /// @deprecated Use CategoryReadRepository.getCategoriesByType() instead
  @deprecated
  Future<List<CategoryEntity>> getCategoriesByType(CategoryType type);

  /// @deprecated Use CategoryReadRepository.getCategoryById() instead
  @deprecated
  Future<CategoryEntity?> getCategoryById(int id);

  /// @deprecated Use CategoryWriteRepository.addCategory() instead
  @deprecated
  Future<CategoryEntity> addCategory(CategoryEntity category);

  /// @deprecated Use CategoryWriteRepository.updateCategory() instead
  @deprecated
  Future<CategoryEntity> updateCategory(CategoryEntity category);

  /// @deprecated Use CategoryWriteRepository.deleteCategory() instead
  @deprecated
  Future<bool> deleteCategory(int id);

  /// @deprecated Use CategorySeedingRepository.needsSeed() instead
  @deprecated
  Future<bool> needsSeed();

  /// @deprecated Use CategorySeedingRepository.seedDefaultCategories() instead
  @deprecated
  Future<void> seedDefaultCategories();

  /// @deprecated Use CategoryReadRepository.getCategoriesWithCount() instead
  @deprecated
  Future<List<CategoryEntity>> getCategoriesWithCount(CategoryType type);

  /// @deprecated Use CategoryManagementRepository.getInactiveCategories() instead
  @deprecated
  Future<List<CategoryEntity>> getInactiveCategories();

  /// @deprecated Use CategoryManagementRepository.reactivateCategory() instead
  @deprecated
  Future<bool> reactivateCategory(int id);

  /// @deprecated Use CategoryManagementRepository.reorderCategories() instead
  @deprecated
  Future<void> reorderCategories(List<int> categoryIds);

  /// @deprecated Use CategoryReadRepository.getCategoryByName() instead
  @deprecated
  Future<CategoryEntity?> getCategoryByName(String name, CategoryType type, {int? excludeId});

  /// @deprecated Use CategoryReadRepository.getTransactionCount() instead
  @deprecated
  Future<int> getTransactionCount(int categoryId);
}
