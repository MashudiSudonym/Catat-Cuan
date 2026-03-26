import 'package:catat_cuan/domain/entities/category_entity.dart';

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
