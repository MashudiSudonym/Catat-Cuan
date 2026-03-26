import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_write_repository.dart';

/// Use case untuk mengupdate kategori yang sudah ada
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles updating categories
/// - Dependency Inversion: Depends on CategoryReadRepository and CategoryWriteRepository abstractions
///
/// Catatan: Tipe kategori TIDAK BOLEH diubah setelah dibuat
class UpdateCategoryUseCase extends UseCase<CategoryEntity, CategoryEntity> {
  final CategoryWriteRepository _writeRepository;
  final CategoryReadRepository _readRepository;

  UpdateCategoryUseCase(this._writeRepository, this._readRepository);

  @override
  Future<Result<CategoryEntity>> call(CategoryEntity category) async {
    // Validasi ID harus ada
    if (category.id == null) {
      return Result.failure(
        const ValidationFailure('ID kategori wajib diisi untuk update'),
      );
    }

    // Ambil kategori yang sudah ada untuk validasi
    final existingResult = await _readRepository.getCategoryById(category.id!);

    if (existingResult.isFailure || existingResult.data == null) {
      return Result.failure(
        const NotFoundFailure('Kategori tidak ditemukan'),
      );
    }

    final existing = existingResult.data!;

    // Validasi: tipe tidak boleh diubah
    if (existing.type != category.type) {
      return Result.failure(
        const ValidationFailure('Tipe kategori tidak dapat diubah'),
      );
    }

    // Validasi nama tidak boleh kosong
    if (category.name.trim().isEmpty) {
      return Result.failure(
        const ValidationFailure('Nama kategori tidak boleh kosong'),
      );
    }

    // Validasi panjang nama
    if (category.name.trim().length < 2) {
      return Result.failure(
        const ValidationFailure('Nama kategori minimal 2 karakter'),
      );
    }

    if (category.name.trim().length > 50) {
      return Result.failure(
        const ValidationFailure('Nama kategori maksimal 50 karakter'),
      );
    }

    // Validasi nama unik (kecuali untuk kategori itu sendiri)
    final duplicateResult = await _readRepository.getCategoryByName(
      category.name.trim(),
      category.type,
      excludeId: category.id,
    );

    if (duplicateResult.isSuccess && duplicateResult.data != null) {
      return Result.failure(
        ValidationFailure(
          'Kategori "${category.name}" untuk ${category.type.displayName} sudah ada',
        ),
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

    try {
      final result = await _writeRepository.updateCategory(updatedCategory);
      return result;
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengupdate kategori: $e'),
      );
    }
  }
}
