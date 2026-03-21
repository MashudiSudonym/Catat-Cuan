import 'package:sqflite/sqflite.dart';
import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/models/category_model.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/repositories/category_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Implementasi CategoryRepository dengan SQLite
class CategoryRepositoryImpl implements CategoryRepository {
  final DatabaseHelper _dbHelper;

  CategoryRepositoryImpl(this._dbHelper);

  @override
  Future<List<CategoryEntity>> getCategories() async {
    AppLogger.d('Fetching all active categories');

    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableCategories,
        where: '${CategoryFields.isActive} = ?',
        whereArgs: [1],
        orderBy: '${CategoryFields.sortOrder} ASC',
      );

      final categories = maps.map((map) => CategoryModel.fromMap(map).toEntity()).toList();
      AppLogger.i('Retrieved ${categories.length} active categories');
      return categories;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get categories', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<CategoryEntity>> getCategoriesByType(CategoryType type) async {
    AppLogger.d('Fetching categories by type: ${type.value}');

    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableCategories,
        where: '${CategoryFields.type} = ? AND ${CategoryFields.isActive} = ?',
        whereArgs: [type.value, 1],
        orderBy: '${CategoryFields.sortOrder} ASC',
      );

      final categories = maps.map((map) => CategoryModel.fromMap(map).toEntity()).toList();
      AppLogger.i('Retrieved ${categories.length} ${type.value} categories');
      return categories;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get categories by type', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<CategoryEntity?> getCategoryById(int id) async {
    AppLogger.d('Fetching category by ID: $id');

    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableCategories,
        where: '${CategoryFields.id} = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        AppLogger.w('Category not found: ID $id');
        return null;
      }

      return CategoryModel.fromMap(maps.first).toEntity();
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get category by ID: $id', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<CategoryEntity> addCategory(CategoryEntity category) async {
    AppLogger.d('Adding category: ${category.name} (${category.type.value})');

    try {
      final db = await _dbHelper.database;

      final model = CategoryModel.fromEntity(category);

      final id = await db.insert(
        DatabaseHelper.tableCategories,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      final inserted = await db.query(
        DatabaseHelper.tableCategories,
        where: '${CategoryFields.id} = ?',
        whereArgs: [id],
      );

      AppLogger.i('Category added successfully: ID $id');
      return CategoryModel.fromMap(inserted.first).toEntity();
    } catch (e, stackTrace) {
      AppLogger.e('Failed to add category', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    AppLogger.d('Updating category: ID ${category.id} - ${category.name}');

    try {
      final db = await _dbHelper.database;

      if (category.id == null) {
        AppLogger.w('Update attempted without category ID');
        throw Exception('ID kategori wajib diisi untuk update');
      }

      final model = CategoryModel.fromEntity(category);

      await db.update(
        DatabaseHelper.tableCategories,
        model.toMap(),
        where: '${CategoryFields.id} = ?',
        whereArgs: [category.id],
      );

      final updated = await db.query(
        DatabaseHelper.tableCategories,
        where: '${CategoryFields.id} = ?',
        whereArgs: [category.id],
      );

      AppLogger.i('Category updated successfully: ID ${category.id}');
      return CategoryModel.fromMap(updated.first).toEntity();
    } catch (e, stackTrace) {
      AppLogger.e('Failed to update category', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> deleteCategory(int id) async {
    AppLogger.d('Soft deleting category: ID $id');

    try {
      final db = await _dbHelper.database;

      // Soft delete dengan set isActive = 0
      final rowsAffected = await db.update(
        DatabaseHelper.tableCategories,
        {CategoryFields.isActive: 0, CategoryFields.updatedAt: DateTime.now().toIso8601String()},
        where: '${CategoryFields.id} = ?',
        whereArgs: [id],
      );

      final success = rowsAffected > 0;
      if (success) {
        AppLogger.i('Category soft deleted successfully: ID $id');
      } else {
        AppLogger.w('Category not found for deletion: ID $id');
      }
      return success;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to delete category: $id', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> needsSeed() async {
    try {
      final db = await _dbHelper.database;

      final result = await db.query(
        DatabaseHelper.tableCategories,
        limit: 1,
      );

      final needsSeed = result.isEmpty;
      AppLogger.d('Categories need seed: $needsSeed');
      return needsSeed;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to check if categories need seed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> seedDefaultCategories() async {
    if (!await needsSeed()) {
      AppLogger.i('Categories already seeded, skipping');
      return;
    }

    AppLogger.i('Seeding default categories...');

    try {
      final now = DateTime.now();
      final categories = _getDefaultCategories(now);

      final db = await _dbHelper.database;
      final batch = db.batch();

      for (final category in categories) {
        final model = CategoryModel.fromEntity(category);
        batch.insert(
          DatabaseHelper.tableCategories,
          model.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }

      await batch.commit(noResult: true);
      AppLogger.i('Seeded ${categories.length} default categories');
    } catch (e, stackTrace) {
      AppLogger.e('Failed to seed default categories', e, stackTrace);
      rethrow;
    }
  }

  /// Mendapatkan default categories sesuai SPEC
  List<CategoryEntity> _getDefaultCategories(DateTime now) {
    return [
      // Kategori Pemasukan
      CategoryEntity(
        name: 'Gaji',
        type: CategoryType.income,
        color: '#4CAF50',
        icon: '💰',
        sortOrder: 1,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryEntity(
        name: 'Bonus',
        type: CategoryType.income,
        color: '#8BC34A',
        icon: '🎁',
        sortOrder: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryEntity(
        name: 'Freelance',
        type: CategoryType.income,
        color: '#CDDC39',
        icon: '💼',
        sortOrder: 3,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryEntity(
        name: 'Hadiah',
        type: CategoryType.income,
        color: '#FFEB3B',
        icon: '🎀',
        sortOrder: 4,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryEntity(
        name: 'Investasi',
        type: CategoryType.income,
        color: '#FFC107',
        icon: '📈',
        sortOrder: 5,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryEntity(
        name: 'Lainnya',
        type: CategoryType.income,
        color: '#9E9E9E',
        icon: '📦',
        sortOrder: 6,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      // Kategori Pengeluaran
      CategoryEntity(
        name: 'Makan',
        type: CategoryType.expense,
        color: '#F44336',
        icon: '🍔',
        sortOrder: 1,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryEntity(
        name: 'Transport',
        type: CategoryType.expense,
        color: '#E91E63',
        icon: '🚗',
        sortOrder: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryEntity(
        name: 'Langganan',
        type: CategoryType.expense,
        color: '#9C27B0',
        icon: '🔄',
        sortOrder: 3,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryEntity(
        name: 'Belanja',
        type: CategoryType.expense,
        color: '#673AB7',
        icon: '🛍️',
        sortOrder: 4,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryEntity(
        name: 'Hiburan',
        type: CategoryType.expense,
        color: '#3F51B5',
        icon: '🎬',
        sortOrder: 5,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryEntity(
        name: 'Kesehatan',
        type: CategoryType.expense,
        color: '#2196F3',
        icon: '💊',
        sortOrder: 6,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryEntity(
        name: 'Pendidikan',
        type: CategoryType.expense,
        color: '#03A9F4',
        icon: '📚',
        sortOrder: 7,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryEntity(
        name: 'Tagihan',
        type: CategoryType.expense,
        color: '#00BCD4',
        icon: '📄',
        sortOrder: 8,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryEntity(
        name: 'Lainnya',
        type: CategoryType.expense,
        color: '#9E9E9E',
        icon: '📦',
        sortOrder: 9,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  @override
  Future<List<CategoryEntity>> getCategoriesWithCount(CategoryType type) async {
    AppLogger.d('Fetching categories with transaction count: ${type.value}');

    try {
      final db = await _dbHelper.database;

      // Use LEFT JOIN to get transaction count
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
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

      AppLogger.i('Retrieved ${categories.length} categories with transaction counts');
      return categories;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get categories with count', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<CategoryEntity>> getInactiveCategories() async {
    AppLogger.d('Fetching inactive categories');

    try {
      final db = await _dbHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableCategories,
        where: '${CategoryFields.isActive} = ?',
        whereArgs: [0],
        orderBy: '${CategoryFields.sortOrder} ASC',
      );

      final categories = maps.map((map) => CategoryModel.fromMap(map).toEntity()).toList();
      AppLogger.i('Retrieved ${categories.length} inactive categories');
      return categories;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get inactive categories', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> reactivateCategory(int id) async {
    AppLogger.d('Reactivating category: ID $id');

    try {
      final db = await _dbHelper.database;

      final rowsAffected = await db.update(
        DatabaseHelper.tableCategories,
        {
          CategoryFields.isActive: 1,
          CategoryFields.updatedAt: DateTime.now().toIso8601String(),
        },
        where: '${CategoryFields.id} = ?',
        whereArgs: [id],
      );

      final success = rowsAffected > 0;
      if (success) {
        AppLogger.i('Category reactivated successfully: ID $id');
      } else {
        AppLogger.w('Category not found for reactivation: ID $id');
      }
      return success;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to reactivate category: $id', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> reorderCategories(List<int> categoryIds) async {
    AppLogger.d('Reordering ${categoryIds.length} categories');

    if (categoryIds.isEmpty) {
      AppLogger.w('No categories to reorder');
      return;
    }

    try {
      final db = await _dbHelper.database;
      final batch = db.batch();

      // Batch update sort_order for all categories
      for (int i = 0; i < categoryIds.length; i++) {
        batch.update(
          DatabaseHelper.tableCategories,
          {
            CategoryFields.sortOrder: i + 1,
            CategoryFields.updatedAt: DateTime.now().toIso8601String(),
          },
          where: '${CategoryFields.id} = ?',
          whereArgs: [categoryIds[i]],
        );
      }

      await batch.commit(noResult: true);
      AppLogger.i('Categories reordered successfully');
    } catch (e, stackTrace) {
      AppLogger.e('Failed to reorder categories', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<CategoryEntity?> getCategoryByName(
    String name,
    CategoryType type, {
    int? excludeId,
  }) async {
    AppLogger.d('Fetching category by name: "$name" (${type.value})');

    try {
      final db = await _dbHelper.database;

      String whereClause =
          '${CategoryFields.name} = ? AND ${CategoryFields.type} = ?';
      List<dynamic> whereArgs = [name, type.value];

      // Add excludeId condition if provided (for update scenario)
      if (excludeId != null) {
        whereClause += ' AND ${CategoryFields.id} != ?';
        whereArgs = [...whereArgs, excludeId];
      }

      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tableCategories,
        where: whereClause,
        whereArgs: whereArgs,
        limit: 1,
      );

      if (maps.isEmpty) {
        AppLogger.i('Category not found by name: "$name"');
        return null;
      }

      return CategoryModel.fromMap(maps.first).toEntity();
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get category by name', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<int> getTransactionCount(int categoryId) async {
    AppLogger.d('Fetching transaction count for category: $categoryId');

    try {
      final db = await _dbHelper.database;

      final result = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM ${DatabaseHelper.tableTransactions}
        WHERE ${TransactionFields.categoryId} = ?
      ''', [categoryId]);

      final count = result.first['count'] as int? ?? 0;
      AppLogger.d('Transaction count for category $categoryId: $count');
      return count;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get transaction count', e, stackTrace);
      rethrow;
    }
  }
}
