import 'package:flutter/material.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

/// Amount display widget for transactions
///
/// Following SRP: Only handles amount formatting and display
class TransactionAmountDisplay extends StatelessWidget {
  final TransactionEntity transaction;
  final TextStyle? style;

  const TransactionAmountDisplay({
    super.key,
    required this.transaction,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;

    return Text(
      _formatAmount(),
      style: (style ?? Theme.of(context).textTheme.titleLarge)?.copyWith(
        color: amountColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _formatAmount() {
    final prefix = transaction.type == TransactionType.income ? '+' : '-';
    return '$prefix ${CurrencyInputFormatter.formatRupiahFromDouble(transaction.amount)}';
  }
}
