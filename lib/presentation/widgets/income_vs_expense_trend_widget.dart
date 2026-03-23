import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:intl/intl.dart';

/// Widget untuk menampilkan tren pemasukan vs pengeluaran dalam bentuk bar chart
class IncomeVsExpenseTrendWidget extends ConsumerWidget {
  final List<MonthlySummaryEntity> summaries;

  const IncomeVsExpenseTrendWidget({
    super.key,
    required this.summaries,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (summaries.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;

    // Find max value for Y-axis scaling
    double maxValue = 0;
    for (final summary in summaries) {
      if (summary.totalIncome > maxValue) maxValue = summary.totalIncome;
      if (summary.totalExpense > maxValue) maxValue = summary.totalExpense;
    }

    // Add 10% headroom
    maxValue = maxValue * 1.1;

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
                  Icons.trending_up,
                  color: AppColors.primary,
                  size: 20,
                ),
                AppSpacingWidget.horizontalSM(),
                Text(
                  'Tren Pemasukan vs Pengeluaran',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                ),
              ],
            ),
            AppSpacingWidget.verticalLG(),

            // Legend
            _buildLegend(context, isDark),
            AppSpacingWidget.verticalMD(),

            // Bar Chart
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue,
                  minY: 0,
                  groupsSpace: AppSpacing.md,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final monthIndex = group.x.toInt() ~/ 2;
                        if (monthIndex >= summaries.length) {
                          return null;
                        }
                        final monthName = _formatMonth(summaries[monthIndex].yearMonth);
                        final type = group.x.toInt() % 2 == 0 ? 'Pemasukan' : 'Pengeluaran';
                        final amount = rod.toY.toCurrency(ref: ref);
                        return BarTooltipItem(
                          '$monthName\n$type\n$amount',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                      tooltipBgColor: textColor.withValues(alpha: 0.9),
                      tooltipPadding: AppSpacing.all(AppSpacing.sm),
                      tooltipRoundedRadius: AppRadius.md,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Show label only for income bars (even indices)
                          if (value.toInt() % 2 != 0) {
                            return const SizedBox.shrink();
                          }
                          final monthIndex = value.toInt() ~/ 2;
                          if (monthIndex >= summaries.length) {
                            return const SizedBox.shrink();
                          }
                          final monthName = _formatShortMonth(summaries[monthIndex].yearMonth);
                          return Padding(
                            padding: EdgeInsets.only(top: AppSpacing.xs),
                            child: Text(
                              monthName,
                              style: TextStyle(
                                fontSize: 10,
                                color: textColor,
                              ),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.max || value == meta.min) {
                            return const SizedBox.shrink();
                          }
                          // Format in millions (jt) or thousands (rb)
                          String formatted;
                          if (value >= 1000000) {
                            formatted = '${(value / 1000000).toStringAsFixed(0)}jt';
                          } else if (value >= 1000) {
                            formatted = '${(value / 1000).toStringAsFixed(0)}rb';
                          } else {
                            formatted = value.toStringAsFixed(0);
                          }
                          return Text(
                            formatted,
                            style: TextStyle(
                              fontSize: 10,
                              color: textColor,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxValue / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.textTertiary.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarGroups(),
                ),
                swapAnimationDuration: const Duration(milliseconds: 800),
                swapAnimationCurve: Curves.easeInOutCubic,
              ),
            ),

            AppSpacingWidget.verticalSM(),
          ],
        ),
      ),
    );
  }

  /// Build legend for the chart
  Widget _buildLegend(BuildContext context, bool isDark) {
    final legendColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.8) : AppColors.textSecondary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Income legend
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xFF059669),
                    AppColors.income,
                  ],
                ),
                borderRadius: AppRadius.xsAll,
              ),
            ),
            AppSpacingWidget.horizontalXS(),
            Text(
              'Pemasukan',
              style: TextStyle(
                fontSize: 12,
                color: legendColor,
              ),
            ),
          ],
        ),
        AppSpacingWidget.horizontalLG(),

        // Expense legend
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xFFDC2626),
                    AppColors.expense,
                  ],
                ),
                borderRadius: AppRadius.xsAll,
              ),
            ),
            AppSpacingWidget.horizontalXS(),
            Text(
              'Pengeluaran',
              style: TextStyle(
                fontSize: 12,
                color: legendColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build bar groups for the chart
  List<BarChartGroupData> _buildBarGroups() {
    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < summaries.length; i++) {
      final summary = summaries[i];

      // Income bar
      barGroups.add(BarChartGroupData(
        x: i * 2,
        barRods: [
          BarChartRodData(
            toY: summary.totalIncome,
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xFF059669),
                AppColors.income,
              ],
            ),
            width: 12,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.sm),
              topRight: Radius.circular(AppRadius.sm),
            ),
          ),
        ],
      ));

      // Expense bar
      barGroups.add(BarChartGroupData(
        x: i * 2 + 1,
        barRods: [
          BarChartRodData(
            toY: summary.totalExpense,
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xFFDC2626),
                AppColors.expense,
              ],
            ),
            width: 12,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.sm),
              topRight: Radius.circular(AppRadius.sm),
            ),
          ),
        ],
      ));
    }

    return barGroups;
  }

  /// Format year-month to short month name (e.g., "2024-03" -> "Mar")
  String _formatShortMonth(String yearMonth) {
    try {
      final parts = yearMonth.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final date = DateTime(year, month);
      return DateFormat('MMM').format(date);
    } catch (e) {
      return '--';
    }
  }

  /// Format year-month to full month name in Indonesian (e.g., "2024-03" -> "Maret")
  String _formatMonth(String yearMonth) {
    try {
      final parts = yearMonth.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      const months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];

      return '${months[month - 1]} $year';
    } catch (e) {
      return yearMonth;
    }
  }
}
