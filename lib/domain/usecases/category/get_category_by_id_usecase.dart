import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';

/// Use case untuk mengambil kategori berdasarkan ID
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles getting category by ID
/// - Dependency Inversion: Depends on CategoryReadRepository abstraction
class GetCategoryByIdUseCase extends UseCase<CategoryEntity, int> {
  final CategoryReadRepository _repository;

  GetCategoryByIdUseCase(this._repository);

  @override
  Future<Result<CategoryEntity>> call(int id) async {
    try {
      final result = await _repository.getCategoryById(id);
      return result;
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal mengambil kategori: $e'),
      );
    }
  }
}
