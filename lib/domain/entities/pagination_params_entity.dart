/// Pagination parameters for paginated queries
class PaginationParamsEntity {
  /// Current page number (1-based)
  final int page;

  /// Number of items per page
  final int limit;

  const PaginationParamsEntity({
    this.page = 1,
    this.limit = 20,
  });

  /// Calculate offset for SQL queries
  /// OFFSET = (page - 1) * limit
  int get offset => (page - 1) * limit;

  /// Create params for the next page
  PaginationParamsEntity nextPage() => PaginationParamsEntity(
        page: page + 1,
        limit: limit,
      );

  /// Create params for the previous page
  PaginationParamsEntity previousPage() => PaginationParamsEntity(
        page: page > 1 ? page - 1 : 1,
        limit: limit,
      );

  /// Reset to first page
  PaginationParamsEntity reset() => PaginationParamsEntity(
        page: 1,
        limit: limit,
      );
}
