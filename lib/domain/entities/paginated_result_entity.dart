/// Wrapper for paginated data with metadata
class PaginatedResultEntity<T> {
  /// Data items for the current page
  final List<T> data;

  /// Current page number (1-based)
  final int currentPage;

  /// Number of items per page
  final int itemsPerPage;

  /// Total number of items across all pages
  final int totalItems;

  /// Total number of pages
  final int totalPages;

  /// Whether there is a next page
  final bool hasNextPage;

  /// Whether there is a previous page
  final bool hasPreviousPage;

  const PaginatedResultEntity({
    required this.data,
    required this.currentPage,
    required this.itemsPerPage,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  /// Factory constructor to create PaginatedResultEntity from raw data
  factory PaginatedResultEntity.create({
    required List<T> data,
    required int page,
    required int limit,
    required int totalItems,
  }) {
    final totalPages = (totalItems / limit).ceil();
    return PaginatedResultEntity(
      data: data,
      currentPage: page,
      itemsPerPage: limit,
      totalItems: totalItems,
      totalPages: totalPages,
      hasNextPage: page < totalPages,
      hasPreviousPage: page > 1,
    );
  }

  /// Create empty result
  factory PaginatedResultEntity.empty({
    required int page,
    required int limit,
  }) {
    return PaginatedResultEntity(
      data: const [],
      currentPage: page,
      itemsPerPage: limit,
      totalItems: 0,
      totalPages: 0,
      hasNextPage: false,
      hasPreviousPage: page > 1,
    );
  }

  /// Whether this page is empty
  bool get isDataEmpty => data.isEmpty;

  /// Check if current page is the first page
  bool get isFirstPage => currentPage == 1;

  /// Check if current page is the last page
  bool get isLastPage => currentPage == totalPages || totalPages == 0;
}
