import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/models/category_model.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_seeding_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Implementation of CategorySeedingRepository
///
/// Responsibility: Seeding default category data
/// Following SRP - only handles seeding operations
///
/// Following DIP: Depends on LocalDataSource abstraction, not concrete DatabaseHelper.
class CategorySeedingRepositoryImpl implements CategorySeedingRepository {
  final LocalDataSource _dataSource;

  CategorySeedingRepositoryImpl(this._dataSource);

  @override
  Future<Result<bool>> needsSeed() async {
    try {
      final result = await _dataSource.query(
        DatabaseHelper.tableCategories,
        limit: 1,
      );

      final needsSeed = result.isEmpty;
      AppLogger.d('Categories need seed: $needsSeed');
      return Result.success(needsSeed);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to check if categories need seed', e, stackTrace);
      return Result.failure(DatabaseFailure(
        'Gagal mengecek ketersediaan data kategori',
        exception: e,
      ));
    }
  }

  @override
  Future<Result<void>> seedDefaultCategories() async {
    // Check if already seeded
    final needsSeedResult = await needsSeed();
    if (!needsSeedResult.isSuccess ||
        (needsSeedResult.isSuccess && needsSeedResult.data == false)) {
      AppLogger.i('Categories already seeded, skipping');
      return Result.success(null);
    }

    AppLogger.i('Seeding default categories...');

    try {
      final now = DateTime.now();
      final categories = _getDefaultCategories(now);

      // Use batchInsert for efficient bulk insert
      final categoryMaps =
          categories.map((c) => CategoryModel.fromEntity(c).toMap()).toList();
      await _dataSource.batchInsert(
        DatabaseHelper.tableCategories,
        categoryMaps,
      );

      AppLogger.i('Seeded ${categories.length} default categories');
      return Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to seed default categories', e, stackTrace);
      return Result.failure(DatabaseFailure(
        'Gagal menambahkan kategori default',
        exception: e,
      ));
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
}
