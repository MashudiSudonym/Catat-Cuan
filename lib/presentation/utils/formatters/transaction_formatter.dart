import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Utility class for formatting transaction data for display
///
/// Responsibility: Centralizing all transaction-related formatting logic
///
/// Following SRP - Only handles formatting of transaction data
class TransactionFormatter {
  TransactionFormatter._();

  /// Format transaction amount as currency string
  ///
  /// Handles income/expense styling and currency symbol
  static String formatAmount(
    TransactionEntity transaction,
    WidgetRef ref,
  ) {
    final currencyState = ref.watch(currencyProvider);
    final symbol = currencyState.currencyOption.symbol;

    final amountStr = transaction.amount.toStringAsFixed(0);

    // Add thousand separators
    final buffer = StringBuffer();
    for (int i = 0; i < amountStr.length; i++) {
      if (i > 0 && (amountStr.length - i) % 3 == 0) {
        buffer.write(currencyState.currencyOption.thousandSeparator);
      }
      buffer.write(amountStr[i]);
    }

    return '$symbol${buffer.toString()}';
  }

  /// Format transaction amount with sign (+/-)
  ///
  /// Returns formatted amount with income/expense indicator
  static String formatAmountWithSign(
    TransactionEntity transaction,
    WidgetRef ref,
  ) {
    final formattedAmount = formatAmount(transaction, ref);

    if (transaction.type == TransactionType.income) {
      return '+ $formattedAmount';
    } else {
      return '- $formattedAmount';
    }
  }

  /// Format transaction date time
  ///
  /// Returns formatted date/time string in Indonesian locale
  static String formatDateTime(TransactionEntity transaction) {
    final now = DateTime.now();
    final diff = now.difference(transaction.dateTime);

    // Today: show time only
    if (diff.inDays == 0 &&
        transaction.dateTime.day == now.day &&
        transaction.dateTime.month == now.month &&
        transaction.dateTime.year == now.year) {
      final hour = transaction.dateTime.hour.toString().padLeft(2, '0');
      final minute = transaction.dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    // Yesterday
    final yesterday = now.subtract(const Duration(days: 1));
    if (transaction.dateTime.day == yesterday.day &&
        transaction.dateTime.month == yesterday.month &&
        transaction.dateTime.year == yesterday.year) {
      return 'Kemarin';
    }

    // This week: show day name
    if (diff.inDays < 7) {
      const days = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu'
      ];
      final dayName = days[transaction.dateTime.weekday - 1];
      return dayName;
    }

    // Otherwise: show date
    final day = transaction.dateTime.day.toString().padLeft(2, '0');
    final month = transaction.dateTime.month.toString().padLeft(2, '0');
    final year = transaction.dateTime.year;
    return '$day/$month/$year';
  }

  /// Format transaction date for grouping
  ///
  /// Returns formatted date string for transaction grouping headers
  static String formatDateForGrouping(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    // Today
    if (diff.inDays == 0 &&
        dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      return 'Hari Ini';
    }

    // Yesterday
    final yesterday = now.subtract(const Duration(days: 1));
    if (dateTime.day == yesterday.day &&
        dateTime.month == yesterday.month &&
        dateTime.year == yesterday.year) {
      return 'Kemarin';
    }

    // This week: show day name
    if (diff.inDays < 7) {
      const days = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu'
      ];
      final dayName = days[dateTime.weekday - 1];
      return dayName;
    }

    // Otherwise: show full date
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  /// Get category color from color string
  ///
  /// Converts hex color string to Color object
  static Color getCategoryColor(CategoryEntity category) {
    try {
      // Remove # if present
      final hexColor = category.color.replaceFirst('#', '');

      // Parse color
      final colorValue = int.parse('FF$hexColor', radix: 16);
      return Color(colorValue);
    } catch (e) {
      // Return default color if parsing fails
      return category.type == CategoryType.income
          ? const Color(0xFF4CAF50)
          : const Color(0xFFF44336);
    }
  }

  /// Get text color based on transaction type
  ///
  /// Returns green for income, red for expense
  static Color getAmountColor(TransactionEntity transaction) {
    return transaction.type == TransactionType.income
        ? const Color(0xFF4CAF50)
        : const Color(0xFFF44336);
  }

  /// Format category display text
  ///
  /// Returns category name with icon
  static String formatCategoryText(CategoryEntity category) {
    return '${category.icon} ${category.name}';
  }
}
