import 'package:catat_cuan/domain/entities/category_breakdown_entity.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/services/insight/insight_configuration_service.dart';

/// Rule Engine untuk mengevaluasi kondisi keuangan dan menghasilkan insight decisions
///
/// Following SRP: Hanya bertanggung jawab untuk mengevaluasi aturan bisnis
/// Tidak bertanggung jawab untuk formatting atau UI presentation
class InsightRuleEngine {
  /// Mengecek apakah pengguna adalah pengguna baru (transaksi sedikit)
  ///
  /// - [transactionCount]: Jumlah transaksi
  /// - [minTransactionCount]: Threshold minimum transaksi (default dari config)
  ///
  /// Mengembalikan true jika transaksi < minimum
  static bool isNewUser(int transactionCount, {int? minTransactionCount}) {
    final threshold = minTransactionCount ?? InsightConfigurationService.minTransactionCount;
    return transactionCount < threshold;
  }

  /// Mengecek apakah terjadi imbalance (pengeluaran > pemasukan)
  ///
  /// - [summary]: Ringkasan bulanan
  ///
  /// Mengembalikan true jika saldo negatif
  static bool hasImbalance(MonthlySummaryEntity summary) {
    return summary.isImbalance;
  }

  /// Mengecek apakah ada kategori yang berlebihan
  ///
  /// - [breakdown]: List breakdown kategori
  /// - [threshold]: Threshold persentase (default dari config)
  ///
  /// Mengembalikan list kategori yang melewati threshold
  static List<CategoryBreakdownEntity> checkExcessiveCategories(
    List<CategoryBreakdownEntity> breakdown, {
    double? threshold,
  }) {
    final thresholdValue = threshold ?? InsightConfigurationService.excessiveCategoryThreshold;
    return breakdown.where((c) => c.percentage > thresholdValue).toList();
  }

  /// Mengecek apakah keuangan sehat
  ///
  /// - [summary]: Ringkasan bulanan
  /// - [hasExcessiveCategories]: Apakah ada kategori berlebihan
  ///
  /// Mengembalikan true jika saldo > 20% dan tidak ada kategori berlebihan
  static bool isHealthyFinance(
    MonthlySummaryEntity summary, {
    bool hasExcessiveCategories = false,
  }) {
    return summary.isHealthy && !hasExcessiveCategories && !summary.isImbalance;
  }

  /// Mengecek potensi menabung
  ///
  /// - [summary]: Ringkasan bulanan
  /// - [threshold]: Threshold persentase (default dari config)
  ///
  /// Mengembalikan persentase potensi menabung, atau null jika tidak ada potensi
  static double? checkSavingsPotential(
    MonthlySummaryEntity summary, {
    double? threshold,
  }) {
    final thresholdValue = threshold ?? InsightConfigurationService.savingsPotentialThreshold;

    if (summary.totalIncome <= 0 || summary.balance <= 0) {
      return null;
    }

    final expensePercentage = (summary.totalExpense / summary.totalIncome * 100);
    final savingsPercentage = 100 - expensePercentage;

    if (expensePercentage < (100 - thresholdValue)) {
      return savingsPercentage;
    }

    return null;
  }

  /// Menghitung rasio pengeluaran terhadap pemasukan
  ///
  /// - [summary]: Ringkasan bulanan
  ///
  /// Mengembalikan persentase pengeluaran (0-100), atau 0 jika tidak ada pemasukan
  static double calculateExpenseRatio(MonthlySummaryEntity summary) {
    if (summary.totalIncome <= 0) {
      return 0.0;
    }
    return (summary.totalExpense / summary.totalIncome * 100);
  }

  /// Mendapatkan insight level berdasarkan rasio pengeluaran
  ///
  /// - [expenseRatio]: Persentase pengeluaran (0-100)
  ///
  /// Mengembalikan kategori insight level
  static ExpenseLevel getExpenseLevel(double expenseRatio) {
    if (expenseRatio >= InsightConfigurationService.nearEmptyThreshold) {
      return ExpenseLevel.nearEmpty;
    } else if (expenseRatio >= InsightConfigurationService.highExpenseThreshold) {
      return ExpenseLevel.high;
    } else if (expenseRatio >= 50) {
      return ExpenseLevel.moderate;
    } else {
      return ExpenseLevel.low;
    }
  }
}

/// Kategori level pengeluaran
enum ExpenseLevel {
  /// Pengeluaran > 90% dari pemasukan
  nearEmpty,

  /// Pengeluaran > 70% dari pemasukan
  high,

  /// Pengeluaran > 50% dari pemasukan
  moderate,

  /// Pengeluaran < 50% dari pemasukan
  low,
}
