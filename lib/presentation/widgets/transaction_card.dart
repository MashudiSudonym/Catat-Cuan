import 'package:flutter/material.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:intl/intl.dart';
import '../utils/utils.dart';
import 'base/base.dart';

/// Card item untuk menampilkan transaksi dalam list
/// Menggunakan design dari transaction_history.html reference
class TransactionCard extends StatelessWidget {
  final TransactionEntity transaction;
  final CategoryEntity category;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showDateGroup;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onLongPress;
  final VoidCallback? onSelectionToggle;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.category,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showDateGroup = false,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onLongPress,
    this.onSelectionToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final categoryColor = _getCategoryColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.7) : AppColors.textSecondary;
    final tertiaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.5) : AppColors.textTertiary;

    return Stack(
      children: [
        AppGlassContainer.glassCard(
          margin: AppSpacing.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
          child: InkWell(
            onTap: isSelectionMode ? onSelectionToggle : onTap,
            onLongPress: onLongPress,
            borderRadius: AppRadius.mdAll,
            child: Padding(
              padding: AppSpacing.lgAll,
              child: Row(
                children: [
                  // Checkbox in selection mode
                  if (isSelectionMode) ...[
                    _buildCheckbox(context),
                    const AppSpacingWidget.horizontalMD(),
                  ],

                  // Category Icon
                  _CategoryIcon(
                    icon: category.icon ?? '📦',
                    color: categoryColor,
                  ),
                  const AppSpacingWidget.horizontalMD(),

                  // Transaction Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Name
                        Text(
                          category.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const AppSpacingWidget.verticalXS(),
                        // Date & Time
                        Text(
                          _formatDateTime(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: secondaryColor,
                          ),
                        ),
                        // Note (if any)
                        if (transaction.note != null &&
                            transaction.note!.isNotEmpty) ...[
                          const AppSpacingWidget.horizontalXS(),
                          Text(
                            transaction.note!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: tertiaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatAmount(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: amountColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Action Menu (only show when not in selection mode)
                  if (!isSelectionMode && (onEdit != null || onDelete != null))
                    _buildActionMenu(context, secondaryColor),
                ],
              ),
            ),
          ),
        ),

        // Selected indicator overlay
        if (isSelectionMode && isSelected)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppRadius.mdAll,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getCategoryColor() {
    final colorStr = category.color;
    if (colorStr.isNotEmpty) {
      try {
        return Color(int.parse(colorStr, radix: 16));
      } catch (_) {
        // Fall through to default
      }
    }
    return AppColors.getCategoryColor(category.id ?? 0);
  }

  String _formatAmount() {
    final prefix = transaction.type == TransactionType.income ? '+' : '-';
    return '$prefix ${transaction.amount.toRupiahWithoutPrefix()}';
  }

  String _formatDateTime() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(
      transaction.dateTime.year,
      transaction.dateTime.month,
      transaction.dateTime.day,
    );

    String datePrefix;
    if (transactionDate == today) {
      datePrefix = 'Hari ini';
    } else {
      final yesterday = today.subtract(const Duration(days: 1));
      if (transactionDate == yesterday) {
        datePrefix = 'Kemarin';
      } else {
        datePrefix = DateFormat('dd MMM yyyy', 'id_ID').format(transaction.dateTime);
      }
    }

    final time = DateFormat('HH:mm', 'id_ID').format(transaction.dateTime);
    return '$datePrefix, $time';
  }

  Widget _buildActionMenu(BuildContext context, Color secondaryColor) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      icon: Icon(
        Icons.more_vert,
        color: secondaryColor,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 20),
              const AppSpacingWidget.horizontalMD(),
              Text(
                'Edit',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: AppColors.expense),
              const AppSpacingWidget.horizontalMD(),
              Text(
                'Hapus',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.expense,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onSelectionToggle,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? AppColors.primary
              : (isDark
                  ? AppColors.getGlassSurface(isDark: true, alpha: 0.3)
                  : AppColors.getGlassSurface(isDark: false, alpha: 0.5)),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? AppColors.textOnDark.withValues(alpha: 0.3)
                    : AppColors.textSecondary.withValues(alpha: 0.3)),
            width: 2,
          ),
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}

/// Category icon widget dengan colored background
class _CategoryIcon extends StatelessWidget {
  final String icon;
  final Color color;

  const _CategoryIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      color: color.withValues(alpha: 0.1),
      borderRadius: AppRadius.lgAll,
      width: 48,
      height: 48,
      alignment: Alignment.center,
      child: Text(
        icon,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}

/// Date group header untuk mengelompokkan transaksi berdasarkan tanggal
class TransactionDateHeader extends StatelessWidget {
  final DateTime date;
  final String? customTitle;
  final double totalAmount;

  const TransactionDateHeader({
    super.key,
    required this.date,
    this.customTitle,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.7) : AppColors.textSecondary;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final headerDate = DateTime(date.year, date.month, date.day);

    String title;
    if (customTitle != null) {
      title = customTitle!;
    } else if (headerDate == today) {
      title = 'Hari ini';
    } else {
      final yesterday = today.subtract(const Duration(days: 1));
      if (headerDate == yesterday) {
        title = 'Kemarin';
      } else {
        title = DateFormat('dd MMMM yyyy', 'id_ID').format(date);
      }
    }

    return Padding(
      padding: AppSpacing.only(left: AppSpacing.lg, top: AppSpacing.lg, right: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: secondaryColor,
            ),
          ),
          Text(
            totalAmount.toRupiah(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: secondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Swipeable transaction card dengan gesture untuk edit/delete
class SwipeableTransactionCard extends StatelessWidget {
  final TransactionEntity transaction;
  final CategoryEntity category;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onLongPress;
  final VoidCallback? onSelectionToggle;

  const SwipeableTransactionCard({
    super.key,
    required this.transaction,
    required this.category,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onLongPress,
    this.onSelectionToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Disable swipe when in selection mode
    if (isSelectionMode) {
      return TransactionCard(
        transaction: transaction,
        category: category,
        onTap: onTap,
        onEdit: onEdit,
        onDelete: onDelete,
        isSelected: isSelected,
        isSelectionMode: isSelectionMode,
        onLongPress: onLongPress,
        onSelectionToggle: onSelectionToggle,
      );
    }

    return Dismissible(
      key: Key('transaction_${transaction.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete?.call();
        }
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context);
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: AppSpacing.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: AppRadius.mdAll,
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: TransactionCard(
        transaction: transaction,
        category: category,
        onTap: onTap,
        onEdit: onEdit,
        isSelected: isSelected,
        isSelectionMode: isSelectionMode,
        onLongPress: onLongPress,
        onSelectionToggle: onSelectionToggle,
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: Text(
          'Apakah Anda yakin ingin menghapus transaksi ${category.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.expense,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

/// Compact version untuk list dengan spacing lebih kecil
class CompactTransactionCard extends StatelessWidget {
  final TransactionEntity transaction;
  final CategoryEntity category;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onLongPress;
  final VoidCallback? onSelectionToggle;

  const CompactTransactionCard({
    super.key,
    required this.transaction,
    required this.category,
    this.onTap,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onLongPress,
    this.onSelectionToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.5) : AppColors.textTertiary;

    return InkWell(
      onTap: isSelectionMode ? onSelectionToggle : onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: AppSpacing.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        child: Row(
          children: [
            // Checkbox in selection mode
            if (isSelectionMode) ...[
              _buildCompactCheckbox(context),
              const AppSpacingWidget.horizontalMD(),
            ],
            Text(
              category.icon ?? '📦',
              style: const TextStyle(fontSize: 20),
            ),
            const AppSpacingWidget.horizontalMD(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM, HH:mm', 'id_ID').format(transaction.dateTime),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tertiaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatAmount(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCheckbox(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onSelectionToggle,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? AppColors.primary
              : (isDark
                  ? AppColors.getGlassSurface(isDark: true, alpha: 0.3)
                  : AppColors.getGlassSurface(isDark: false, alpha: 0.5)),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? AppColors.textOnDark.withValues(alpha: 0.3)
                    : AppColors.textSecondary.withValues(alpha: 0.3)),
            width: 1.5,
          ),
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  String _formatAmount() {
    final prefix = transaction.type == TransactionType.income ? '+' : '-';
    return '$prefix ${transaction.amount.toRupiahWithoutPrefix()}';
  }
}
