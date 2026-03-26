import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_management_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';

/// Use case untuk mengubah urutan kategori (drag & drop)
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles reordering categories
/// - Dependency Inversion: Depends on CategoryReadRepository and CategoryManagementRepository abstractions
class ReorderCategoriesUseCase extends UseCase<void, List<int>> {
  final CategoryManagementRepository _managementRepository;
  final CategoryReadRepository _readRepository;

  ReorderCategoriesUseCase(this._managementRepository, this._readRepository);

  @override
  Future<Result<void>> call(List<int> categoryIds) async {
    // Validasi list tidak boleh kosong
    if (categoryIds.isEmpty) {
      return Result.failure(
        const ValidationFailure('Daftar kategori tidak boleh kosong'),
      );
    }

    // Validasi tidak ada duplikat ID
    if (categoryIds.toSet().length != categoryIds.length) {
      return Result.failure(
        const ValidationFailure('Terjadi duplikasi ID kategori'),
      );
    }

    // Validasi semua kategori ada
    for (final id in categoryIds) {
      final categoryResult = await _readRepository.getCategoryById(id);

      if (categoryResult.isFailure || categoryResult.data == null) {
        return Result.failure(
          NotFoundFailure('Kategori dengan ID $id tidak ditemukan'),
        );
      }
    }

    // Lakukan reordering
    try {
      final result = await _managementRepository.reorderCategories(categoryIds);
      return result;
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengubah urutan kategori: $e'),
      );
    }
  }
}
