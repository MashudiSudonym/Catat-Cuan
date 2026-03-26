import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_management_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';

/// Use case untuk mengaktifkan kembali kategori yang sudah dinonaktifkan
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles reactivating categories
/// - Dependency Inversion: Depends on CategoryReadRepository and CategoryManagementRepository abstractions
class ReactivateCategoryUseCase extends UseCase<void, int> {
  final CategoryManagementRepository _managementRepository;
  final CategoryReadRepository _readRepository;

  ReactivateCategoryUseCase(this._managementRepository, this._readRepository);

  @override
  Future<Result<void>> call(int categoryId) async {
    // Cek apakah kategori ada
    final categoryResult = await _readRepository.getCategoryById(categoryId);

    if (categoryResult.isFailure || categoryResult.data == null) {
      return Result.failure(
        const NotFoundFailure('Kategori tidak ditemukan'),
      );
    }

    final category = categoryResult.data!;

    // Cek apakah kategori sudah aktif
    if (category.isActive) {
      return Result.failure(
        const ValidationFailure('Kategori sudah aktif'),
      );
    }

    // Aktifkan kembali kategori
    try {
      final result = await _managementRepository.reactivateCategory(categoryId);
      return result;
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengaktifkan kembali kategori: $e'),
      );
    }
  }
}
