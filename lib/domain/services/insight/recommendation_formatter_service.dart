import 'package:catat_cuan/domain/entities/category_breakdown_entity.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/entities/recommendation_entity.dart';
import 'package:catat_cuan/domain/services/insight/insight_configuration_service.dart';
import 'package:catat_cuan/presentation/utils/currency_formatter.dart';

/// Service untuk memformat rekomendasi keuangan menjadi entity
///
/// Following SRP: Hanya bertanggung jawab untuk membuat RecommendationEntity
/// berdasarkan hasil evaluasi dari rule engine
class RecommendationFormatterService {
  /// Membuat rekomendasi untuk imbalance (pengeluaran > pemasukan)
  static RecommendationEntity createImbalanceRecommendation(MonthlySummaryEntity summary) {
    return RecommendationEntity(
      type: RecommendationType.imbalance,
      title: 'Perhatian: Pengeluaran Melebihi Pemasukan',
      message: 'Deficit sebesar ${CurrencyInputFormatter.formatRupiahFromDouble(summary.balance.abs())}. '
          'Pertimbangkan untuk mengurangi pengeluaran atau mencari sumber pemasukan tambahan.',
      value: summary.balancePercentage.abs(),
      priority: RecommendationPriority.high,
    );
  }

  /// Membuat rekomendasi untuk pengeluaran kategori berlebihan
  static RecommendationEntity createExcessiveSpendingRecommendation(
    CategoryBreakdownEntity category,
  ) {
    return RecommendationEntity(
      type: RecommendationType.excessiveSpending,
      title: 'Pengeluaran ${category.categoryName} Tinggi',
      message: '${category.categoryName} mencapai ${category.percentageDisplay} '
          'dari total pengeluaran bulan ini (${CurrencyInputFormatter.formatRupiahFromDouble(category.totalAmount)}). '
          'Pertimbangkan untuk mengurangi pengeluaran kategori ini.',
      value: category.percentage,
      priority: RecommendationPriority.medium,
    );
  }

  /// Membuat rekomendasi untuk potensi menabung
  static RecommendationEntity createSavingsRecommendation(double savingsPercentage) {
    return RecommendationEntity(
      type: RecommendationType.potentialSavings,
      title: 'Potensi Menabung',
      message: 'Bagus! Anda berpotensi menabung ${savingsPercentage.toStringAsFixed(1)}% '
          'dari pemasukan bulan ini. '
          'Pertimbangkan untuk mengalokasikan ke tabungan atau investasi.',
      value: savingsPercentage,
      priority: RecommendationPriority.low,
    );
  }

  /// Membuat rekomendasi untuk keuangan sehat
  static RecommendationEntity createHealthyFinanceRecommendation(
    MonthlySummaryEntity summary,
  ) {
    return RecommendationEntity(
      type: RecommendationType.healthy,
      title: 'Keuangan Sehat',
      message: 'Kondisi keuangan bulan ini sehat dengan saldo ${CurrencyInputFormatter.formatRupiahFromDouble(summary.balance)} '
          '(${summary.balancePercentage.toStringAsFixed(1)}% dari pemasukan). '
          'Pertahankan pola pengeluaran yang baik ini!',
      value: summary.balancePercentage,
      priority: RecommendationPriority.low,
    );
  }

  /// Membuat rekomendasi motivasi untuk pengguna baru
  static RecommendationEntity createMotivationalRecommendation(
    InsightMessage message,
  ) {
    return RecommendationEntity(
      type: RecommendationType.motivational,
      title: message.title,
      message: message.message,
      value: null,
      priority: RecommendationPriority.low,
    );
  }

  /// Membuat rekomendasi untuk top kategori
  static RecommendationEntity createTopCategoryRecommendation(
    CategoryBreakdownEntity category,
  ) {
    return RecommendationEntity(
      type: RecommendationType.excessiveSpending,
      title: 'Kategori Terbesar: ${category.categoryName}',
      message: 'Menghabiskan ${category.percentageDisplay} dari total pengeluaran',
      value: category.percentage,
      priority: RecommendationPriority.medium,
    );
  }

  /// Sort recommendations by priority (high > medium > low)
  static List<RecommendationEntity> sortByPriority(List<RecommendationEntity> recommendations) {
    final sorted = List<RecommendationEntity>.from(recommendations);
    sorted.sort((a, b) => b.priority.sortValue.compareTo(a.priority.sortValue));
    return sorted;
  }

  /// Limit recommendations to max count
  static List<RecommendationEntity> limit(List<RecommendationEntity> recommendations, int max) {
    return recommendations.take(max).toList();
  }
}
