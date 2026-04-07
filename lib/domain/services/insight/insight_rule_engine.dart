import 'package:catat_cuan/domain/entities/category_breakdown_entity.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/services/insight/insight_configuration_service.dart';

/// Rule Engine for evaluating financial conditions and generating insight decisions
///
/// Following SRP: Only responsible for evaluating business rules
/// Not responsible for formatting or UI presentation
class InsightRuleEngine {
  /// Check if user is a new user (few transactions)
  ///
  /// - [transactionCount]: Number of transactions
  /// - [minTransactionCount]: Minimum transaction threshold (default from config)
  ///
  /// Returns true if transactions < minimum
  static bool isNewUser(int transactionCount, {int? minTransactionCount}) {
    final threshold = minTransactionCount ?? InsightConfigurationService.minTransactionCount;
    return transactionCount < threshold;
  }

  /// Check if there's an imbalance (expense > income)
  ///
  /// - [summary]: Monthly summary
  ///
  /// Returns true if balance is negative
  static bool hasImbalance(MonthlySummaryEntity summary) {
    return summary.isImbalance;
  }

  /// Check if there are excessive categories
  ///
  /// - [breakdown]: List of category breakdowns
  /// - [threshold]: Percentage threshold (default from config)
  ///
  /// Returns list of categories that exceed threshold
  static List<CategoryBreakdownEntity> checkExcessiveCategories(
    List<CategoryBreakdownEntity> breakdown, {
    double? threshold,
  }) {
    final thresholdValue = threshold ?? InsightConfigurationService.excessiveCategoryThreshold;
    return breakdown.where((c) => c.percentage > thresholdValue).toList();
  }

  /// Check if finances are healthy
  ///
  /// - [summary]: Monthly summary
  /// - [hasExcessiveCategories]: Whether there are excessive categories
  ///
  /// Returns true if balance > 20% and no excessive categories
  static bool isHealthyFinance(
    MonthlySummaryEntity summary, {
    bool hasExcessiveCategories = false,
  }) {
    return summary.isHealthy && !hasExcessiveCategories && !summary.isImbalance;
  }

  /// Check savings potential
  ///
  /// - [summary]: Monthly summary
  /// - [threshold]: Percentage threshold (default from config)
  ///
  /// Returns savings potential percentage, or null if no potential
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

  /// Calculate expense ratio against income
  ///
  /// - [summary]: Monthly summary
  ///
  /// Returns expense percentage (0-100), or 0 if no income
  static double calculateExpenseRatio(MonthlySummaryEntity summary) {
    if (summary.totalIncome <= 0) {
      return 0.0;
    }
    return (summary.totalExpense / summary.totalIncome * 100);
  }

  /// Get insight level based on expense ratio
  ///
  /// - [expenseRatio]: Expense percentage (0-100)
  ///
  /// Returns insight level category
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

/// Expense level category
enum ExpenseLevel {
  /// Expense > 90% of income
  nearEmpty,

  /// Expense > 70% of income
  high,

  /// Expense > 50% of income
  moderate,

  /// Expense < 50% of income
  low,
}
