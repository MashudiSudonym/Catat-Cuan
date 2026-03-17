import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/category_with_count_entity.dart';
import 'package:catat_cuan/domain/usecases/get_categories_with_count_usecase.dart';
import 'package:catat_cuan/domain/usecases/deactivate_category_usecase.dart';
import 'package:catat_cuan/domain/usecases/reactivate_category_usecase.dart';
import 'package:catat_cuan/domain/usecases/reorder_categories_usecase.dart';
import 'package:catat_cuan/presentation/providers/usecases/category_usecase_providers.dart';

/// Provider untuk CategoryManagementNotifier
/// Following DIP: Injects UseCase dependencies through constructor
final categoryManagementProvider =
    StateNotifierProvider<CategoryManagementNotifier, CategoryManagementState>((ref) {
  return CategoryManagementNotifier(
    ref.read(getCategoriesWithCountUseCaseProvider),
    ref.read(deactivateCategoryUseCaseProvider),
    ref.read(reactivateCategoryUseCaseProvider),
    ref.read(reorderCategoriesUseCaseProvider),
  );
});

/// Tab yang aktif di CategoryManagementScreen
enum CategoryManagementTab {
  income,
  expense,
  inactive,
}

/// State untuk category management
class CategoryManagementState {
  final List<CategoryWithCountEntity> incomeCategories;
  final List<CategoryWithCountEntity> expenseCategories;
  final List<CategoryWithCountEntity> inactiveCategories;
  final bool isLoading;
  final String? error;
  final CategoryManagementTab selectedTab;
  final String searchQuery;

  const CategoryManagementState({
    this.incomeCategories = const [],
    this.expenseCategories = const [],
    this.inactiveCategories = const [],
    this.isLoading = false,
    this.error,
    this.selectedTab = CategoryManagementTab.income,
    this.searchQuery = '',
  });

  CategoryManagementState copyWith({
    List<CategoryWithCountEntity>? incomeCategories,
    List<CategoryWithCountEntity>? expenseCategories,
    List<CategoryWithCountEntity>? inactiveCategories,
    bool? isLoading,
    String? error,
    CategoryManagementTab? selectedTab,
    String? searchQuery,
  }) {
    return CategoryManagementState(
      incomeCategories: incomeCategories ?? this.incomeCategories,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      inactiveCategories: inactiveCategories ?? this.inactiveCategories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTab: selectedTab ?? this.selectedTab,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Get kategori yang sedang ditampilkan berdasarkan tab dan search
  List<CategoryWithCountEntity> get displayedCategories {
    List<CategoryWithCountEntity> categories;

    switch (selectedTab) {
      case CategoryManagementTab.income:
        categories = incomeCategories;
        break;
      case CategoryManagementTab.expense:
        categories = expenseCategories;
        break;
      case CategoryManagementTab.inactive:
        categories = inactiveCategories;
        break;
    }

    // Filter berdasarkan search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      categories = categories
          .where((cat) => cat.category.name.toLowerCase().contains(query))
          .toList();
    }

    return categories;
  }

  /// Check apakah sedang searching
  bool get isSearching => searchQuery.isNotEmpty;

  /// Get total kategori aktif
  int get totalActiveCategories =>
      incomeCategories.length + expenseCategories.length;

  /// Get total kategori tidak aktif
  int get totalInactiveCategories => inactiveCategories.length;
}

/// Notifier untuk category management
class CategoryManagementNotifier extends StateNotifier<CategoryManagementState> {
  final GetCategoriesWithCountUseCase _getCategoriesWithCountUseCase;
  final DeactivateCategoryUseCase _deactivateCategoryUseCase;
  final ReactivateCategoryUseCase _reactivateCategoryUseCase;
  final ReorderCategoriesUseCase _reorderCategoriesUseCase;

  CategoryManagementNotifier(
    this._getCategoriesWithCountUseCase,
    this._deactivateCategoryUseCase,
    this._reactivateCategoryUseCase,
    this._reorderCategoriesUseCase,
  ) : super(const CategoryManagementState()) {
    loadCategories();
  }

  /// Load semua kategori dengan count
  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _getCategoriesWithCountUseCase.execute();

      state = state.copyWith(
        incomeCategories: result.incomeCategories,
        expenseCategories: result.expenseCategories,
        inactiveCategories: result.inactiveCategories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        incomeCategories: [],
        expenseCategories: [],
        inactiveCategories: [],
      );
    }
  }

  /// Switch tab
  void switchTab(CategoryManagementTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  /// Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clear search
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  /// Deactivate kategori
  Future<bool> deactivateCategory(int categoryId) async {
    try {
      await _deactivateCategoryUseCase.execute(categoryId);
      await loadCategories(); // Refresh data
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Reactivate kategori
  Future<bool> reactivateCategory(int categoryId) async {
    try {
      await _reactivateCategoryUseCase.execute(categoryId);
      await loadCategories(); // Refresh data
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Reorder kategori (hanya untuk tab yang sedang aktif)
  Future<void> reorderCategories(List<int> categoryIds) async {
    try {
      await _reorderCategoriesUseCase.execute(categoryIds);
      await loadCategories(); // Refresh data
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Get transaction count untuk kategori (untuk warning dialog)
  Future<int> getTransactionCount(int categoryId) async {
    return await _deactivateCategoryUseCase.getTransactionCount(categoryId);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh data (pull to refresh)
  Future<void> refresh() async {
    await loadCategories();
  }
}
