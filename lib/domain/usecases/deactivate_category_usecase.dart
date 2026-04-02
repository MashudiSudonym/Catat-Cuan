import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_write_repository.dart';

/// Use case untuk menonaktifkan kategori (soft delete)
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles deactivating categories
/// - Dependency Inversion: Depends on CategoryReadRepository and CategoryWriteRepository abstractions
class DeactivateCategoryUseCase extends UseCase<void, int> {
  final CategoryWriteRepository _writeRepository;
  final CategoryReadRepository _readRepository;

  DeactivateCategoryUseCase(this._writeRepository, this._readRepository);

  @override
  Future<Result<void>> call(int categoryId) async {
    try {
      // Cek apakah kategori ada
      final categoryResult = await _readRepository.getCategoryById(categoryId);

      if (categoryResult.isFailure || categoryResult.data == null) {
        return Result.failure(
          const NotFoundFailure('Kategori tidak ditemukan'),
        );
      }

      final category = categoryResult.data!;

      // Cek apakah kategori sudah tidak aktif
      if (!category.isActive) {
        return Result.failure(
          const ValidationFailure('Kategori sudah tidak aktif'),
        );
      }

      // Cek apakah kategori masih digunakan oleh transaksi
      final transactionCountResult =
          await _readRepository.getTransactionCount(categoryId);

      final transactionCount = transactionCountResult.data ?? 0;

      if (transactionCount > 0) {
        return Result.failure(
          ValidationFailure(
            'Kategori ini tidak dapat dinonaktifkan karena masih digunakan '
            'oleh $transactionCount transaksi. '
            'Gunakan kategori lain untuk transaksi tersebut terlebih dahulu.',
          ),
        );
      }

      // Nonaktifkan kategori
      try {
        final result = await _writeRepository.deleteCategory(categoryId);
        return result;
      } catch (e) {
        return Result.failure(
          DatabaseFailure('Gagal menonaktifkan kategori: $e'),
        );
      }
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal menonaktifkan kategori: $e'),
      );
    }
  }
}

/// Use case untuk mendapatkan jumlah transaksi untuk sebuah kategori
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles getting transaction count
/// - Dependency Inversion: Depends on CategoryReadRepository abstraction
class GetCategoryTransactionCountUseCase extends UseCase<int, int> {
  final CategoryReadRepository _readRepository;

  GetCategoryTransactionCountUseCase(this._readRepository);

  @override
  Future<Result<int>> call(int categoryId) async {
    try {
      final result = await _readRepository.getTransactionCount(categoryId);
      return result;
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengambil jumlah transaksi: $e'),
      );
    }
  }
}
