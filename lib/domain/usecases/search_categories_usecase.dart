import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';

/// Parameter untuk pencarian kategori
class SearchCategoriesParams {
  final String query;
  final CategoryType? typeFilter;

  const SearchCategoriesParams({
    required this.query,
    this.typeFilter,
  });
}

/// Hasil pencarian kategori dengan informasi tipe
class SearchResult {
  final List<CategoryEntity> incomeCategories;
  final List<CategoryEntity> expenseCategories;

  const SearchResult({
    required this.incomeCategories,
    required this.expenseCategories,
  });

  /// Mengambil semua kategori dari hasil pencarian
  List<CategoryEntity> get allCategories => [
        ...incomeCategories,
        ...expenseCategories,
      ];

  /// Menghitung total kategori yang ditemukan
  int get totalCount => incomeCategories.length + expenseCategories.length;
}

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
