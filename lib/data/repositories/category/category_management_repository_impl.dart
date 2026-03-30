import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/models/category_model.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_management_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Implementation of CategoryManagementRepository
///
/// Responsibility: Managing category status and ordering
/// Following SRP - only handles management operations (reactivate, reorder)
///
/// Following DIP: Depends on LocalDataSource abstraction, not concrete DatabaseHelper.
class CategoryManagementRepositoryImpl
    implements CategoryManagementRepository {
  final LocalDataSource _dataSource;

  CategoryManagementRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<CategoryEntity>>> getInactiveCategories() async {
    AppLogger.d('Fetching inactive categories');

    try {
      final List<Map<String, dynamic>> maps = await _dataSource.query(
        DatabaseHelper.tableCategories,
        where: '${CategoryFields.isActive} = ?',
        whereArgs: [0],
        orderBy: '${CategoryFields.sortOrder} ASC',
      );

      final categories =
          maps.map((map) => CategoryModel.fromMap(map).toEntity()).toList();
      AppLogger.i('Retrieved ${categories.length} inactive categories');
      return Result.success(categories);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get inactive categories', e, stackTrace);
      return Result.failure(DatabaseFailure(
        'Gagal mengambil kategori tidak aktif',
        exception: e,
      ));
    }
  }

  @override
  Future<Result<void>> reactivateCategory(int id) async {
    AppLogger.d('Reactivating category: ID $id');

    try {
      final rowsAffected = await _dataSource.update(
        DatabaseHelper.tableCategories,
        {
          CategoryFields.isActive: 1,
          CategoryFields.updatedAt: DateTime.now().toIso8601String(),
        },
        where: '${CategoryFields.id} = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        AppLogger.w('Category not found for reactivation: ID $id');
        return Result.failure(
          NotFoundFailure('Kategori dengan ID $id tidak ditemukan'),
        );
      }

      AppLogger.i('Category reactivated successfully: ID $id');
      return Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to reactivate category: $id', e, stackTrace);
      return Result.failure(DatabaseFailure(
        'Gagal mengaktifkan kembali kategori',
        exception: e,
      ));
    }
  }

  @override
  Future<Result<void>> reorderCategories(List<int> categoryIds) async {
    AppLogger.d('Reordering ${categoryIds.length} categories');

    if (categoryIds.isEmpty) {
      AppLogger.w('No categories to reorder');
      return Result.failure(
        ValidationFailure('Daftar kategori tidak boleh kosong'),
      );
    }

    try {
      // Use batchUpdate for efficient bulk update
      final updates = <(Map<String, dynamic>, String?, List<Object>?)>[];
      for (int i = 0; i < categoryIds.length; i++) {
        updates.add((
          {
            CategoryFields.sortOrder: i + 1,
            CategoryFields.updatedAt: DateTime.now().toIso8601String(),
          },
          '${CategoryFields.id} = ?',
          [categoryIds[i]],
        ));
      }
      await _dataSource.batchUpdate(
        DatabaseHelper.tableCategories,
        updates,
      );

      AppLogger.i('Categories reordered successfully');
      return Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to reorder categories', e, stackTrace);
      return Result.failure(DatabaseFailure(
        'Gagal mengubah urutan kategori',
        exception: e,
      ));
    }
  }
}
