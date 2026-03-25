import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_params_entity.freezed.dart';

/// Pagination parameters for paginated queries
@freezed
abstract class PaginationParamsEntity with _$PaginationParamsEntity {
  const PaginationParamsEntity._();

  const factory PaginationParamsEntity({
    /// Current page number (1-based)
    @Default(1) int page,

    /// Number of items per page
    @Default(20) int limit,
  }) = _PaginationParamsEntity;

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
