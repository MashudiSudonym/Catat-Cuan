import 'package:catat_cuan/domain/entities/category_with_count_entity.dart';

/// Hasil pengambilan kategori dengan count, dipisah per tipe
class CategoriesWithCountResult {
  final List<CategoryWithCountEntity> incomeCategories;
  final List<CategoryWithCountEntity> expenseCategories;
  final List<CategoryWithCountEntity> inactiveCategories;

  const CategoriesWithCountResult({
    required this.incomeCategories,
    required this.expenseCategories,
    required this.inactiveCategories,
  });

  /// Mengambil semua kategori aktif
  List<CategoryWithCountEntity> get activeCategories => [
        ...incomeCategories,
        ...expenseCategories,
      ];

  /// Mengambil semua kategori (aktif dan tidak aktif)
  List<CategoryWithCountEntity> get allCategories => [
        ...incomeCategories,
        ...expenseCategories,
        ...inactiveCategories,
      ];
}
