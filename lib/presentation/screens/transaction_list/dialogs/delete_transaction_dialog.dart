import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/utils/app_colors.dart';
import 'package:catat_cuan/presentation/utils/currency_formatter.dart';

/// Dialog untuk konfirmasi hapus transaksi
/// Following SRP: Only handles delete confirmation dialog
class DeleteTransactionDialog extends StatelessWidget {
  final TransactionEntity transaction;

  const DeleteTransactionDialog({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hapus Transaksi'),
      content: Text(
        'Apakah Anda yakin ingin menghapus transaksi ini?\n\n'
        '${transaction.amount.toRupiah()}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => _handleDelete(context),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.expense,
          ),
          child: const Text('Hapus'),
        ),
      ],
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    Navigator.pop(context);
    // Note: The actual delete logic is handled by the caller through a callback
    // This dialog is only responsible for confirmation UI
  }
}

/// Widget untuk menampilkan delete dialog dan handle delete action
/// Following SRP: Separates dialog display from delete logic
class DeleteTransactionHandler extends ConsumerWidget {
  final TransactionEntity transaction;
  final VoidCallback onDelete;

  const DeleteTransactionHandler({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DeleteTransactionDialog(transaction: transaction);
  }

  /// Show delete dialog and handle delete
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    TransactionEntity transaction,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteTransactionDialog(transaction: transaction),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(deleteTransactionUseCaseProvider).execute(transaction.id!);

        // Invalidate transaction list and monthly summary to trigger refresh
        ref.invalidate(transactionListNotifierProvider);
        ref.invalidate(monthlySummaryNotifierProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaksi berhasil dihapus'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus transaksi: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
