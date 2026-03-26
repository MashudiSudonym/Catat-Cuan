import 'package:flutter/material.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/repositories/category/category_management_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_read_repository.dart';
import 'package:catat_cuan/domain/repositories/category/category_write_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Controller for handling category management operations
///
/// Responsibility: Managing category reorder and deletion operations
///
/// Following SRP - Only handles management operations (reorder, deactivate)
class CategoryManagementController {
  final CategoryManagementRepository _managementRepository;
  final CategoryReadRepository _readRepository;
  final CategoryWriteRepository _writeRepository;

  CategoryManagementController(
    this._managementRepository,
    this._readRepository,
    this._writeRepository,
  );

  /// Handle category reorder from drag and drop
  ///
  /// Returns true if reorder was successful, false otherwise
  Future<bool> handleReorder(
    int oldIndex,
    int newIndex,
    List<CategoryEntity> categories,
  ) async {
    AppLogger.d('Reordering category from index $oldIndex to $newIndex');

    try {
      // Adjust for moving item down
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      // Create reordered list
      final reorderedCategories = List<CategoryEntity>.from(categories);
      final category = reorderedCategories.removeAt(oldIndex);
      reorderedCategories.insert(newIndex, category);

      // Extract IDs in new order
      final categoryIds =
          reorderedCategories.map((c) => c.id!).toList(); // IDs are required

      // Update database
      final result = await _managementRepository.reorderCategories(categoryIds);

      return result.isSuccess;
    } catch (e) {
      AppLogger.e('Failed to reorder categories', e);
      return false;
    }
  }

  /// Show delete confirmation dialog and deactivate category
  ///
  /// Returns true if deactivation was successful, false otherwise
  Future<bool> showDeleteConfirmation(
    BuildContext context,
    CategoryEntity category,
  ) async {
    // Check if category has transactions
    final countResult =
        await _readRepository.getTransactionCount(category.id!);

    int transactionCount = 0;
    if (countResult.isSuccess && countResult.data != null) {
      transactionCount = countResult.data!;
    }

    if (!context.mounted) return false;

    final confirmed = await _showDeleteDialog(
      context,
      category,
      transactionCount,
    );

    if (!confirmed) return false;

    return await _deactivateCategory(category.id!);
  }

  /// Deactivate a category without confirmation
  ///
  /// This is useful when confirmation is handled elsewhere
  Future<void> deactivateCategory(String id) async {
    await _deactivateCategory(int.parse(id));
  }

  /// Internal method to deactivate a category
  Future<bool> _deactivateCategory(int id) async {
    try {
      final result = await _writeRepository.deleteCategory(id);
      return result.isSuccess;
    } catch (e) {
      AppLogger.e('Failed to deactivate category', e);
      return false;
    }
  }

  /// Show delete confirmation dialog
  ///
  /// Returns true if user confirmed, false otherwise
  Future<bool> _showDeleteDialog(
    BuildContext context,
    CategoryEntity category,
    int transactionCount,
  ) async {
    final String message = transactionCount > 0
        ? 'Kategori "${category.name}" memiliki $transactionCount transaksi. Jika dihapus, transaksi tersebut tetap ada tapi tidak akan memiliki kategori.'
        : 'Apakah Anda yakin ingin menghapus kategori "${category.name}"?';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
