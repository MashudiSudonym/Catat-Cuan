import 'package:flutter/material.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import '../utils/app_colors.dart';
import 'base/base.dart';
import '../utils/utils.dart';

/// Toggle button untuk memilih tipe transaksi (Pemasukan/Pengeluaran)
/// Menggunakan design pill-shape sesuai UI reference
class TransactionTypeToggle extends StatelessWidget {
  final TransactionType? selectedType;
  final Function(TransactionType) onTypeChanged;
  final bool enabled;

  const TransactionTypeToggle({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipe Transaksi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        AppGlassContainer.subtle(
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              Expanded(
                child: _TypeButton(
                  label: 'Pemasukan',
                  icon: Icons.arrow_downward,
                  isSelected: selectedType == TransactionType.income,
                  color: AppColors.income,
                  onTap: enabled ? () => onTypeChanged(TransactionType.income) : null,
                ),
              ),
              Expanded(
                child: _TypeButton(
                  label: 'Pengeluaran',
                  icon: Icons.arrow_upward,
                  isSelected: selectedType == TransactionType.expense,
                  color: AppColors.expense,
                  onTap: enabled ? () => onTypeChanged(TransactionType.expense) : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback? onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isSelected ? Colors.white : color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal segmented button version untuk compact layout
class TransactionTypeSegmentedButton extends StatelessWidget {
  final TransactionType? selectedType;
  final Function(TransactionType) onTypeChanged;
  final bool enabled;

  const TransactionTypeSegmentedButton({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TransactionType>(
      segments: const [
        ButtonSegment(
          value: TransactionType.income,
          label: Text('Pemasukan'),
          icon: Icon(Icons.arrow_downward, size: 20),
        ),
        ButtonSegment(
          value: TransactionType.expense,
          label: Text('Pengeluaran'),
          icon: Icon(Icons.arrow_upward, size: 20),
        ),
      ],
      selected: selectedType != null ? {selectedType!} : const {},
      onSelectionChanged: enabled ? (Set<TransactionType> newSelection) {
        onTypeChanged(newSelection.first);
      } : null,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            final type = states.firstWhere(
              (state) => state == WidgetState.selected,
              orElse: () => WidgetState.selected,
            );
            if (type == WidgetState.selected) {
              // Determine which type based on selected value
              return selectedType == TransactionType.expense
                  ? AppColors.expense
                  : AppColors.income;
            }
          }
          return AppColors.backgroundLight;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return selectedType == TransactionType.expense
              ? AppColors.expense
              : AppColors.income;
        }),
      ),
    );
  }
}

/// Icon-only button untuk compact layout
class TransactionTypeIconButton extends StatelessWidget {
  final TransactionType selectedType;
  final Function(TransactionType) onTypeChanged;
  final bool enabled;

  const TransactionTypeIconButton({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = selectedType == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;

    return GestureDetector(
      onTap: enabled ? () {
        // Toggle to opposite type
        onTypeChanged(isIncome ? TransactionType.expense : TransactionType.income);
      } : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              isIncome ? 'Pemasukan' : 'Pengeluaran',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.swap_vert, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
