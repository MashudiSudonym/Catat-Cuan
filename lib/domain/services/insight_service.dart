import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/services/insight/insight_configuration_service.dart';
import 'package:catat_cuan/domain/services/insight/insight_rule_engine.dart';
import 'package:catat_cuan/domain/services/insight/recommendation_formatter_service.dart';
import 'package:catat_cuan/domain/services/insight/summary_insight_service.dart';

/// Service untuk generate insight dan rekomendasi keuangan
///
/// Refactored to follow SRP: This service now acts as a facade/orchestrator
/// that coordinates focused services:
/// - InsightConfigurationService: Manages thresholds and messages
/// - InsightRuleEngine: Evaluates financial rules
/// - RecommendationFormatterService: Formats recommendations
/// - SummaryInsightService: Creates summary insights
///
/// Each responsibility is now handled by a dedicated service.
class InsightService {
  /// Generate rekomendasi berdasarkan ringkasan bulanan dan breakdown kategori
  /// Akan selalu menampilkan rekomendasi (finansial jika cukup data, motivasi jika kurang)
  List<RecommendationEntity> generateInsights(
    MonthlySummaryEntity summary,
    List<CategoryBreakdownEntity> breakdown,
  ) {
    // Jika transaksi kurang dari minimum, tampilkan pesan motivasi
    if (InsightRuleEngine.isNewUser(summary.transactionCount)) {
      final message = InsightConfigurationService.getMotivationalMessage(summary.transactionCount);
      final recommendation = RecommendationFormatterService.createMotivationalRecommendation(message);
      return [recommendation];
    }

    final recommendations = <RecommendationEntity>[];

    // Rule 1: Imbalance - Pengeluaran melebihi pemasukan (HIGH PRIORITY)
    if (InsightRuleEngine.hasImbalance(summary)) {
      recommendations.add(RecommendationFormatterService.createImbalanceRecommendation(summary));
    }

    // Rule 2: Excessive Spending - Kategori > threshold dari total pengeluaran (MEDIUM PRIORITY)
    final excessiveCategories = InsightRuleEngine.checkExcessiveCategories(breakdown);
    if (excessiveCategories.isNotEmpty) {
      // Hanya ambil satu kategori yang berlebihan
      recommendations.add(
        RecommendationFormatterService.createExcessiveSpendingRecommendation(excessiveCategories.first),
      );
    }

    // Rule 3: Potential Savings - Pengeluaran < threshold dari pemasukan (LOW PRIORITY)
    final savingsPotential = InsightRuleEngine.checkSavingsPotential(summary);
    if (savingsPotential != null) {
      recommendations.add(
        RecommendationFormatterService.createSavingsRecommendation(savingsPotential),
      );
    }

    // Rule 4: Healthy - Saldo > threshold dari pemasukan dan tidak ada kategori berlebihan (LOW PRIORITY)
    if (InsightRuleEngine.isHealthyFinance(
      summary,
      hasExcessiveCategories: excessiveCategories.isNotEmpty,
    )) {
      recommendations.add(
        RecommendationFormatterService.createHealthyFinanceRecommendation(summary),
      );
    }

    // Sort by priority (high > medium > low) dan ambil maksimal 3
    final sorted = RecommendationFormatterService.sortByPriority(recommendations);
    return RecommendationFormatterService.limit(sorted, 3);
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
      if (category.percentage > InsightConfigurationService.topCategoryThreshold) {
        recommendations.add(
          RecommendationFormatterService.createTopCategoryRecommendation(category),
        );
      }
    }

    return recommendations;
  }

  /// Generate insight ringkas untuk ditampilkan di widget kecil
  ///
  /// Delegates to SummaryInsightService
  String getSummaryInsight(MonthlySummaryEntity summary) {
    return SummaryInsightService.getSummaryInsight(summary);
  }
}
