import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/models/category_model.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Implementation of CategoryReadRepository
///
/// Responsibility: Reading category data from the database
/// Following SRP - only handles read operations
///
/// Following DIP: Depends on LocalDataSource abstraction, not concrete DatabaseHelper.
class CategoryReadRepositoryImpl implements CategoryReadRepository {
  final LocalDataSource _dataSource;

  CategoryReadRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<CategoryEntity>>> getCategories() async {
    AppLogger.d('Fetching all active categories');

    try {
      final List<Map<String, dynamic>> maps = await _dataSource.query(
        DatabaseHelper.tableCategories,
        where: '${CategoryFields.isActive} = ?',
        whereArgs: [1],
        orderBy: '${CategoryFields.sortOrder} ASC',
      );

      final categories =
          maps.map((map) => CategoryModel.fromMap(map).toEntity()).toList();
      AppLogger.i('Retrieved ${categories.length} active categories');
      return Result.success(categories);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get categories', e, stackTrace);
      return Result.failure(DatabaseFailure(
        'Gagal mengambil kategori',
        exception: e,
      ));
    }
  }

  @override
  Future<Result<List<CategoryEntity>>> getCategoriesByType(
      CategoryType type) async {
    AppLogger.d('Fetching categories by type: ${type.value}');

    try {
      final List<Map<String, dynamic>> maps = await _dataSource.query(
        DatabaseHelper.tableCategories,
        where:
            '${CategoryFields.type} = ? AND ${CategoryFields.isActive} = ?',
        whereArgs: [type.value, 1],
        orderBy: '${CategoryFields.sortOrder} ASC',
      );

      final categories =
          maps.map((map) => CategoryModel.fromMap(map).toEntity()).toList();
      AppLogger.i('Retrieved ${categories.length} ${type.value} categories');
      return Result.success(categories);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get categories by type', e, stackTrace);
      return Result.failure(DatabaseFailure(
        'Gagal mengambil kategori berdasarkan tipe',
        exception: e,
      ));
    }
  }

  @override
  Future<Result<CategoryEntity>> getCategoryById(int id) async {
    AppLogger.d('Fetching category by ID: $id');

    try {
      final List<Map<String, dynamic>> maps = await _dataSource.query(
        DatabaseHelper.tableCategories,
        where: '${CategoryFields.id} = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        AppLogger.w('Category not found: ID $id');
        return Result.failure(NotFoundFailure(
          'Kategori dengan ID $id tidak ditemukan',
        ));
      }

      return Result.success(CategoryModel.fromMap(maps.first).toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get category by ID: $id', e, stackTrace);
      return Result.failure(DatabaseFailure(
        'Gagal mengambil kategori',
        exception: e,
      ));
    }
  }

  @override
  Future<Result<List<CategoryEntity>>> getCategoriesWithCount(
      CategoryType type) async {
    AppLogger.d('Fetching categories with transaction count: ${type.value}');

    try {
      // Use LEFT JOIN to get transaction count
      final List<Map<String, dynamic>> maps = await _dataSource.rawQuery('''
        SELECT c.*,
               COUNT(t.id) as transaction_count
        FROM ${DatabaseHelper.tableCategories} c
        LEFT JOIN ${DatabaseHelper.tableTransactions} t
          ON c.${CategoryFields.id} = t.${TransactionFields.categoryId}
        WHERE c.${CategoryFields.type} = ?
          AND c.${CategoryFields.isActive} = ?
        GROUP BY c.${CategoryFields.id}
        ORDER BY c.${CategoryFields.sortOrder} ASC
      ''', [type.value, 1]);

      final categories = maps.map((map) {
        // Remove transaction_count from map before converting to CategoryModel
        final categoryMap = Map<String, dynamic>.from(map);
        categoryMap.remove('transaction_count');
        return CategoryModel.fromMap(categoryMap).toEntity();
      }).toList();

      AppLogger
          .i('Retrieved ${categories.length} categories with transaction counts');
      return Result.success(categories);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get categories with count', e, stackTrace);
      return Result.failure(DatabaseFailure(
        'Gagal mengambil kategori dengan jumlah transaksi',
        exception: e,
      ));
    }
  }

  @override
  Future<Result<CategoryEntity?>> getCategoryByName(
    String name,
    CategoryType type, {
    int? excludeId,
  }) async {
    AppLogger.d('Fetching category by name: "$name" (${type.value})');

    try {
      String whereClause =
          '${CategoryFields.name} = ? AND ${CategoryFields.type} = ?';
      List<Object> whereArgs = [name, type.value];

      // Add excludeId condition if provided (for update scenario)
      if (excludeId != null) {
        whereClause += ' AND ${CategoryFields.id} != ?';
        whereArgs = [...whereArgs, excludeId];
      }

      final List<Map<String, dynamic>> maps = await _dataSource.query(
        DatabaseHelper.tableCategories,
        where: whereClause,
        whereArgs: whereArgs,
        limit: 1,
      );

      if (maps.isEmpty) {
        AppLogger.i('Category not found by name: "$name"');
        return Result.success(null);
      }

      return Result.success(CategoryModel.fromMap(maps.first).toEntity());
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get category by name', e, stackTrace);
      return Result.failure(DatabaseFailure(
        'Gagal mengambil kategori berdasarkan nama',
        exception: e,
      ));
    }
  }

  @override
  Future<Result<int>> getTransactionCount(int categoryId) async {
    AppLogger.d('Fetching transaction count for category: $categoryId');

    try {
      final result = await _dataSource.rawQuery('''
        SELECT COUNT(*) as count
        FROM ${DatabaseHelper.tableTransactions}
        WHERE ${TransactionFields.categoryId} = ?
      ''', [categoryId]);

      final count = result.first['count'] as int? ?? 0;
      AppLogger.d('Transaction count for category $categoryId: $count');
      return Result.success(count);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get transaction count', e, stackTrace);
      return Result.failure(DatabaseFailure(
        'Gagal mengambil jumlah transaksi',
        exception: e,
      ));
    }
  }
}
