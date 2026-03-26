import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'search_categories_params.dart';
import 'search_result.dart';

/// Use case untuk mencari kategori berdasarkan nama
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles searching categories
/// - Dependency Inversion: Depends on CategoryReadRepository abstraction
class SearchCategoriesUseCase extends UseCase<SearchResult, SearchCategoriesParams> {
  final CategoryReadRepository _repository;

  SearchCategoriesUseCase(this._repository);

  @override
  Future<Result<SearchResult>> call(SearchCategoriesParams params) async {
    // Ambil semua kategori aktif
    final allCategoriesResult = await _repository.getCategories();

    if (allCategoriesResult.isFailure) {
      return Result.failure(
        allCategoriesResult.failure!,
      );
    }

    final allCategories = allCategoriesResult.data ?? [];

    // Filter berdasarkan query dan tipe
    final searchQuery = params.query.toLowerCase().trim();

    List<CategoryEntity> incomeResults = [];
    List<CategoryEntity> expenseResults = [];

    for (final category in allCategories) {
      // Skip jika tidak cocok dengan tipe filter
      if (params.typeFilter != null && category.type != params.typeFilter) {
        continue;
      }

      // Filter berdasarkan query nama
      if (searchQuery.isEmpty ||
          category.name.toLowerCase().contains(searchQuery)) {
        // Group berdasarkan tipe
        if (category.type == CategoryType.income) {
          incomeResults.add(category);
        } else {
          expenseResults.add(category);
        }
      }
    }

    return Result.success(
      SearchResult(
        incomeCategories: incomeResults,
        expenseCategories: expenseResults,
      ),
    );
  }
}
