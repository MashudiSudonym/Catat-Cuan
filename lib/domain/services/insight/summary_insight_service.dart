import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/services/insight/insight_rule_engine.dart';

/// Service untuk membuat insight ringkas untuk widget kecil
///
/// Following SRP: Hanya bertanggung jawab untuk membuat insight singkat
/// untuk ditampilkan di widget kecil (bukan list rekomendasi lengkap)
class SummaryInsightService {
  /// Generate insight ringkas untuk ditampilkan di widget kecil
  ///
  /// - [summary]: Ringkasan bulanan
  ///
  /// Mengembalikan string insight singkat yang cocok untuk tampilan ringkas
  static String getSummaryInsight(MonthlySummaryEntity summary) {
    if (summary.transactionCount == 0) {
      return 'Belum ada transaksi bulan ini';
    }

    if (InsightRuleEngine.hasImbalance(summary)) {
      return 'Pengeluaran melebihi pemasukan';
    }

    final expenseRatio = InsightRuleEngine.calculateExpenseRatio(summary);
    final level = InsightRuleEngine.getExpenseLevel(expenseRatio);

    switch (level) {
      case ExpenseLevel.nearEmpty:
        return 'Pengeluaran hampir habis';
      case ExpenseLevel.high:
        return 'Pengeluaran cukup tinggi';
      case ExpenseLevel.moderate:
        return 'Pengeluaran terkendali';
      case ExpenseLevel.low:
        // Cek lagi apakah sehat
        if (summary.isHealthy) {
          return 'Keuangan sehat';
        }
        return 'Pengeluaran terkendali';
    }
  }
}
