import 'package:flutter/material.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

/// Date display widget for transactions
///
/// Following SRP: Only handles date formatting and display
class TransactionDateDisplay extends StatelessWidget {
  final TransactionEntity transaction;
  final TextStyle? style;
  final bool showTime;

  const TransactionDateDisplay({
    super.key,
    required this.transaction,
    this.style,
    this.showTime = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark
        ? AppColors.textOnDark.withValues(alpha: 0.7)
        : AppColors.textSecondary;

    return Text(
      _formatDateTime(),
      style: (style ?? Theme.of(context).textTheme.bodySmall)?.copyWith(
        color: secondaryColor,
      ),
    );
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
        final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
        final dayName = days[transaction.dateTime.weekday - 1];
        final month = _getMonthName(transaction.dateTime.month);
        datePrefix = '$dayName, ${transaction.dateTime.day} $month ${transaction.dateTime.year}';
      }
    }

    if (!showTime) {
      return datePrefix;
    }

    final time = '${transaction.dateTime.hour.toString().padLeft(2, '0')}:'
                '${transaction.dateTime.minute.toString().padLeft(2, '0')}';
    return '$datePrefix, $time';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }
}
