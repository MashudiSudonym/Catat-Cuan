import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/presentation/utils/currency_formatter.dart';

/// Service untuk generate insight dan rekomendasi keuangan
/// berdasarkan data transaksi bulanan
class InsightService {
  /// Motivational messages for Indonesian users about economics/finance
  static const List<Map<String, String>> _motivationalMessages = [
    {
      'title': 'Mulai Perjalanan Finansial Anda',
      'message':
          'Setiap perjalanan dimulai dengan satu langkah. Catat transaksi pertama Anda dan bangun kebiasaan finansial yang sehat.',
    },
    {
      'title': 'Konsistensi adalah Kunci',
      'message':
          'Konsistensi dalam mencatat pengeluaran adalah langkah awal menuju kebebasan finansial. Teruslah mencatat!',
    },
    {
      'title': 'Setiap Rupiah Berharga',
      'message':
          'Memahami kemana uang Anda pergi adalah langkah pertama untuk mencapai tujuan finansial Anda.',
    },
    {
      'title': 'Bangun Kebiasaan Finansial',
      'message':
          'Kebiasaan kecil seperti mencatat pengeluaran dapat memberikan dampak besar pada kesehatan finansial Anda jangka panjang.',
    },
    {
      'title': 'Waktu untuk Mulai',
      'message':
          'Tidak ada waktu yang lebih baik dari sekarang untuk mulai mengelola keuangan Anda. Setiap transaksi tercatat membawa Anda lebih dekat ke tujuan.',
    },
  ];
  /// Minimal jumlah transaksi sebelum menampilkan rekomendasi finansial
  /// Di bawah jumlah ini akan menampilkan pesan motivasi
  static const int minTransactionCount = 5;

  /// Batas persentase kategori yang dianggap berlebihan
  static const double excessiveCategoryThreshold = 40.0;

  /// Batas persentase untuk dianggap berpotensi menabung
  static const double savingsPotentialThreshold = 20.0;

  /// Batas persentase saldo untuk dianggap sehat
  static const double healthyBalanceThreshold = 20.0;

  /// Generate rekomendasi berdasarkan ringkasan bulanan dan breakdown kategori
  /// Akan selalu menampilkan rekomendasi (finansial jika cukup data, motivasi jika kurang)
  List<RecommendationEntity> generateInsights(
    MonthlySummaryEntity summary,
    List<CategoryBreakdownEntity> breakdown,
  ) {
    // Jika transaksi kurang dari minimum, tampilkan pesan motivasi
    if (summary.transactionCount < minTransactionCount) {
      return _getMotivationalInsights(summary.transactionCount);
    }

    final recommendations = <RecommendationEntity>[];

    // Rule 1: Imbalance - Pengeluaran melebihi pemasukan (HIGH PRIORITY)
    if (summary.isImbalance) {
      recommendations.add(RecommendationEntity(
        type: RecommendationType.imbalance,
        title: 'Perhatian: Pengeluaran Melebihi Pemasukan',
        message: 'Deficit sebesar ${CurrencyInputFormatter.formatRupiahFromDouble(summary.balance.abs())}. '
            'Pertimbangkan untuk mengurangi pengeluaran atau mencari sumber pemasukan tambahan.',
        value: summary.balancePercentage.abs(),
        priority: RecommendationPriority.high,
      ));
    }

    // Rule 2: Excessive Spending - Kategori > 40% dari total pengeluaran (MEDIUM PRIORITY)
    for (final category in breakdown) {
      if (category.isExcessive) {
        recommendations.add(RecommendationEntity(
          type: RecommendationType.excessiveSpending,
          title: 'Pengeluaran ${category.categoryName} Tinggi',
          message: '${category.categoryName} mencapai ${category.percentageDisplay} '
              'dari total pengeluaran bulan ini (${CurrencyInputFormatter.formatRupiahFromDouble(category.totalAmount)}). '
              'Pertimbangkan untuk mengurangi pengeluaran kategori ini.',
          value: category.percentage,
          priority: RecommendationPriority.medium,
        ));
        break; // Hanya ambil satu kategori yang berlebihan
      }
    }

    // Rule 3: Potential Savings - Pengeluaran < 80% dari pemasukan (LOW PRIORITY)
    final expensePercentage = summary.totalIncome > 0
        ? (summary.totalExpense / summary.totalIncome * 100)
        : 0.0;

    if (summary.totalIncome > 0 &&
        expensePercentage < (100 - savingsPotentialThreshold) &&
        summary.balance > 0) {
      final savingsPercentage = 100 - expensePercentage;
      recommendations.add(RecommendationEntity(
        type: RecommendationType.potentialSavings,
        title: 'Potensi Menabung',
        message: 'Bagus! Anda berpotensi menabung ${savingsPercentage.toStringAsFixed(1)}% '
            'dari pemasukan bulan ini. '
            'Pertimbangkan untuk mengalokasikan ke tabungan atau investasi.',
        value: savingsPercentage,
        priority: RecommendationPriority.low,
      ));
    }

    // Rule 4: Healthy - Saldo > 20% dari pemasukan dan tidak ada kategori berlebihan (LOW PRIORITY)
    if (summary.isHealthy &&
        !breakdown.any((c) => c.isExcessive) &&
        !summary.isImbalance) {
      recommendations.add(RecommendationEntity(
        type: RecommendationType.healthy,
        title: 'Keuangan Sehat',
        message: 'Kondisi keuangan bulan ini sehat dengan saldo ${CurrencyInputFormatter.formatRupiahFromDouble(summary.balance)} '
            '(${summary.balancePercentage.toStringAsFixed(1)}% dari pemasukan). '
            'Pertahankan pola pengeluaran yang baik ini!',
        value: summary.balancePercentage,
        priority: RecommendationPriority.low,
      ));
    }

    // Sort by priority (high > medium > low) dan ambil maksimal 3
    recommendations.sort((a, b) => b.priority.sortValue.compareTo(a.priority.sortValue));

    return recommendations.take(3).toList();
  }

