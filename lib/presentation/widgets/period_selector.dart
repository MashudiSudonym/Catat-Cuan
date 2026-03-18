import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:catat_cuan/presentation/utils/app_colors.dart';
import 'package:catat_cuan/presentation/widgets/month_picker_bottom_sheet.dart';

/// Widget untuk pemilihan periode (bulan/tahun)
/// Menampilkan tombol previous/next dan dropdown untuk quick selection
class PeriodSelector extends StatelessWidget {
  final String selectedYearMonth;
  final Function(String) onMonthChanged;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final DateTime? firstTransactionDate;

  const PeriodSelector({
    super.key,
    required this.selectedYearMonth,
    required this.onMonthChanged,
    this.onPrevious,
    this.onNext,
    this.firstTransactionDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        border: Border(
          bottom: BorderSide(
            color: AppColors.textTertiary.withValues(alpha: isDark ? 0.1 : 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Previous Button (disabled for "all" mode)
          _MonthNavigationButton(
            icon: Icons.chevron_left,
            onPressed: selectedYearMonth == 'all' ? null : onPrevious,
          ),

          const SizedBox(width: 12),

          // Month Display & Dropdown
          Expanded(
            child: _MonthDropdown(
              selectedYearMonth: selectedYearMonth,
              onMonthChanged: onMonthChanged,
              firstTransactionDate: firstTransactionDate,
            ),
          ),

          const SizedBox(width: 12),

          // Next Button (disabled for "all" mode)
          _MonthNavigationButton(
            icon: Icons.chevron_right,
            onPressed: selectedYearMonth == 'all' ? null : onNext,
          ),
        ],
      ),
    );
  }
}

/// Widget untuk tombol navigasi bulan
class _MonthNavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _MonthNavigationButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.4) : AppColors.textTertiary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.textTertiary.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: onPressed != null
                ? AppColors.primary
                : tertiaryColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// Widget untuk dropdown pemilihan bulan
class _MonthDropdown extends StatelessWidget {
  final String selectedYearMonth;
  final Function(String) onMonthChanged;
  final DateTime? firstTransactionDate;

  const _MonthDropdown({
    required this.selectedYearMonth,
    required this.onMonthChanged,
    this.firstTransactionDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final secondaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.7) : AppColors.textSecondary;

    return GestureDetector(
      onTap: () => _showMonthPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.getBackgroundColor(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textTertiary.withValues(alpha: isDark ? 0.2 : 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _formatMonthYear(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.expand_more,
              color: secondaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMonthPicker(BuildContext context) async {
    final selected = await MonthPickerBottomSheet.show(
      context,
      selectedYearMonth: selectedYearMonth,
      firstTransactionDate: firstTransactionDate,
    );

    if (selected != null) {
      onMonthChanged(selected);
    }
  }

  String _formatMonthYear() {
    if (selectedYearMonth == 'all') {
      return 'Semua Data';
    }

    final parts = selectedYearMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    // Menggunakan intl untuk format bahasa Indonesia
    final date = DateTime(year, month);
    final formatter = DateFormat('MMMM yyyy', 'id_ID');
    return formatter.format(date);
  }
}

/// Widget compact version untuk periode selector (tanpa dropdown)
class PeriodSelectorCompact extends StatelessWidget {
  final String selectedYearMonth;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const PeriodSelectorCompact({
    super.key,
    required this.selectedYearMonth,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Previous Button
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
            color: AppColors.primary,
            constraints: const BoxConstraints(minWidth: 40),
            padding: EdgeInsets.zero,
          ),

          const SizedBox(width: 8),

          // Month Display
          Expanded(
            child: Center(
              child: Text(
                _formatMonthYear(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Next Button
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
            color: AppColors.primary,
            constraints: const BoxConstraints(minWidth: 40),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  String _formatMonthYear() {
    final parts = selectedYearMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    // Menggunakan intl untuk format bahasa Indonesia
    final date = DateTime(year, month);
    final formatter = DateFormat('MMMM yyyy', 'id_ID');
    return formatter.format(date);
  }
}

/// Widget untuk display periode saja (tanpa tombol navigasi)
class PeriodDisplay extends StatelessWidget {
  final String yearMonth;

  const PeriodDisplay({
    super.key,
    required this.yearMonth,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;

    return Text(
      _formatMonthYear(),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
    );
  }

  String _formatMonthYear() {
    final parts = yearMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    final date = DateTime(year, month);
    final formatter = DateFormat('MMMM yyyy', 'id_ID');
    return formatter.format(date);
  }
}
