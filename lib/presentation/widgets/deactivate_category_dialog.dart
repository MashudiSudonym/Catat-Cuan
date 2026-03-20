import 'package:flutter/material.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

/// Dialog konfirmasi untuk menonaktifkan kategori
class DeactivateCategoryDialog extends StatelessWidget {
  final String categoryName;
  final int transactionCount;
  final VoidCallback onConfirm;

  const DeactivateCategoryDialog({
    super.key,
    required this.categoryName,
    required this.transactionCount,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nonaktifkan Kategori'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apakah Anda yakin ingin menonaktifkan kategori "$categoryName"?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (transactionCount > 0) ...[
            const AppSpacingWidget.verticalLG(),
            Container(
              padding: AppSpacing.mdAll,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: AppRadius.smAll,
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange[700],
                        size: 20,
                      ),
                      const AppSpacingWidget.horizontalSM(),
                      Text(
                        'Peringatan',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const AppSpacingWidget.verticalSM(),
                  Text(
                    'Kategori ini digunakan oleh $transactionCount transaksi. '
                    'Kategori dengan transaksi tidak dapat dinonaktifkan.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange[900],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        if (transactionCount == 0)
          TextButton(
            onPressed: onConfirm,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Nonaktifkan'),
          ),
      ],
    );
  }

  /// Show deactivate category dialog
  static Future<bool?> show({
    required BuildContext context,
    required String categoryName,
    required int transactionCount,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeactivateCategoryDialog(
        categoryName: categoryName,
        transactionCount: transactionCount,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }
}
