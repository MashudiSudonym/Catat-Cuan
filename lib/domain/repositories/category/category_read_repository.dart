import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';

/// Repository interface untuk membaca kategori
///
/// Following Interface Segregation Principle (ISP) - hanya berisi operasi baca
///
/// Responsibility: Mengambil data kategori dari database
abstract class CategoryReadRepository {
  /// Mengambil semua kategori aktif
  ///
  /// Mengembalikan Result dengan list kategori aktif
  Future<Result<List<CategoryEntity>>> getCategories();

  /// Mengambil kategori berdasarkan tipe (income/expense)
  ///
  /// Hanya mengembalikan kategori yang isActive = true
  /// - [type]: Filter tipe kategori (income/expense)
  ///
  /// Mengembalikan Result dengan list kategori yang difilter
  Future<Result<List<CategoryEntity>>> getCategoriesByType(CategoryType type);

  /// Mengambil kategori berdasarkan ID
  ///
  /// Mengembalikan Result dengan kategori jika ditemukan,
  /// NotFoundFailure jika tidak ditemukan
  Future<Result<CategoryEntity>> getCategoryById(int id);

  /// Mengambil kategori dengan jumlah transaksi (untuk tampilan list)
  ///
  /// Returns categories with transaction count using LEFT JOIN
  /// - [type]: Filter tipe kategori (income/expense)
  ///
  /// Mengembalikan Result dengan list kategori beserta jumlah transaksi
  Future<Result<List<CategoryEntity>>> getCategoriesWithCount(CategoryType type);

  /// Mengecek apakah nama kategori sudah ada (untuk validasi)
  ///
  /// - [name]: Nama kategori yang akan dicek
  /// - [type]: Tipe kategori
  /// - [excludeId]: Exclude kategori ini dari pengecekan (untuk update)
  ///
  /// Mengembalikan Result dengan kategori jika nama sudah ada,
  /// atau Result dengan null jika nama belum dipakai
  Future<Result<CategoryEntity?>> getCategoryByName(
    String name,
    CategoryType type, {
    int? excludeId,
  });

  /// Mengambil jumlah transaksi untuk sebuah kategori
  ///
  /// - [categoryId]: ID kategori
  ///
  /// Mengembalikan Result dengan jumlah transaksi
  Future<Result<int>> getTransactionCount(int categoryId);
}
