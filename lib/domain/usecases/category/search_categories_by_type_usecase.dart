import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'search_categories_params.dart';

/// Use case untuk mencari kategori dengan tipe tertentu saja
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles searching categories by type
/// - Dependency Inversion: Depends on CategoryReadRepository abstraction
class SearchCategoriesByTypeUseCase extends UseCase<List<CategoryEntity>, SearchCategoriesParams> {
  final CategoryReadRepository _repository;

  SearchCategoriesByTypeUseCase(this._repository);

  @override
  Future<Result<List<CategoryEntity>>> call(SearchCategoriesParams params) async {
    if (params.typeFilter == null) {
      return Result.failure(
        const ValidationFailure('Tipe kategori wajib ditentukan'),
      );
    }

    final result = await _repository.getCategoriesByType(params.typeFilter!);

    if (result.isFailure) {
      return result;
    }

    final categories = result.data ?? [];
    final searchQuery = params.query.toLowerCase().trim();

    final filtered = categories.where((category) {
      return searchQuery.isEmpty ||
          category.name.toLowerCase().contains(searchQuery);
    }).toList();

    return Result.success(filtered);
  }
}
