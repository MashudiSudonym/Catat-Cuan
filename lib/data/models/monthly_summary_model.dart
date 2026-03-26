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
