import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';

/// Repository interface untuk menulis kategori
///
/// Following Interface Segregation Principle (ISP) - hanya berisi operasi tulis
///
/// Responsibility: Membuat, mengupdate, dan menghapus kategori
abstract class CategoryWriteRepository {
  /// Menambahkan kategori baru
  ///
  /// Mengembalikan Result dengan CategoryEntity yang sudah disertai ID jika sukses
  Future<Result<CategoryEntity>> addCategory(CategoryEntity category);

  /// Mengupdate kategori yang sudah ada
  ///
  /// Mengembalikan Result dengan CategoryEntity yang sudah diupdate
  /// Mengembalikan NotFoundFailure jika kategori tidak ditemukan
  Future<Result<CategoryEntity>> updateCategory(CategoryEntity category);

  /// Menghapus kategori (soft delete dengan set isActive = false)
  ///
  /// - [id]: ID kategori yang akan dihapus
  ///
  /// Mengembalikan Result yang sukses jika berhasil dihapus
  /// Mengembalikan NotFoundFailure jika kategori tidak ditemukan
  Future<Result<void>> deleteCategory(int id);
}
