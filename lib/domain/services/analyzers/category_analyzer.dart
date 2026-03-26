/// Analyzer service untuk menganalisis breakdown kategori transaksi
///
/// Service ini bertanggung jawab untuk menganalisis kategori transaksi
/// dan memberikan insight tentang pola pengeluaran.
class CategoryAnalyzer {
  /// Threshold default untuk kategori berlebihan
  static const double excessiveCategoryThreshold = 40.0;

  /// Cek apakah kategori ini berlebihan
  ///
  /// Kategori dianggap berlebihan jika persentasenya melebihi threshold.
  static bool isExcessiveCategory({
    required double percentage,
    double? threshold,
  }) {
    final effectiveThreshold = threshold ?? excessiveCategoryThreshold;
    return percentage > effectiveThreshold;
  }

  /// Hitung rata-rata pengeluaran per transaksi
  ///
  /// Mengembalikan 0 jika transactionCount adalah 0 untuk menghindari division by zero.
  static double calculateAveragePerTransaction({
    required double totalAmount,
    required int transactionCount,
  }) {
    if (transactionCount == 0) return 0;
    return totalAmount / transactionCount;
  }

  /// Format persentase untuk display
  ///
  /// Mengembalikan string dengan format "X.X%".
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Get threshold default untuk kategori berlebihan
  static double get excessiveThreshold => excessiveCategoryThreshold;
}