  /// Generate rekomendasi khusus untuk kategori yang perlu diperhatikan
  List<RecommendationEntity> getCategoryRecommendations(
    List<CategoryBreakdownEntity> breakdown,
    double totalExpense,
  ) {
    if (breakdown.isEmpty || totalExpense == 0) {
      return [];
    }

    final recommendations = <RecommendationEntity>[];

    // Ambil top 3 kategori terbesar
    final topCategories = breakdown.take(3).toList();

    for (final category in topCategories) {
      if (category.percentage > 30) {
        recommendations.add(RecommendationEntity(
          type: RecommendationType.excessiveSpending,
          title: 'Kategori Terbesar: ${category.categoryName}',
          message: 'Menghabiskan ${category.percentageDisplay} dari total pengeluaran',
          value: category.percentage,
          priority: RecommendationPriority.medium,
        ));
      }
    }

    return recommendations;
  }

  /// Generate insight ringkas untuk ditampilkan di widget kecil
  String getSummaryInsight(MonthlySummaryEntity summary) {
    if (summary.transactionCount == 0) {
      return 'Belum ada transaksi bulan ini';
    }

    if (summary.isImbalance) {
      return 'Pengeluaran melebihi pemasukan';
    }

    if (summary.isHealthy) {
      return 'Keuangan sehat';
    }

    final expenseRatio = summary.totalIncome > 0
        ? (summary.totalExpense / summary.totalIncome * 100)
        : 0.0;

    if (expenseRatio > 90) {
      return 'Pengeluaran hampir habis';
    } else if (expenseRatio > 70) {
      return 'Pengeluaran cukup tinggi';
    } else {
      return 'Pengeluaran terkendali';
    }
  }

  /// Get motivational insight for new/low-data users
  List<RecommendationEntity> _getMotivationalInsights(int transactionCount) {
    // Select message based on transaction count
    final messageIndex = transactionCount.clamp(0, _motivationalMessages.length - 1);
    final message = _motivationalMessages[messageIndex];

    return [
      RecommendationEntity(
        type: RecommendationType.motivational,
        title: message['title']!,
        message: message['message']!,
        value: null, // No value for motivational
        priority: RecommendationPriority.low,
      ),
    ];
  }
}
