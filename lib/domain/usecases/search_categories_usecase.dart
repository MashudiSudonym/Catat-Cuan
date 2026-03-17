import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/repositories/category_repository.dart';

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
class SearchCategoriesUseCase {
  final CategoryRepository _repository;

  SearchCategoriesUseCase(this._repository);

  /// Mencari kategori berdasarkan nama dengan filter tipe
  /// Jika typeFilter null, mencari semua tipe
  /// Jika query kosong, mengembalikan semua kategori aktif
  Future<SearchResult> execute(String query, {CategoryType? typeFilter}) async {
    // Ambil semua kategori aktif
    final allCategories = await _repository.getCategories();

    // Filter berdasarkan query dan tipe
    final searchQuery = query.toLowerCase().trim();

    List<CategoryEntity> incomeResults = [];
    List<CategoryEntity> expenseResults = [];

    for (final category in allCategories) {
      // Skip jika tidak cocok dengan tipe filter
      if (typeFilter != null && category.type != typeFilter) {
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

    return SearchResult(
      incomeCategories: incomeResults,
      expenseCategories: expenseResults,
    );
  }

  /// Mencari kategori dengan tipe tertentu saja
  Future<List<CategoryEntity>> executeByType(
    String query,
    CategoryType type,
  ) async {
    final result = await execute(query, typeFilter: type);

    return type == CategoryType.income
        ? result.incomeCategories
        : result.expenseCategories;
  }
}
