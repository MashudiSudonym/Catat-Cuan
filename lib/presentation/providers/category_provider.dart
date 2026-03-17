import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/usecases/get_categories.dart';
import 'package:catat_cuan/presentation/providers/usecases/category_usecase_providers.dart';

/// Provider untuk CategoryListNotifier
/// Following DIP: Injects UseCase dependency through constructor
final categoryListProvider =
    StateNotifierProvider<CategoryListNotifier, CategoryListState>((ref) {
  return CategoryListNotifier(
    ref.read(getCategoriesUseCaseProvider),
  );
});

/// State untuk category list
class CategoryListState {
  final List<CategoryEntity> categories;
  final bool isLoading;
  final String? error;

  const CategoryListState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoryListState copyWith({
    List<CategoryEntity>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoryListState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// When-like method for handling state
  R when<R>({
    required R Function(List<CategoryEntity> categories) data,
    required R Function() loading,
    required R Function(String error, Object? stackTrace) error,
  }) {
    if (isLoading) {
      return loading();
    } else {
      final errorStr = this.error;
      if (errorStr != null) {
        return error(errorStr, null);
      } else {
        return data(categories);
      }
    }
  }
}

/// Notifier untuk category list
class CategoryListNotifier extends StateNotifier<CategoryListState> {
  final GetCategoriesUseCase _getCategoriesUseCase;

  CategoryListNotifier(this._getCategoriesUseCase)
      : super(const CategoryListState()) {
    // Load categories on initialization
    loadCategories();
  }

  /// Load semua kategori aktif
  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final categories = await _getCategoriesUseCase.execute();
      state = state.copyWith(
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Load kategori berdasarkan tipe (income/expense)
  Future<List<CategoryEntity>> getCategoriesByType(String typeStr) async {
    final type = typeStr == 'income'
        ? CategoryType.income
        : CategoryType.expense;

    return await _getCategoriesUseCase.executeByType(type);
  }
}
