import 'package:flutter/material.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import '../utils/utils.dart';

/// Filter chips untuk memfilter tipe transaksi di list
/// Menampilkan opsi: Semua, Pemasukan, Pengeluaran
class TransactionFilterChip extends StatelessWidget {
  final TransactionType? selectedType;
  final Function(TransactionType?) onTypeChanged;

  const TransactionFilterChip({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.horizontal(AppSpacing.lg),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'Semua',
              isSelected: selectedType == null,
              onTap: () => onTypeChanged(null),
            ),
            const AppSpacingWidget.horizontalSM(),
            _FilterChip(
              label: 'Pemasukan',
              icon: Icons.arrow_downward,
              isSelected: selectedType == TransactionType.income,
              color: AppColors.income,
              onTap: () => onTypeChanged(TransactionType.income),
            ),
            const AppSpacingWidget.horizontalSM(),
            _FilterChip(
              label: 'Pengeluaran',
              icon: Icons.arrow_upward,
              isSelected: selectedType == TransactionType.expense,
              color: AppColors.expense,
              onTap: () => onTypeChanged(TransactionType.expense),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14),
            const AppSpacingWidget.horizontalXS(),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      backgroundColor: chipColor.withValues(alpha: 0.1),
      side: BorderSide(
        color: isSelected ? chipColor : Colors.grey.shade300,
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : chipColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 13,
      ),
    );
  }
}

/// Segmented button style untuk filter tipe transaksi
class TransactionFilterSegmented extends StatelessWidget {
  final TransactionType? selectedType;
  final Function(TransactionType?) onTypeChanged;

  const TransactionFilterSegmented({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TransactionType?>(
      segments: const [
        ButtonSegment(
          value: null,
          label: Text('Semua'),
        ),
        ButtonSegment(
          value: TransactionType.income,
          label: Text('Pemasukan'),
          icon: Icon(Icons.arrow_downward, size: 18),
        ),
        ButtonSegment(
          value: TransactionType.expense,
          label: Text('Pengeluaran'),
          icon: Icon(Icons.arrow_upward, size: 18),
        ),
      ],
      selected: {selectedType},
      onSelectionChanged: (Set<TransactionType?> newSelection) {
        onTypeChanged(newSelection.first);
      },
    );
  }
}

/// Tab bar style untuk filter tipe transaksi
class TransactionFilterTabs extends StatelessWidget {
  final TransactionType? selectedType;
  final Function(TransactionType?) onTypeChanged;

  const TransactionFilterTabs({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.horizontal(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _FilterTab(
              label: 'Semua',
              isSelected: selectedType == null,
              onTap: () => onTypeChanged(null),
            ),
          ),
          const AppSpacingWidget.horizontalSM(),
          Expanded(
            child: _FilterTab(
              label: 'Pemasukan',
              isSelected: selectedType == TransactionType.income,
              color: AppColors.income,
              onTap: () => onTypeChanged(TransactionType.income),
            ),
          ),
          const AppSpacingWidget.horizontalSM(),
          Expanded(
            child: _FilterTab(
              label: 'Pengeluaran',
              isSelected: selectedType == TransactionType.expense,
              color: AppColors.expense,
              onTap: () => onTypeChanged(TransactionType.expense),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tabColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? tabColor : Colors.transparent,
          borderRadius: AppRadius.smAll,
          border: Border.all(
            color: isSelected ? tabColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : tabColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
