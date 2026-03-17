import 'package:catat_cuan/domain/repositories/category_repository.dart';
import 'add_category_usecase.dart' show CategoryValidationException;

/// Use case untuk menonaktifkan kategori (soft delete)
class DeactivateCategoryUseCase {
  final CategoryRepository _repository;

  DeactivateCategoryUseCase(this._repository);

  /// Menonaktifkan kategori dengan validasi
  /// Throws [CategoryValidationException] jika kategori masih digunakan
  /// Returns true jika berhasil dinonaktifkan
  Future<bool> execute(int categoryId) async {
    // Cek apakah kategori ada
    final category = await _repository.getCategoryById(categoryId);
    if (category == null) {
      throw CategoryValidationException('Kategori tidak ditemukan');
    }

    // Cek apakah kategori sudah tidak aktif
    if (!category.isActive) {
      throw CategoryValidationException('Kategori sudah tidak aktif');
    }

    // Cek apakah kategori masih digunakan oleh transaksi
    final transactionCount = await _repository.getTransactionCount(categoryId);

    if (transactionCount > 0) {
      throw CategoryValidationException(
        'Kategori ini tidak dapat dinonaktifkan karena masih digunakan '
        'oleh $transactionCount transaksi. '
        'Gunakan kategori lain untuk transaksi tersebut terlebih dahulu.',
      );
    }

    // Nonaktifkan kategori
    return await _repository.deleteCategory(categoryId);
  }

  /// Mendapatkan jumlah transaksi untuk sebuah kategori
  /// Untuk menampilkan warning sebelum deactivate
  Future<int> getTransactionCount(int categoryId) async {
    return await _repository.getTransactionCount(categoryId);
  }
}
