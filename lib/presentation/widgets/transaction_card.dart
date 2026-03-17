import 'package:flutter/material.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
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

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.category,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showDateGroup = false,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final categoryColor = _getCategoryColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.7) : AppColors.textSecondary;
    final tertiaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.5) : AppColors.textTertiary;

    return AppGlassContainer.glassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category Icon
              _CategoryIcon(
                icon: category.icon ?? '📦',
                color: categoryColor,
              ),
              const SizedBox(width: 12),

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
                    const SizedBox(height: 4),
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
                      const SizedBox(height: 2),
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

              // Action Menu
              if (onEdit != null || onDelete != null)
                _buildActionMenu(context, secondaryColor),
            ],
          ),
        ),
      ),
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
              const SizedBox(width: 12),
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
              const SizedBox(width: 12),
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
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          icon,
          style: TextStyle(
            fontSize: 24,
          ),
        ),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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

  const SwipeableTransactionCard({
    super.key,
    required this.transaction,
    required this.category,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: BorderRadius.circular(12),
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

  const CompactTransactionCard({
    super.key,
    required this.transaction,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiaryColor = isDark ? AppColors.textOnDark.withValues(alpha: 0.5) : AppColors.textTertiary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Text(
              category.icon ?? '📦',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
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

  String _formatAmount() {
    final prefix = transaction.type == TransactionType.income ? '+' : '-';
    return '$prefix ${transaction.amount.toRupiahWithoutPrefix()}';
  }
}
