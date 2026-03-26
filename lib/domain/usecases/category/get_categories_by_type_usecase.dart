import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';

/// Use case untuk mengambil kategori berdasarkan tipe
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles getting categories by type
/// - Dependency Inversion: Depends on CategoryReadRepository abstraction
class GetCategoriesByTypeUseCase extends UseCase<List<CategoryEntity>, CategoryType> {
  final CategoryReadRepository _repository;

  GetCategoriesByTypeUseCase(this._repository);

  @override
  Future<Result<List<CategoryEntity>>> call(CategoryType type) async {
    try {
      final result = await _repository.getCategoriesByType(type);
      return result;
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengambil kategori: $e'),
      );
    }
  }
}
