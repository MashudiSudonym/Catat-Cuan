/// Analyzer service untuk mengevaluasi kesehatan finansial bulanan
///
/// Service ini bertanggung jawab untuk menganalisis ringkasan bulanan
/// dan memberikan insight tentang kesehatan finansial.
class FinancialHealthAnalyzer {
  /// Threshold untuk persentase saldo yang dianggap sehat
  static const double healthyBalanceThreshold = 20.0;

  /// Hitung persentase pengeluaran terhadap pemasukan
  ///
  /// Mengembalikan 0 jika totalIncome adalah 0 untuk menghindari division by zero.
  static double calculateExpensePercentage({
    required double totalExpense,
    required double totalIncome,
  }) {
    if (totalIncome == 0) return 0;
    return (totalExpense / totalIncome * 100);
  }

  /// Hitung persentase saldo terhadap pemasukan
  ///
  /// Mengembalikan 0 jika totalIncome adalah 0 untuk menghindari division by zero.
  static double calculateBalancePercentage({
    required double balance,
    required double totalIncome,
  }) {
    if (totalIncome == 0) return 0;
    return (balance / totalIncome * 100);
  }

  /// Cek apakah keuangan bulanan sehat
  ///
  /// Kriteria: saldo positif dan >= 20% dari pemasukan
  static bool isHealthyFinancial({
    required double balance,
    required double totalIncome,
  }) {
    if (balance <= 0) return false;
    final balancePercent = calculateBalancePercentage(
      balance: balance,
      totalIncome: totalIncome,
    );
    return balancePercent >= healthyBalanceThreshold;
  }

  /// Cek apakah ada imbalance (pengeluaran > pemasukan)
  static bool hasImbalance({
    required double balance,
  }) {
    return balance < 0;
  }

  /// Get threshold untuk persentase saldo sehat
  static double get healthyThreshold => healthyBalanceThreshold;
}
