import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/category_with_count_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';

import 'package:catat_cuan/presentation/providers/usecases/category_usecase_providers.dart';

part 'category_management_provider.g.dart';

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryManagementState &&
          runtimeType == other.runtimeType &&
          incomeCategories == other.incomeCategories &&
          expenseCategories == other.expenseCategories &&
          inactiveCategories == other.inactiveCategories &&
          isLoading == other.isLoading &&
          error == other.error &&
          selectedTab == other.selectedTab &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode =>
      incomeCategories.hashCode ^
      expenseCategories.hashCode ^
      inactiveCategories.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      selectedTab.hashCode ^
      searchQuery.hashCode;
}

/// Provider untuk category management
/// Following SRP: Only manages category list state and operations
/// Following DIP: Depends on UseCase abstractions
/// Uses @riverpod annotation for modern Riverpod patterns without constructor side effects
@riverpod
class CategoryManagementNotifier extends _$CategoryManagementNotifier {
  @override
  CategoryManagementState build() {
    // No constructor side effects - initialize state in build()
    // Load data immediately
    _loadCategories();
    return const CategoryManagementState(isLoading: true);
  }

  /// Load semua kategori dengan count
  Future<void> _loadCategories() async {
    AppLogger.d('Loading categories with transaction counts');

    final getCategoriesWithCountUseCase = ref.read(getCategoriesWithCountUseCaseProvider);

    final result = await getCategoriesWithCountUseCase(const NoParams());

    if (result.isFailure || result.data == null) {
      AppLogger.e('Failed to load categories: ${result.failure?.message}');
      state = state.copyWith(
        error: result.failure?.message ?? 'Failed to load categories',
        isLoading: false,
        incomeCategories: [],
        expenseCategories: [],
        inactiveCategories: [],
      );
      return;
    }

    final data = result.data!;
    AppLogger.i('Categories loaded: '
        '${data.incomeCategories.length} income, '
        '${data.expenseCategories.length} expense, '
        '${data.inactiveCategories.length} inactive');

    state = state.copyWith(
      incomeCategories: data.incomeCategories,
      expenseCategories: data.expenseCategories,
      inactiveCategories: data.inactiveCategories,
      isLoading: false,
    );
  }

  /// Switch tab
  void switchTab(CategoryManagementTab tab) {
    AppLogger.d('Switching to tab: $tab');
    state = state.copyWith(selectedTab: tab);
  }

  /// Set search query
  void setSearchQuery(String query) {
    AppLogger.d('Setting search query: "$query"');
    state = state.copyWith(searchQuery: query);
  }

  /// Clear search
  void clearSearch() {
    AppLogger.d('Clearing search query');
    state = state.copyWith(searchQuery: '');
  }

  /// Deactivate kategori
  Future<bool> deactivateCategory(int categoryId) async {
    AppLogger.d('Deactivating category: $categoryId');

    final deactivateCategoryUseCase = ref.read(deactivateCategoryUseCaseProvider);

    final result = await deactivateCategoryUseCase(categoryId);

    if (result.isFailure) {
      AppLogger.e('Failed to deactivate category: ${result.failure?.message}');
      state = state.copyWith(error: result.failure?.message ?? 'Failed to deactivate category');
      return false;
    }

    AppLogger.i('Category deactivated successfully: $categoryId');
    await _loadCategories(); // Refresh data
    return true;
  }

  /// Reactivate kategori
  Future<bool> reactivateCategory(int categoryId) async {
    AppLogger.d('Reactivating category: $categoryId');

    final reactivateCategoryUseCase = ref.read(reactivateCategoryUseCaseProvider);

    final result = await reactivateCategoryUseCase(categoryId);

    if (result.isFailure) {
      AppLogger.e('Failed to reactivate category: ${result.failure?.message}');
      state = state.copyWith(error: result.failure?.message ?? 'Failed to reactivate category');
      return false;
    }

    AppLogger.i('Category reactivated successfully: $categoryId');
    await _loadCategories(); // Refresh data
    return true;
  }

  /// Reorder kategori (hanya untuk tab yang sedang aktif)
  Future<void> reorderCategories(List<int> categoryIds) async {
    AppLogger.d('Reordering ${categoryIds.length} categories');

    try {
      final reorderCategoriesUseCase = ref.read(reorderCategoriesUseCaseProvider);

      final result = await reorderCategoriesUseCase(categoryIds);

      if (result.isFailure) {
        AppLogger.e('Failed to reorder categories: ${result.failure?.message}');
        state = state.copyWith(error: result.failure?.message ?? 'Failed to reorder categories');
        return;
      }

      AppLogger.i('Categories reordered successfully');
      await _loadCategories(); // Refresh data
    } catch (e, stackTrace) {
      final userMessage = ErrorMessageMapper.getUserMessage(e);
      AppLogger.e('Failed to reorder categories', e, stackTrace);
      state = state.copyWith(error: userMessage);
    }
  }

  /// Get transaction count untuk kategori (untuk warning dialog)
  Future<int> getTransactionCount(int categoryId) async {
    AppLogger.d('Getting transaction count for category: $categoryId');

    final getCategoryTransactionCountUseCase = ref.read(getCategoryTransactionCountUseCaseProvider);
    final result = await getCategoryTransactionCountUseCase(categoryId);

    if (result.isFailure) {
      AppLogger.e('Failed to get transaction count: ${result.failure?.message}');
      return 0;
    }

    final count = result.data ?? 0;
    AppLogger.d('Transaction count for category $categoryId: $count');
    return count;
  }

  /// Clear error
  void clearError() {
    AppLogger.d('Clearing error state');
    state = state.copyWith(error: null);
  }

  /// Refresh data (pull to refresh)
  Future<void> refresh() async {
    AppLogger.d('Refreshing categories');
    await _loadCategories();
  }
}
