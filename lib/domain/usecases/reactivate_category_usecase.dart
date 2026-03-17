import 'package:catat_cuan/domain/repositories/category_repository.dart';
import 'add_category_usecase.dart' show CategoryValidationException;

/// Use case untuk mengaktifkan kembali kategori yang sudah dinonaktifkan
class ReactivateCategoryUseCase {
  final CategoryRepository _repository;

  ReactivateCategoryUseCase(this._repository);

  /// Mengaktifkan kembali kategori yang sudah dinonaktifkan
  /// Throws [CategoryValidationException] jika validasi gagal
  /// Returns true jika berhasil diaktifkan kembali
  Future<bool> execute(int categoryId) async {
    // Cek apakah kategori ada
    final category = await _repository.getCategoryById(categoryId);
    if (category == null) {
      throw CategoryValidationException('Kategori tidak ditemukan');
    }

    // Cek apakah kategori sudah aktif
    if (category.isActive) {
      throw CategoryValidationException('Kategori sudah aktif');
    }

    // Aktifkan kembali kategori
    return await _repository.reactivateCategory(categoryId);
  }
}
