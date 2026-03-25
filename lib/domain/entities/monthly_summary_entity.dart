import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_summary_entity.freezed.dart';

/// Entity untuk ringkasan bulanan transaksi
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
  double get expensePercentage {
    if (totalIncome == 0) return 0;
    return (totalExpense / totalIncome * 100);
  }

  /// Hitung persentase saldo terhadap pemasukan
  double get balancePercentage {
    if (totalIncome == 0) return 0;
    return (balance / totalIncome * 100);
  }

  /// Cek apakah bulan ini sehat (saldo > 20% dari pemasukan)
  bool get isHealthy => balance > 0 && balancePercentage >= 20;

  /// Cek apakah ada imbalance (pengeluaran > pemasukan)
  bool get isImbalance => balance < 0;
}

/// Entity untuk breakdown kategori transaksi
@freezed
abstract class CategoryBreakdownEntity with _$CategoryBreakdownEntity {
  const CategoryBreakdownEntity._();

  const factory CategoryBreakdownEntity({
    /// Category ID
    required int categoryId,

    /// Category name
    required String categoryName,

    /// Category icon
    required String categoryIcon,

    /// Category color (hex code)
    required String categoryColor,

    /// Total amount for this category
    required double totalAmount,

    /// Percentage of total expense/income
    required double percentage,

    /// Number of transactions in this category
    required int transactionCount,
  }) = _CategoryBreakdownEntity;

  /// Cek apakah kategori ini berlebihan (> 40% dari total)
  bool get isExcessive => percentage > 40;

  /// Format persentase untuk display
  String get percentageDisplay => '${percentage.toStringAsFixed(1)}%';

  /// Rata-rata pengeluaran per transaksi untuk kategori ini
  double get averagePerTransaction {
    if (transactionCount == 0) return 0;
    return totalAmount / transactionCount;
  }
}

/// Entity untuk rekomendasi keuangan
@freezed
abstract class RecommendationEntity with _$RecommendationEntity {
  const RecommendationEntity._();

  const factory RecommendationEntity({
    /// Type of recommendation
    required RecommendationType type,

    /// Recommendation title
    required String title,

    /// Detailed recommendation message
    required String message,

    /// Related value (e.g., percentage)
    double? value,

    /// Priority level
    required RecommendationPriority priority,
  }) = _RecommendationEntity;
}

/// Enum untuk tipe rekomendasi
enum RecommendationType {
  excessiveSpending('excessive_spending'),
  potentialSavings('potential_savings'),
  imbalance('imbalance'),
  healthy('healthy'),
  motivational('motivational');

  const RecommendationType(this.value);

  final String value;

  /// Get enum dari string value
  static RecommendationType fromString(String value) {
    return RecommendationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => RecommendationType.healthy,
    );
  }

  /// Get display name dalam Bahasa Indonesia
  String get displayName {
    switch (this) {
      case RecommendationType.excessiveSpending:
        return 'Pengeluaran Berlebih';
      case RecommendationType.potentialSavings:
        return 'Potensi Tabungan';
      case RecommendationType.imbalance:
        return 'Ketidakseimbangan';
      case RecommendationType.healthy:
        return 'Keuangan Sehat';
      case RecommendationType.motivational:
        return 'Motivasi';
    }
  }

  /// Get icon untuk tipe rekomendasi
  String get icon {
    switch (this) {
      case RecommendationType.excessiveSpending:
        return '⚠️';
      case RecommendationType.potentialSavings:
        return '💰';
      case RecommendationType.imbalance:
        return '📉';
      case RecommendationType.healthy:
        return '✅';
      case RecommendationType.motivational:
        return '💡';
    }
  }
}

/// Enum untuk prioritas rekomendasi
enum RecommendationPriority {
  high('high'),
  medium('medium'),
  low('low');

  const RecommendationPriority(this.value);

  final String value;

  /// Get enum dari string value
  static RecommendationPriority fromString(String value) {
    return RecommendationPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => RecommendationPriority.low,
    );
  }

  /// Get display name dalam Bahasa Indonesia
  String get displayName {
    switch (this) {
      case RecommendationPriority.high:
        return 'Tinggi';
      case RecommendationPriority.medium:
        return 'Sedang';
      case RecommendationPriority.low:
        return 'Rendah';
    }
  }

  /// Get nilai untuk sorting (higher = more important)
  int get sortValue {
    switch (this) {
      case RecommendationPriority.high:
        return 3;
      case RecommendationPriority.medium:
        return 2;
      case RecommendationPriority.low:
        return 1;
    }
  }

  /// Get color untuk prioritas
  String get colorValue {
    switch (this) {
      case RecommendationPriority.high:
        return '#EF4444'; // Red
      case RecommendationPriority.medium:
        return '#F59E0B'; // Orange
      case RecommendationPriority.low:
        return '#10B981'; // Green
    }
  }
}
