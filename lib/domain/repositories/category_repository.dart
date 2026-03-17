import 'package:catat_cuan/domain/entities/category_entity.dart';

/// Repository interface untuk operasi kategori
abstract class CategoryRepository {
  /// Mengambil semua kategori aktif
  Future<List<CategoryEntity>> getCategories();

  /// Mengambil kategori berdasarkan tipe (income/expense)
  /// Hanya mengembalikan kategori yang isActive = true
  Future<List<CategoryEntity>> getCategoriesByType(CategoryType type);

  /// Mengambil kategori berdasarkan ID
  Future<CategoryEntity?> getCategoryById(int id);

  /// Menambahkan kategori baru
  Future<CategoryEntity> addCategory(CategoryEntity category);

  /// Mengupdate kategori yang sudah ada
  Future<CategoryEntity> updateCategory(CategoryEntity category);

  /// Menghapus kategori (soft delete dengan set isActive = false)
  Future<bool> deleteCategory(int id);

  /// Mengecek apakah perlu seed default categories
  Future<bool> needsSeed();

  /// Seed default categories ke database
  Future<void> seedDefaultCategories();

  /// Mengambil kategori dengan jumlah transaksi (untuk tampilan list)
  /// Returns categories with transaction count using LEFT JOIN
  Future<List<CategoryEntity>> getCategoriesWithCount(CategoryType type);

  /// Mengambil kategori yang tidak aktif (untuk tab "Tidak Aktif")
  Future<List<CategoryEntity>> getInactiveCategories();

  /// Mengaktifkan kembali kategori yang sudah dinonaktifkan
  Future<bool> reactivateCategory(int id);

  /// Mengubah urutan kategori (batch update sort_order)
  Future<void> reorderCategories(List<int> categoryIds);

  /// Mengecek apakah nama kategori sudah ada (untuk validasi)
  /// excludeId digunakan saat update (exclude current category from check)
  Future<CategoryEntity?> getCategoryByName(String name, CategoryType type, {int? excludeId});

  /// Mengambil jumlah transaksi untuk sebuah kategori
  Future<int> getTransactionCount(int categoryId);
}
