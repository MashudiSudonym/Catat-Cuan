import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';

/// Model untuk mapping ringkasan bulanan dari database query
class MonthlySummaryModel {
  final String yearMonth;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int transactionCount;

  const MonthlySummaryModel({
    required this.yearMonth,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
  });

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

  @override
  String toString() {
    return 'MonthlySummaryModel{yearMonth: $yearMonth, totalIncome: $totalIncome, totalExpense: $totalExpense, balance: $balance, transactionCount: $transactionCount}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlySummaryModel &&
          runtimeType == other.runtimeType &&
          yearMonth == other.yearMonth &&
          totalIncome == other.totalIncome &&
          totalExpense == other.totalExpense &&
          balance == other.balance &&
          transactionCount == other.transactionCount;

  @override
  int get hashCode =>
      yearMonth.hashCode ^
      totalIncome.hashCode ^
      totalExpense.hashCode ^
      balance.hashCode ^
      transactionCount.hashCode;
}

/// Model untuk mapping breakdown kategori dari database query
class CategoryBreakdownModel {
  final int categoryId;
  final String categoryName;
  final String? categoryIcon;
  final String categoryColor;
  final double totalAmount;
  final int transactionCount;

  const CategoryBreakdownModel({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.totalAmount,
    required this.transactionCount,
  });

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

  @override
  String toString() {
    return 'CategoryBreakdownModel{categoryId: $categoryId, categoryName: $categoryName, categoryIcon: $categoryIcon, categoryColor: $categoryColor, totalAmount: $totalAmount, transactionCount: $transactionCount}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryBreakdownModel &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          categoryName == other.categoryName &&
          categoryIcon == other.categoryIcon &&
          categoryColor == other.categoryColor &&
          totalAmount == other.totalAmount &&
          transactionCount == other.transactionCount;

  @override
  int get hashCode =>
      categoryId.hashCode ^
      categoryName.hashCode ^
      categoryIcon.hashCode ^
      categoryColor.hashCode ^
      totalAmount.hashCode ^
      transactionCount.hashCode;
}
