import 'package:catat_cuan/domain/entities/paginated_result_entity.dart';
import 'package:catat_cuan/domain/entities/pagination_params_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'transaction_filter_provider.dart';
import 'package:catat_cuan/presentation/providers/usecases/transaction_usecase_providers.dart';

part 'transaction_list_paginated_provider.g.dart';

/// Paginated transaction list state
class PaginatedTransactionListState {
  final List<TransactionEntity> transactions;
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  const PaginatedTransactionListState({
    this.transactions = const [],
    this.currentPage = 1,
    this.itemsPerPage = 20,
    this.totalItems = 0,
    this.totalPages = 0,
    this.hasNextPage = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  PaginatedTransactionListState copyWith({
    List<TransactionEntity>? transactions,
    int? currentPage,
    int? itemsPerPage,
    int? totalItems,
    int? totalPages,
    bool? hasNextPage,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) {
    return PaginatedTransactionListState(
      transactions: transactions ?? this.transactions,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginatedTransactionListState &&
          runtimeType == other.runtimeType &&
          transactions == other.transactions &&
          currentPage == other.currentPage &&
          itemsPerPage == other.itemsPerPage &&
          totalItems == other.totalItems &&
          totalPages == other.totalPages &&
          hasNextPage == other.hasNextPage &&
          isLoading == other.isLoading &&
          isLoadingMore == other.isLoadingMore &&
          error == other.error;

  @override
  int get hashCode =>
      transactions.hashCode ^
      currentPage.hashCode ^
      itemsPerPage.hashCode ^
      totalItems.hashCode ^
      totalPages.hashCode ^
      hasNextPage.hashCode ^
      isLoading.hashCode ^
      isLoadingMore.hashCode ^
      error.hashCode;
}

/// Provider untuk paginated transaction list
/// Following SRP: Only manages paginated transaction list state and loading
/// Following DIP: Depends on UseCase abstraction, not concrete implementation
/// Uses @riverpod annotation for modern Riverpod patterns
@riverpod
class TransactionListPaginatedNotifier extends _$TransactionListPaginatedNotifier {
  // Pagination constants
  static const int _itemsPerPage = 20;

  @override
  PaginatedTransactionListState build() {
    // No constructor side effects - data loading in build()
    _loadInitialData();
    return const PaginatedTransactionListState(isLoading: true);
  }

  /// Load initial data (first page)
  Future<void> _loadInitialData() async {
    final filterState = ref.watch(transactionFilterNotifierProvider);
    final pagination = PaginationParamsEntity(page: 1, limit: _itemsPerPage);

    final paginatedResult = await _executePaginatedQuery(pagination, filterState);

    state = state.copyWith(
      transactions: paginatedResult.data,
      currentPage: paginatedResult.currentPage,
      totalItems: paginatedResult.totalItems,
      totalPages: paginatedResult.totalPages,
      hasNextPage: paginatedResult.hasNextPage,
      isLoading: false,
    );
  }

  /// Execute paginated query based on filter state
  Future<PaginatedResultEntity<TransactionEntity>> _executePaginatedQuery(
    PaginationParamsEntity pagination,
    TransactionFilterState filterState,
  ) async {
    final getTransactionsPaginatedUseCase = ref.read(getTransactionsPaginatedUseCaseProvider);

    return await getTransactionsPaginatedUseCase.execute(
      pagination,
      startDate: filterState.startDate,
      endDate: filterState.endDate,
      categoryId: filterState.categoryId,
      type: filterState.type,
    );
  }

  /// Load more items (next page)
  Future<void> loadMore() async {
    // Don't load if already loading or no more pages
    if (state.isLoading || state.isLoadingMore || !state.hasNextPage) {
      return;
    }

    final filterState = ref.read(transactionFilterNotifierProvider);
    final nextPage = state.currentPage + 1;
    final pagination = PaginationParamsEntity(page: nextPage, limit: _itemsPerPage);

    state = state.copyWith(isLoadingMore: true);

    final paginatedResult = await _executePaginatedQuery(pagination, filterState);

    state = state.copyWith(
      transactions: [...state.transactions, ...paginatedResult.data],
      currentPage: paginatedResult.currentPage,
      totalItems: paginatedResult.totalItems,
      totalPages: paginatedResult.totalPages,
      hasNextPage: paginatedResult.hasNextPage,
      isLoadingMore: false,
    );
  }

  /// Refresh data (reset to first page)
  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// Set filter dan reload data (reset to first page)
  void setFilters(TransactionFilterState filters) {
    final filterNotifier = ref.read(transactionFilterNotifierProvider.notifier);
    filterNotifier.setFilters(
      startDate: filters.startDate,
      endDate: filters.endDate,
      categoryId: filters.categoryId,
      type: filters.type,
    );
    // Auto-reload happens via watch in build()
    ref.invalidateSelf();
  }

  /// Clear semua filter
  void clearFilters() {
    ref.read(transactionFilterNotifierProvider.notifier).clearFilters();
    // Auto-reload happens via watch in build()
    ref.invalidateSelf();
  }

  /// Get current filter state
  TransactionFilterState get filterState => ref.read(transactionFilterNotifierProvider);
}
