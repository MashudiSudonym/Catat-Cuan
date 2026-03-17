import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';
import 'package:catat_cuan/presentation/utils/app_colors.dart';

/// Dialog untuk konfirmasi hapus semua transaksi
/// Following SRP: Only handles delete all confirmation dialog
class DeleteAllTransactionsDialog extends StatelessWidget {
  const DeleteAllTransactionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hapus Semua Transaksi'),
      content: const Text(
        '⚠️ PERINGATAN!\n\n'
        'Semua transaksi akan dihapus secara permanen. '
        'Tindakan ini TIDAK DAPAT dibatalkan.\n\n'
        'Apakah Anda yakin ingin melanjutkan?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => _handleDelete(context),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
          ),
          child: const Text('Hapus Semua'),
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

/// Widget untuk menampilkan delete all dialog dan handle delete all action
/// Following SRP: Separates dialog display from delete logic
class DeleteAllTransactionsHandler {
  /// Show delete all dialog and handle delete all
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => const DeleteAllTransactionsDialog(),
    );

    // Handle delete all logic outside the dialog
    if (context.mounted) {
      try {
        await ref.read(deleteAllTransactionsUseCaseProvider).execute();

        // Invalidate transaction list and monthly summary to trigger refresh
        ref.invalidate(transactionListNotifierProvider);
        ref.invalidate(monthlySummaryNotifierProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Semua transaksi berhasil dihapus'),
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
