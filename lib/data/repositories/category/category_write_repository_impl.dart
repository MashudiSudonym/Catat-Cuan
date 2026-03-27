import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/models/category_model.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_write_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Implementation of CategoryWriteRepository
///
/// Responsibility: Writing category data to the database
/// Following SRP - only handles write operations (create, update, delete)
///
/// Following DIP: Depends on LocalDataSource abstraction, not concrete DatabaseHelper.
class CategoryWriteRepositoryImpl implements CategoryWriteRepository {
  final LocalDataSource _dataSource;

  CategoryWriteRepositoryImpl(this._dataSource);

  @override
  Future<Result<CategoryEntity>> addCategory(CategoryEntity category) async {
    AppLogger.d('Adding category: ${category.name} (${category.type.value})');

    try {
      final model = CategoryModel.fromEntity(category);

      final id = await _dataSource.insert(
        DatabaseHelper.tableCategories,
        model.toMap(),
      );

      final inserted = await _dataSource.query(
        DatabaseHelper.tableCategories,
        where: '${CategoryFields.id} = ?',
        whereArgs: [id],
      );

      if (inserted.isEmpty) {
        AppLogger.w('Category inserted but not found in database');
        return Result.failure(DatabaseFailure('Gagal menyimpan kategori'));
      }

      AppLogger.i('Category added successfully: ID $id');
      return Result.success(CategoryModel.fromMap(inserted.first).toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('Failed to add category', e, stackTrace);
      return Result.failure(DatabaseFailure(
        'Gagal menambahkan kategori',
        exception: e,
      ));
    }
  }

  @override
  Future<Result<CategoryEntity>> updateCategory(
      CategoryEntity category) async {
    AppLogger.d('Updating category: ID ${category.id} - ${category.name}');

    try {
      if (category.id == null) {
        AppLogger.w('Update attempted without category ID');
        return Result.failure(
          ValidationFailure('ID kategori wajib diisi untuk update'),
        );
      }

      final model = CategoryModel.fromEntity(category);

      final rowsAffected = await _dataSource.update(
        DatabaseHelper.tableCategories,
        model.toMap(),
        where: '${CategoryFields.id} = ?',
        whereArgs: [category.id!],
      );

      if (rowsAffected == 0) {
        AppLogger.w('Category not found for update: ID ${category.id}');
        return Result.failure(
          NotFoundFailure('Kategori dengan ID ${category.id} tidak ditemukan'),
        );
      }

      final updated = await _dataSource.query(
        DatabaseHelper.tableCategories,
        where: '${CategoryFields.id} = ?',
        whereArgs: [category.id!],
      );

      if (updated.isEmpty) {
        AppLogger.w('Updated category not found: ID ${category.id}');
        return Result.failure(DatabaseFailure('Gagal mengambil kategori yang diupdate'));
      }

      AppLogger.i('Category updated successfully: ID ${category.id}');
      return Result.success(CategoryModel.fromMap(updated.first).toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('Failed to update category', e, stackTrace);
      return Result.failure(DatabaseFailure(
        'Gagal mengubah kategori',
        exception: e,
      ));
    }
  }

  @override
  Future<Result<void>> deleteCategory(int id) async {
    AppLogger.d('Soft deleting category: ID $id');

    try {
      // Soft delete dengan set isActive = 0
      final rowsAffected = await _dataSource.update(
        DatabaseHelper.tableCategories,
        {
          CategoryFields.isActive: 0,
          CategoryFields.updatedAt: DateTime.now().toIso8601String()
        },
        where: '${CategoryFields.id} = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        AppLogger.w('Category not found for deletion: ID $id');
        return Result.failure(
          NotFoundFailure('Kategori dengan ID $id tidak ditemukan'),
        );
      }

      AppLogger.i('Category soft deleted successfully: ID $id');
      return Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to delete category: $id', e, stackTrace);
      return Result.failure(DatabaseFailure(
        'Gagal menghapus kategori',
        exception: e,
      ));
    }
  }
}
