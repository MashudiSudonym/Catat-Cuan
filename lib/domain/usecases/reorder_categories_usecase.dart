import 'package:catat_cuan/domain/repositories/category_repository.dart';
import 'add_category_usecase.dart' show CategoryValidationException;

/// Use case untuk mengubah urutan kategori (drag & drop)
class ReorderCategoriesUseCase {
  final CategoryRepository _repository;

  ReorderCategoriesUseCase(this._repository);

  /// Mengubah urutan kategori berdasarkan list ID dalam urutan baru
  /// Throws [CategoryValidationException] jika validasi gagal
  Future<void> execute(List<int> categoryIds) async {
    // Validasi list tidak boleh kosong
    if (categoryIds.isEmpty) {
      throw CategoryValidationException('Daftar kategori tidak boleh kosong');
    }

    // Validasi tidak ada duplikat ID
    if (categoryIds.toSet().length != categoryIds.length) {
      throw CategoryValidationException('Terjadi duplikasi ID kategori');
    }

    // Validasi semua kategori ada
    for (final id in categoryIds) {
      final category = await _repository.getCategoryById(id);
      if (category == null) {
        throw CategoryValidationException('Kategori dengan ID $id tidak ditemukan');
      }
    }

    // Lakukan reordering
    await _repository.reorderCategories(categoryIds);
  }
}
