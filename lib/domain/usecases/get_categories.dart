import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/repositories/category_repository.dart';

/// Use case untuk mengambil list kategori
class GetCategoriesUseCase {
  final CategoryRepository _repository;

  GetCategoriesUseCase(this._repository);

  /// Mengambil semua kategori aktif
  Future<List<CategoryEntity>> execute() async {
    return await _repository.getCategories();
  }

  /// Mengambil kategori berdasarkan tipe (income/expense)
  /// Hanya mengembalikan kategori yang isActive = true
  Future<List<CategoryEntity>> executeByType(CategoryType type) async {
    return await _repository.getCategoriesByType(type);
  }

  /// Mengambil kategori berdasarkan ID
  Future<CategoryEntity?> executeById(int id) async {
    return await _repository.getCategoryById(id);
  }

  /// Mengecek apakah perlu seed default categories
  Future<bool> needsSeed() async {
    return await _repository.needsSeed();
  }

  /// Seed default categories ke database
  Future<void> seedDefaultCategories() async {
    await _repository.seedDefaultCategories();
  }
}
