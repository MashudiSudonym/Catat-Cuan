import 'package:sqflite/sqflite.dart';
import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/models/category_model.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/repositories/category_repository.dart';

/// Implementasi CategoryRepository dengan SQLite
class CategoryRepositoryImpl implements CategoryRepository {
  final DatabaseHelper _dbHelper;

  CategoryRepositoryImpl(this._dbHelper);

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableCategories,
      where: '${CategoryFields.isActive} = ?',
      whereArgs: [1],
      orderBy: '${CategoryFields.sortOrder} ASC',
    );

    return maps.map((map) => CategoryModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<List<CategoryEntity>> getCategoriesByType(CategoryType type) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableCategories,
      where: '${CategoryFields.type} = ? AND ${CategoryFields.isActive} = ?',
      whereArgs: [type.value, 1],
      orderBy: '${CategoryFields.sortOrder} ASC',
    );

    return maps.map((map) => CategoryModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<CategoryEntity?> getCategoryById(int id) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableCategories,
      where: '${CategoryFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    return CategoryModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<CategoryEntity> addCategory(CategoryEntity category) async {
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

    return CategoryModel.fromMap(inserted.first).toEntity();
  }

  @override
  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    final db = await _dbHelper.database;

    if (category.id == null) {
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

    return CategoryModel.fromMap(updated.first).toEntity();
  }

  @override
  Future<bool> deleteCategory(int id) async {
    final db = await _dbHelper.database;

    // Soft delete dengan set isActive = 0
    final rowsAffected = await db.update(
      DatabaseHelper.tableCategories,
      {CategoryFields.isActive: 0, CategoryFields.updatedAt: DateTime.now().toIso8601String()},
      where: '${CategoryFields.id} = ?',
      whereArgs: [id],
    );

    return rowsAffected > 0;
  }

  @override
  Future<bool> needsSeed() async {
    final db = await _dbHelper.database;

    final result = await db.query(
      DatabaseHelper.tableCategories,
      limit: 1,
    );

    return result.isEmpty;
  }

  @override
  Future<void> seedDefaultCategories() async {
    if (!await needsSeed()) return;

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

    return maps.map((map) {
      // Remove transaction_count from map before converting to CategoryModel
      final categoryMap = Map<String, dynamic>.from(map);
      categoryMap.remove('transaction_count');
      return CategoryModel.fromMap(categoryMap).toEntity();
    }).toList();
  }

  @override
  Future<List<CategoryEntity>> getInactiveCategories() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableCategories,
      where: '${CategoryFields.isActive} = ?',
      whereArgs: [0],
      orderBy: '${CategoryFields.sortOrder} ASC',
    );

    return maps.map((map) => CategoryModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<bool> reactivateCategory(int id) async {
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

    return rowsAffected > 0;
  }

  @override
  Future<void> reorderCategories(List<int> categoryIds) async {
    if (categoryIds.isEmpty) return;

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
  }

  @override
  Future<CategoryEntity?> getCategoryByName(
    String name,
    CategoryType type, {
    int? excludeId,
  }) async {
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

    if (maps.isEmpty) return null;

    return CategoryModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<int> getTransactionCount(int categoryId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM ${DatabaseHelper.tableTransactions}
      WHERE ${TransactionFields.categoryId} = ?
    ''', [categoryId]);

    return result.first['count'] as int? ?? 0;
  }
}
