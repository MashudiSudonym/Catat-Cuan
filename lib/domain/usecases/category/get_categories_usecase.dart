import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';

/// Use case untuk mengambil semua kategori aktif
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles getting all active categories
/// - Dependency Inversion: Depends on CategoryReadRepository abstraction
class GetCategoriesUseCase extends UseCase<List<CategoryEntity>, NoParams> {
  final CategoryReadRepository _repository;

  GetCategoriesUseCase(this._repository);

  @override
  Future<Result<List<CategoryEntity>>> call(NoParams params) async {
    try {
      final result = await _repository.getCategories();
      return result;
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengambil kategori: $e'),
      );
    }
  }
}
