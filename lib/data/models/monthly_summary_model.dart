import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_summary_model.freezed.dart';

/// Model untuk mapping ringkasan bulanan dari database query
@freezed
abstract class MonthlySummaryModel with _$MonthlySummaryModel {
  const MonthlySummaryModel._();

  const factory MonthlySummaryModel({
    /// Year month in format "2024-03"
    required String yearMonth,

    /// Total income for the month
    required double totalIncome,

    /// Total expense for the month
    required double totalExpense,

    /// Balance (income - expense)
    required double balance,

    /// Number of transactions
    required int transactionCount,
  }) = _MonthlySummaryModel;

  /// Convert dari Map (database row) ke MonthlySummaryModel
  factory MonthlySummaryModel.fromMap(Map<String, dynamic> map) {
    return MonthlySummaryModel(
      yearMonth: map['year_month']?.toString() ?? '',
      totalIncome: (map['total_income'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (map['total_expense'] as num?)?.toDouble() ?? 0.0,
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      transactionCount: map['transaction_count'] as int? ?? 0,
    );
  }

  /// Convert dari MonthlySummaryModel ke MonthlySummaryEntity
  MonthlySummaryEntity toEntity() {
    return MonthlySummaryEntity(
      yearMonth: yearMonth,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: balance,
      transactionCount: transactionCount,
      createdAt: DateTime.now(),
    );
  }
}

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
