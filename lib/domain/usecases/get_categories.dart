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

/// Parameter untuk mengambil kategori berdasarkan ID
class GetCategoryByIdParams {
  final int id;

  const GetCategoryByIdParams({required this.id});
}

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
