import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/entities/category_with_count_entity.dart';
import 'package:catat_cuan/domain/repositories/category_repository.dart';

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

/// Use case untuk mengambil kategori dengan jumlah transaksi
class GetCategoriesWithCountUseCase {
  final CategoryRepository _repository;

  GetCategoriesWithCountUseCase(this._repository);

  /// Mengambil semua kategori dengan jumlah transaksi, dipisah per tipe
  Future<CategoriesWithCountResult> execute() async {
    // Ambil kategori aktif per tipe
    final incomeCategories = await _getCategoriesWithCountByType(
      CategoryType.income,
    );
    final expenseCategories = await _getCategoriesWithCountByType(
      CategoryType.expense,
    );

    // Ambil kategori tidak aktif
    final inactiveCategories = await _getInactiveCategoriesWithCount();

    return CategoriesWithCountResult(
      incomeCategories: incomeCategories,
      expenseCategories: expenseCategories,
      inactiveCategories: inactiveCategories,
    );
  }

  /// Mengambil kategori dengan count berdasarkan tipe
  Future<List<CategoryWithCountEntity>> executeByType(CategoryType type) async {
    return await _getCategoriesWithCountByType(type);
  }

  /// Mengambil kategori tidak aktif dengan count
  Future<List<CategoryWithCountEntity>> executeInactive() async {
    return await _getInactiveCategoriesWithCount();
  }

  /// Internal method: ambil kategori dengan count berdasarkan tipe
  Future<List<CategoryWithCountEntity>> _getCategoriesWithCountByType(
    CategoryType type,
  ) async {
    final categories = await _repository.getCategoriesWithCount(type);

    // Ambil transaction count untuk setiap kategori
    final result = <CategoryWithCountEntity>[];
    for (final category in categories) {
      final count = await _repository.getTransactionCount(category.id!);
      result.add(CategoryWithCountEntity(
        category: category,
        transactionCount: count,
      ));
    }

    return result;
  }

  /// Internal method: ambil kategori tidak aktif dengan count
  Future<List<CategoryWithCountEntity>> _getInactiveCategoriesWithCount() async {
    final categories = await _repository.getInactiveCategories();

    // Ambil transaction count untuk setiap kategori
    final result = <CategoryWithCountEntity>[];
    for (final category in categories) {
      final count = await _repository.getTransactionCount(category.id!);
      result.add(CategoryWithCountEntity(
        category: category,
        transactionCount: count,
      ));
    }

    return result;
  }

  /// Refresh data kategori (invalidate cache jika ada)
  Future<void> refresh() async {
    // Untuk implementasi cache di masa depan
    // Saat ini hanya menjalankan execute untuk memastikan data terbaru
    await execute();
  }
}
