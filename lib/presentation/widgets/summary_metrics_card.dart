import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

/// Card untuk menampilkan 4 metrik utama ringkasan bulanan:
/// - Total Pemasukan
/// - Total Pengeluaran
/// - Saldo
/// - Jumlah Transaksi
class SummaryMetricsCard extends ConsumerWidget {
  final MonthlySummaryEntity summary;

  const SummaryMetricsCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;

    return AppGlassContainer.glassCard(
      margin: AppSpacing.lgAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Ringkasan ${_formatMonthYear()}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
          ),
          const AppSpacingWidget.verticalLG(),

          // Metrics Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.5,
            children: [
              _MetricCard(
                icon: Icons.arrow_downward,
                iconColor: AppColors.income,
                label: 'Pemasukan',
                value: summary.totalIncome.toCurrency(ref: ref),
                backgroundColor: AppColors.incomeLight,
              ),
              _MetricCard(
                icon: Icons.arrow_upward,
                iconColor: AppColors.expense,
                label: 'Pengeluaran',
                value: summary.totalExpense.toCurrency(ref: ref),
                backgroundColor: AppColors.expenseLight,
              ),
              _MetricCard(
                icon: summary.balance >= 0 ? Icons.account_balance_wallet : Icons.warning,
                iconColor: summary.balance >= 0 ? AppColors.income : AppColors.expense,
                label: 'Saldo',
                value: summary.balance.toCurrency(ref: ref),
                backgroundColor: summary.balance >= 0
                    ? AppColors.incomeLight
                    : AppColors.expenseLight,
              ),
              _MetricCard(
                icon: Icons.receipt_long,
                iconColor: AppColors.primary,
                label: 'Transaksi',
                value: '${summary.transactionCount}',
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Format bulan-tahun untuk display (contoh: "Maret 2024")
  String _formatMonthYear() {
    // Handle "all" case for all-time summary
    if (summary.yearMonth == 'all') {
      return 'Semua Waktu';
    }

    final parts = summary.yearMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    return '${months[month - 1]} $year';
  }
}

/// Widget untuk single metric card
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color backgroundColor;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.7) : AppColors.textSecondary;

    return AppGlassContainer.subtle(
      padding: AppSpacing.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon
          AppContainer(
            padding: AppSpacing.all(AppSpacing.xs + 2),
            color: iconColor.withValues(alpha: 0.2),
            borderRadius: AppRadius.smAll,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),

          // Label & Value
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: secondaryColor,
                      fontSize: 11,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
