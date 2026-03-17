import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/repositories/category_repository.dart';
import 'add_category_usecase.dart' show CategoryValidationException;

/// Use case untuk mengupdate kategori yang sudah ada
/// Catatan: Tipe kategori TIDAK BOLEH diubah setelah dibuat
class UpdateCategoryUseCase {
  final CategoryRepository _repository;

  UpdateCategoryUseCase(this._repository);

  /// Mengupdate kategori dengan validasi
  /// Hanya field name, color, dan icon yang boleh diubah
  /// Throws [CategoryValidationException] jika validasi gagal
  /// Throws [Exception] jika ID tidak ada
  Future<CategoryEntity> execute(CategoryEntity category) async {
    // Validasi ID harus ada
    if (category.id == null) {
      throw Exception('ID kategori wajib diisi untuk update');
    }

    // Ambil kategori yang sudah ada untuk validasi
    final existing = await _repository.getCategoryById(category.id!);
    if (existing == null) {
      throw Exception('Kategori tidak ditemukan');
    }

    // Validasi: tipe tidak boleh diubah
    if (existing.type != category.type) {
      throw CategoryValidationException(
        'Tipe kategori tidak dapat diubah',
      );
    }

    // Validasi nama tidak boleh kosong
    if (category.name.trim().isEmpty) {
      throw CategoryValidationException('Nama kategori tidak boleh kosong');
    }

    // Validasi panjang nama
    if (category.name.trim().length < 2) {
      throw CategoryValidationException('Nama kategori minimal 2 karakter');
    }

    if (category.name.trim().length > 50) {
      throw CategoryValidationException('Nama kategori maksimal 50 karakter');
    }

    // Validasi nama unik (kecuali untuk kategori itu sendiri)
    final duplicate = await _repository.getCategoryByName(
      category.name.trim(),
      category.type,
      excludeId: category.id,
    );

    if (duplicate != null) {
      throw CategoryValidationException(
        'Kategori "${category.name}" untuk ${category.type.displayName} sudah ada',
      );
    }

    // Buat entity untuk update dengan field yang diizinkan berubah
    final updatedCategory = CategoryEntity(
      id: category.id,
      name: category.name.trim(),
      type: existing.type, // Gunakan tipe yang sudah ada (tidak boleh diubah)
      color: category.color.isNotEmpty ? category.color : existing.color,
      icon: category.icon?.isNotEmpty == true ? category.icon : existing.icon,
      sortOrder: existing.sortOrder, // Tidak boleh diubah lewat update ini
      isActive: existing.isActive, // Tidak boleh diubah lewat update ini
      createdAt: existing.createdAt, // Tidak berubah
      updatedAt: DateTime.now(),
    );

    return await _repository.updateCategory(updatedCategory);
  }
}
