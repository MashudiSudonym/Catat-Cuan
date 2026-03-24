/// Entity untuk ringkasan bulanan transaksi
class MonthlySummaryEntity {
  final String yearMonth; // Format: "2024-03"
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int transactionCount;
  final DateTime createdAt;

  const MonthlySummaryEntity({
    required this.yearMonth,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
    required this.createdAt,
  });

  /// CopyWith method untuk immutable updates
  MonthlySummaryEntity copyWith({
    String? yearMonth,
    double? totalIncome,
    double? totalExpense,
    double? balance,
    int? transactionCount,
    DateTime? createdAt,
  }) {
    return MonthlySummaryEntity(
      yearMonth: yearMonth ?? this.yearMonth,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      balance: balance ?? this.balance,
      transactionCount: transactionCount ?? this.transactionCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlySummaryEntity &&
          runtimeType == other.runtimeType &&
          yearMonth == other.yearMonth &&
          totalIncome == other.totalIncome &&
          totalExpense == other.totalExpense &&
          balance == other.balance &&
          transactionCount == other.transactionCount &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      yearMonth.hashCode ^
      totalIncome.hashCode ^
      totalExpense.hashCode ^
      balance.hashCode ^
      transactionCount.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'MonthlySummaryEntity{yearMonth: $yearMonth, totalIncome: $totalIncome, totalExpense: $totalExpense, balance: $balance, transactionCount: $transactionCount, createdAt: $createdAt}';
  }

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
class CategoryBreakdownEntity {
  final int categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final double totalAmount;
  final double percentage; // Persentase dari total expense/income
  final int transactionCount;

  const CategoryBreakdownEntity({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.totalAmount,
    required this.percentage,
    required this.transactionCount,
  });

  /// CopyWith method untuk immutable updates
  CategoryBreakdownEntity copyWith({
    int? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    double? totalAmount,
    double? percentage,
    int? transactionCount,
  }) {
    return CategoryBreakdownEntity(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      totalAmount: totalAmount ?? this.totalAmount,
      percentage: percentage ?? this.percentage,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryBreakdownEntity &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          categoryName == other.categoryName &&
          categoryIcon == other.categoryIcon &&
          categoryColor == other.categoryColor &&
          totalAmount == other.totalAmount &&
          percentage == other.percentage &&
          transactionCount == other.transactionCount;

  @override
  int get hashCode =>
      categoryId.hashCode ^
      categoryName.hashCode ^
      categoryIcon.hashCode ^
      categoryColor.hashCode ^
      totalAmount.hashCode ^
      percentage.hashCode ^
      transactionCount.hashCode;

  @override
  String toString() {
    return 'CategoryBreakdownEntity{categoryId: $categoryId, categoryName: $categoryName, categoryIcon: $categoryIcon, categoryColor: $categoryColor, totalAmount: $totalAmount, percentage: $percentage, transactionCount: $transactionCount}';
  }

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
class RecommendationEntity {
  final RecommendationType type;
  final String title;
  final String message;
  final double? value; // Nilai terkait (misalnya persentase)
  final RecommendationPriority priority;

  const RecommendationEntity({
    required this.type,
    required this.title,
    required this.message,
    this.value,
    required this.priority,
  });

  /// CopyWith method untuk immutable updates
  RecommendationEntity copyWith({
    RecommendationType? type,
    String? title,
    String? message,
    double? value,
    RecommendationPriority? priority,
  }) {
    return RecommendationEntity(
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      value: value ?? this.value,
      priority: priority ?? this.priority,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendationEntity &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          title == other.title &&
          message == other.message &&
          value == other.value &&
          priority == other.priority;

  @override
  int get hashCode =>
      type.hashCode ^
      title.hashCode ^
      message.hashCode ^
      value.hashCode ^
      priority.hashCode;

  @override
  String toString() {
    return 'RecommendationEntity{type: $type, title: $title, message: $message, value: $value, priority: $priority}';
  }
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
