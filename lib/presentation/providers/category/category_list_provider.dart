import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:catat_cuan/presentation/providers/usecases/category_usecase_providers.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

part 'category_list_provider.g.dart';

// Type alias for backward compatibility during UI migration
typedef CategoryListState = AsyncValue<List<CategoryEntity>>;

/// Provider untuk category list
/// Following SRP: Only manages category list state and loading
/// Following DIP: Depends on UseCase abstraction, not concrete implementation
/// Uses AsyncNotifier for proper async handling without constructor side effects
@riverpod
class CategoryListNotifier extends _$CategoryListNotifier {
  @override
  Future<List<CategoryEntity>> build() async {
    // No constructor side effects - data loading in build() method
    final getCategoriesUseCase = ref.read(getCategoriesUseCaseProvider);
    final result = await getCategoriesUseCase(const NoParams());

    if (result.isFailure) {
      AppLogger.e('Failed to load categories: ${result.failure?.message}');
      throw Exception(result.failure?.message ?? 'Failed to load categories');
    }

    return result.data ?? [];
  }

  /// Load kategori berdasarkan tipe (income/expense)
  /// Note: This doesn't change state, just returns filtered data
  Future<List<CategoryEntity>> getCategoriesByType(String typeStr) async {
    final getCategoriesByTypeUseCase = ref.read(getCategoriesByTypeUseCaseProvider);
    final type = typeStr == 'income' ? CategoryType.income : CategoryType.expense;
    final result = await getCategoriesByTypeUseCase(type);

    if (result.isFailure) {
      AppLogger.e('Failed to load categories by type: ${result.failure?.message}');
      return [];
    }

    return result.data ?? [];
  }

  /// Load categories (alias for backward compatibility during UI migration)
  /// @deprecated Use refresh() instead
  Future<void> loadCategories() async {
    await refresh();
  }

  /// Refresh data (pull to refresh)
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
