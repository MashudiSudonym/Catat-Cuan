import 'package:catat_cuan/domain/services/analyzers/category_analyzer.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_breakdown_entity.freezed.dart';

/// Entity untuk breakdown kategori transaksi
///
/// Derived properties menggunakan [CategoryAnalyzer] untuk analisis.
/// Ini memisahkan logic bisnis dari entity sambil mempertahankan API yang nyaman.
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
  ///
  /// Delegates to [CategoryAnalyzer.isExcessiveCategory].
  bool get isExcessive => CategoryAnalyzer.isExcessiveCategory(
        percentage: percentage,
      );

  /// Format persentase untuk display
  ///
  /// Delegates to [CategoryAnalyzer.formatPercentage].
  String get percentageDisplay => CategoryAnalyzer.formatPercentage(percentage);

  /// Rata-rata pengeluaran per transaksi untuk kategori ini
  ///
  /// Delegates to [CategoryAnalyzer.calculateAveragePerTransaction].
  double get averagePerTransaction => CategoryAnalyzer.calculateAveragePerTransaction(
        totalAmount: totalAmount,
        transactionCount: transactionCount,
      );
}
