import 'package:catat_cuan/domain/services/analyzers/financial_health_analyzer.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_summary_entity.freezed.dart';

/// Entity untuk ringkasan bulanan transaksi
///
/// Derived properties menggunakan [FinancialHealthAnalyzer] untuk analisis.
/// Ini memisahkan logic bisnis dari entity sambil mempertahankan API yang nyaman.
@freezed
abstract class MonthlySummaryEntity with _$MonthlySummaryEntity {
  const MonthlySummaryEntity._();

  const factory MonthlySummaryEntity({
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

    /// When the summary was created
    required DateTime createdAt,
  }) = _MonthlySummaryEntity;

  /// Hitung persentase pengeluaran terhadap pemasukan
  ///
  /// Delegates to [FinancialHealthAnalyzer.calculateExpensePercentage].
  double get expensePercentage => FinancialHealthAnalyzer.calculateExpensePercentage(
        totalExpense: totalExpense,
        totalIncome: totalIncome,
      );

  /// Hitung persentase saldo terhadap pemasukan
  ///
  /// Delegates to [FinancialHealthAnalyzer.calculateBalancePercentage].
  double get balancePercentage => FinancialHealthAnalyzer.calculateBalancePercentage(
        balance: balance,
        totalIncome: totalIncome,
      );

  /// Cek apakah bulan ini sehat (saldo > 20% dari pemasukan)
  ///
  /// Delegates to [FinancialHealthAnalyzer.isHealthyFinancial].
  bool get isHealthy => FinancialHealthAnalyzer.isHealthyFinancial(
        balance: balance,
        totalIncome: totalIncome,
      );

  /// Cek apakah ada imbalance (pengeluaran > pemasukan)
  ///
  /// Delegates to [FinancialHealthAnalyzer.hasImbalance].
  bool get isImbalance => FinancialHealthAnalyzer.hasImbalance(
        balance: balance,
      );
}
