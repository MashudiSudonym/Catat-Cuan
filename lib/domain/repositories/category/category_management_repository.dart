import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';

/// Repository interface untuk manajemen kategori
///
/// Following Interface Segregation Principle (ISP) - hanya berisi operasi manajemen
///
/// Responsibility: Mengelola status aktif/non-aktif dan urutan kategori
abstract class CategoryManagementRepository {
  /// Mengambil kategori yang tidak aktif (untuk tab "Tidak Aktif")
  ///
  /// Mengembalikan Result dengan list kategori yang tidak aktif
  Future<Result<List<CategoryEntity>>> getInactiveCategories();

  /// Mengaktifkan kembali kategori yang sudah dinonaktifkan
  ///
  /// - [id]: ID kategori yang akan diaktifkan kembali
  ///
  /// Mengembalikan Result yang sukses jika berhasil diaktifkan
  /// Mengembalikan NotFoundFailure jika kategori tidak ditemukan
  Future<Result<void>> reactivateCategory(int id);

  /// Mengubah urutan kategori (batch update sort_order)
  ///
  /// - [categoryIds]: List ID kategori dalam urutan baru
  ///
  /// Mengembalikan Result yang sukses jika berhasil diurutkan
  /// Mengembalikan ValidationFailure jika list kosong
  Future<Result<void>> reorderCategories(List<int> categoryIds);
}
