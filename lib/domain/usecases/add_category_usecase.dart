import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_write_repository.dart';

/// Use case untuk menambah kategori baru dengan validasi
///
/// Following SOLID principles:
/// - Single Responsibility: Only handles adding categories with validation
/// - Dependency Inversion: Depends on CategoryReadRepository and CategoryWriteRepository abstractions
class AddCategoryUseCase extends UseCase<CategoryEntity, CategoryEntity> {
  final CategoryWriteRepository _writeRepository;
  final CategoryReadRepository _readRepository;

  // Default values untuk auto-assignment
  static const List<String> defaultColors = [
    '#4CAF50', '#8BC34A', '#CDDC39', '#FFEB3B', '#FFC107',
    '#FF9800', '#FF5722', '#F44336', '#E91E63', '#9C27B0',
    '#673AB7', '#3F51B5', '#2196F3', '#03A9F4', '#00BCD4',
    '#009688', '#607D8B', '#795548', '#9E9E9E',
  ];

  static const Map<String, List<String>> iconsByType = {
    'income': ['💰', '🎁', '💼', '🎀', '📈', '💵', '🏦', '💳', '🪙'],
    'expense': ['🍔', '🚗', '🔄', '🛍️', '🎬', '💊', '📚', '📄', '⚡', '🏠'],
  };

  AddCategoryUseCase(this._writeRepository, this._readRepository);

  @override
  Future<Result<CategoryEntity>> call(CategoryEntity category) async {
    // Validasi nama tidak boleh kosong
    if (category.name.trim().isEmpty) {
      return Result.failure(
        const ValidationFailure('Nama kategori tidak boleh kosong'),
      );
    }

    // Validasi panjang nama
    if (category.name.trim().length < 2) {
      return Result.failure(
        const ValidationFailure('Nama kategori minimal 2 karakter'),
      );
    }

    if (category.name.trim().length > 50) {
      return Result.failure(
        const ValidationFailure('Nama kategori maksimal 50 karakter'),
      );
    }

    // Validasi nama unik per tipe
    final existingResult = await _readRepository.getCategoryByName(
      category.name.trim(),
      category.type,
    );

    if (existingResult.isSuccess && existingResult.data != null) {
      return Result.failure(
        ValidationFailure(
          'Kategori "${category.name}" untuk ${category.type.displayName} sudah ada',
        ),
      );
    }

    // Auto-assign color jika tidak ada
    final color = category.color.isNotEmpty
        ? category.color
        : _getRandomColor();

    // Auto-assign icon jika tidak ada
    final icon = category.icon?.isNotEmpty == true
        ? category.icon
        : _getDefaultIcon(category.type);

    // Buat entity baru dengan values yang sudah di-auto-assign
    final now = DateTime.now();
    final newCategory = CategoryEntity(
      name: category.name.trim(),
      type: category.type,
      color: color,
      icon: icon,
      sortOrder: category.sortOrder > 0 ? category.sortOrder : 999,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    try {
      final result = await _writeRepository.addCategory(newCategory);
      return result;
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Gagal menambah kategori: $e'),
      );
    }
  }

  /// Mendapatkan warna random dari preset
  String _getRandomColor() {
    return defaultColors[DateTime.now().millisecond % defaultColors.length];
  }

  /// Mendapatkan icon default berdasarkan tipe
  String _getDefaultIcon(CategoryType type) {
    final icons = iconsByType[type.value] ?? ['📦'];
    return icons[DateTime.now().millisecond % icons.length];
  }
}
