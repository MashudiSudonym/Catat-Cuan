import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_entity.freezed.dart';

/// Entity representing a transaction category
@freezed
abstract class CategoryEntity with _$CategoryEntity {
  const CategoryEntity._();

  const factory CategoryEntity({
    /// Primary key from database (nullable for new category)
    int? id,

    /// Category name
    required String name,

    /// Category type (income/expense)
    required CategoryType type,

    /// Category color (hex code)
    required String color,

    /// Category icon (optional)
    String? icon,

    /// Sort order
    @Default(0) int sortOrder,

    /// Active/inactive status
    @Default(true) bool isActive,

    /// Record creation timestamp
    required DateTime createdAt,

    /// Last update timestamp
    required DateTime updatedAt,
  }) = _CategoryEntity;
}

/// Enum for category type
enum CategoryType {
  income('income'),
  expense('expense');

  const CategoryType(this.value);

  final String value;

  /// Get enum from string value
  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CategoryType.expense,
    );
  }

  /// Get display name in Indonesian
  String get displayName {
    switch (this) {
      case CategoryType.income:
        return 'Pemasukan';
      case CategoryType.expense:
        return 'Pengeluaran';
    }
  }
}
