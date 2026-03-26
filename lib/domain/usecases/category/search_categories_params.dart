import 'package:catat_cuan/domain/entities/category_entity.dart';

/// Parameter untuk pencarian kategori
class SearchCategoriesParams {
  final String query;
  final CategoryType? typeFilter;

  const SearchCategoriesParams({
    required this.query,
    this.typeFilter,
  });
}
