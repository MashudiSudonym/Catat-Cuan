import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/domain/entities/category_breakdown_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_breakdown_model.freezed.dart';

/// Model untuk mapping breakdown kategori dari database query
@freezed
abstract class CategoryBreakdownModel with _$CategoryBreakdownModel {
  const CategoryBreakdownModel._();

  const factory CategoryBreakdownModel({
    /// Category ID
    required int categoryId,

    /// Category name
    required String categoryName,

    /// Category icon (optional)
    String? categoryIcon,

    /// Category color (hex code)
    required String categoryColor,

    /// Total amount for this category
    required double totalAmount,

    /// Number of transactions in this category
    required int transactionCount,
  }) = _CategoryBreakdownModel;

  /// Convert dari Map (database row) ke CategoryBreakdownModel
  factory CategoryBreakdownModel.fromMap(Map<String, dynamic> map) {
    return CategoryBreakdownModel(
      categoryId: map['id'] as int? ?? map[CategoryFields.id] as int? ?? 0,
      categoryName: map['name']?.toString() ?? map[CategoryFields.name]?.toString() ?? 'Kategori Tanpa Nama',
      categoryIcon: map['icon']?.toString() ?? map[CategoryFields.icon]?.toString(),
      categoryColor: map['color']?.toString() ?? map[CategoryFields.color]?.toString() ?? '#6B7280',
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      transactionCount: map['transaction_count'] as int? ?? 0,
    );
  }

  /// Convert dari CategoryBreakdownModel ke CategoryBreakdownEntity
  /// dengan menghitung persentase berdasarkan total amount
  CategoryBreakdownEntity toEntity(double totalAmount) {
    final percentage = totalAmount > 0
        ? (this.totalAmount / totalAmount * 100)
        : 0.0;

    return CategoryBreakdownEntity(
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon ?? '📦',
      categoryColor: categoryColor,
      totalAmount: this.totalAmount,
      percentage: percentage,
      transactionCount: transactionCount,
    );
  }
}
