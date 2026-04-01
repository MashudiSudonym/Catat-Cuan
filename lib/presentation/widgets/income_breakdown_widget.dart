import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/category_breakdown_entity.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';

/// Widget untuk menampilkan breakdown kategori pemasukan dalam bentuk pie chart
class IncomeBreakdownWidget extends ConsumerWidget {
  final List<CategoryBreakdownEntity> breakdown;
  final double totalIncome;

  const IncomeBreakdownWidget({
    super.key,
    required this.breakdown,
    required this.totalIncome,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;

    if (breakdown.isEmpty || totalIncome == 0) {
      final tertiaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.5) : AppColors.textTertiary;
      final secondaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.7) : AppColors.textSecondary;
      return AppGlassContainer.glassCard(
        margin: AppSpacing.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        child: Padding(
          padding: AppSpacing.all(AppSpacing.xxl),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 48,
                  color: tertiaryColor,
                ),
                AppSpacingWidget.verticalMD(),
                Text(
                  'Belum ada data pemasukan',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: secondaryColor,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Ambil top 5 kategori + "Lainnya"
    final topCategories = breakdown.take(5).toList();
    final otherCategories = breakdown.skip(5).toList();

    double otherAmount = otherCategories.fold(0.0, (sum, cat) => sum + cat.totalAmount);
    double chartTotal = totalIncome;

    // Siapkan data untuk chart
    final chartData = <_ChartData>[];
    for (final category in topCategories) {
      chartData.add(_ChartData(
        name: category.categoryName,
        value: category.totalAmount,
        color: _parseColor(category.categoryColor),
        icon: category.categoryIcon,
        percentage: (category.totalAmount / chartTotal * 100),
      ));
    }

    // Tambahkan "Lainnya" jika ada
    if (otherAmount > 0) {
      chartData.add(_ChartData(
        name: 'Lainnya',
        value: otherAmount,
        color: isDark ? AppColors.textOnDark.withValues(alpha: 0.3) : AppColors.textTertiary,
        icon: '📦',
        percentage: (otherAmount / chartTotal * 100),
      ));
    }

    return AppGlassContainer.glassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: AppSpacing.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.income,
                  size: 20,
                ),
                AppSpacingWidget.horizontalSM(),
                Text(
                  'Breakdown Pemasukan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                ),
              ],
            ),
            AppSpacingWidget.verticalLG(),

            // Pie Chart
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  borderData: FlBorderData(show: false),
                  sections: _buildSections(chartData),
                ),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOutCubic,
              ),
            ),

            AppSpacingWidget.verticalLG(),

            // Legend
            _buildLegend(chartData, isDark, ref),

            AppSpacingWidget.verticalSM(),
          ],
        ),
      ),
    );
  }

  /// Build pie chart sections
  List<PieChartSectionData> _buildSections(List<_ChartData> data) {
    return data.map((item) {
      return PieChartSectionData(
        value: item.value,
        title: '${item.percentage.toStringAsFixed(0)}%',
        color: item.color,
        radius: 50.0,
        titleStyle: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 2,
            ),
          ],
        ),
        badgeWidget: item.percentage > 10
            ? _BadgeWidget(
                icon: item.icon,
                size: 20,
              )
            : null,
        badgePositionPercentageOffset: .98,
      );
    }).toList();
  }

  /// Build legend below chart
  Widget _buildLegend(List<_ChartData> data, bool isDark, WidgetRef ref) {
    final primaryColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final secondaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.7) : AppColors.textSecondary;
    return Column(
      children: data.map((item) {
        return Padding(
          padding: AppSpacing.vertical(AppSpacing.xs),
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: AppRadius.xsAll,
                ),
              ),
              AppSpacingWidget.horizontalSM(),

              // Category name
              Expanded(
                child: Text(
                  '${item.icon} ${item.name}',
                  style: TextStyle(
                    fontSize: 13,
                    color: primaryColor,
                  ),
                ),
              ),

              // Amount
              Text(
                item.value.toCurrency(ref: ref),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),

              // Percentage
              AppSpacingWidget.horizontalSM(),
              Text(
                '${item.percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Parse color string hex to Color object
  Color _parseColor(String hexColor) {
    try {
      final color = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$color', radix: 16));
    } catch (e) {
      return AppColors.textTertiary;
    }
  }
}

/// Data class untuk chart
class _ChartData {
  final String name;
  final double value;
  final Color color;
  final String icon;
  final double percentage;

  _ChartData({
    required this.name,
    required this.value,
    required this.color,
    required this.icon,
    required this.percentage,
  });
}

/// Badge widget untuk icon di pie chart
class _BadgeWidget extends StatelessWidget {
  final String icon;
  final double size;

  const _BadgeWidget({
    required this.icon,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Text(
          icon,
          style: TextStyle(fontSize: size * 0.6),
        ),
      ),
    );
  }
}
