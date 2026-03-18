import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:catat_cuan/presentation/utils/app_colors.dart';
import 'package:catat_cuan/presentation/utils/glassmorphism/app_glassmorphism.dart';
import 'dart:ui';

/// Bottom sheet untuk memilih bulan dan tahun
/// Menampilkan daftar bulan yang tersedia dan opsi "Semua Data"
class MonthPickerBottomSheet extends StatefulWidget {
  final String selectedYearMonth;
  final DateTime? firstTransactionDate;
  final Function(String) onMonthSelected;

  const MonthPickerBottomSheet({
    super.key,
    required this.selectedYearMonth,
    required this.firstTransactionDate,
    required this.onMonthSelected,
  });

  /// Show month picker bottom sheet
  static Future<String?> show(
    BuildContext context, {
    required String selectedYearMonth,
    DateTime? firstTransactionDate,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MonthPickerBottomSheet(
        selectedYearMonth: selectedYearMonth,
        firstTransactionDate: firstTransactionDate,
        onMonthSelected: (yearMonth) => Navigator.pop(context, yearMonth),
      ),
    );
  }

  @override
  State<MonthPickerBottomSheet> createState() => _MonthPickerBottomSheetState();
}

class _MonthPickerBottomSheetState extends State<MonthPickerBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adjustedBlur = GlassVariant.overlay.getAdjustedBlur(isDark: isDark);
    final adjustedAlpha = GlassVariant.overlay.getAdjustedAlpha(isDark: isDark);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: adjustedBlur, sigmaY: adjustedBlur),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.getGlassOverlay(isDark: isDark, alpha: adjustedAlpha),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(
                  top: BorderSide(
                    color: AppColors.getGlassBorder(isDark: isDark),
                    width: GlassBorder.width,
                  ),
                ),
              ),
              child: Column(
                children: [
                  _buildHandle(isDark),
                  _buildHeader(isDark),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        // Opsi "Semua Data"
                        _buildAllDataOption(isDark),
                        const Divider(height: 24),
                        // Daftar bulan
                        _buildMonthList(isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Text(
            'Pilih Periode',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllDataOption(bool isDark) {
    final isSelected = widget.selectedYearMonth == 'all';
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;

    return _MonthOptionTile(
      title: 'Semua Data',
      subtitle: 'Lihat ringkasan seluruh transaksi',
      icon: Icons.all_inclusive,
      isSelected: isSelected,
      onTap: () => widget.onMonthSelected('all'),
      isDark: isDark,
      textColor: textColor,
    );
  }

  Widget _buildMonthList(bool isDark) {
    // Generate list of months from first transaction to now
    final now = DateTime.now();
    final firstDate = widget.firstTransactionDate ?? DateTime(now.year - 1, now.month);

    final months = <_MonthOption>[];

    // Generate months from first date to current month
    var current = DateTime(now.year, now.month);
    final start = DateTime(firstDate.year, firstDate.month);

    while (current.isAfter(start) || current.isAtSameMomentAs(start)) {
      final yearMonth = '${current.year}-${current.month.toString().padLeft(2, '0')}';
      final formatter = DateFormat('MMMM yyyy', 'id_ID');
      final label = formatter.format(current);

      months.add(_MonthOption(
        value: yearMonth,
        label: label,
        isCurrentMonth: current.year == now.year && current.month == now.month,
      ));

      // Go to previous month
      current = DateTime(current.year, current.month - 1);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Bulan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                ),
          ),
        ),
        ...months.map((month) => _MonthOptionTile(
              title: month.label,
              subtitle: month.isCurrentMonth ? 'Bulan ini' : null,
              icon: Icons.calendar_month,
              isSelected: widget.selectedYearMonth == month.value,
              onTap: () => widget.onMonthSelected(month.value),
              isDark: isDark,
              textColor: isDark ? AppColors.textOnDark : AppColors.textPrimary,
            )),
      ],
    );
  }
}

class _MonthOption {
  final String value;
  final String label;
  final bool isCurrentMonth;

  _MonthOption({
    required this.value,
    required this.label,
    this.isCurrentMonth = false,
  });
}

class _MonthOptionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final Color textColor;

  const _MonthOptionTile({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.15)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : textColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : textColor,
                        ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: textColor.withValues(alpha: 0.6),
                          ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
