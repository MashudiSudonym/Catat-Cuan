import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated_result_entity.freezed.dart';

/// Wrapper for paginated data with metadata
@freezed
abstract class PaginatedResultEntity<T> with _$PaginatedResultEntity<T> {
  const PaginatedResultEntity._();

  const factory PaginatedResultEntity({
    /// Data items for the current page
    required List<T> data,

    /// Current page number (1-based)
    required int currentPage,

    /// Number of items per page
    required int itemsPerPage,

    /// Total number of items across all pages
    required int totalItems,

    /// Total number of pages
    required int totalPages,

    /// Whether there is a next page
    required bool hasNextPage,

    /// Whether there is a previous page
    required bool hasPreviousPage,
  }) = _PaginatedResultEntity;

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
