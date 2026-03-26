import 'package:flutter/material.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

/// Transaction action menu widget
///
/// Following SRP: Only handles action menu rendering
class TransactionActions extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Color? iconColor;

  const TransactionActions({
    super.key,
    this.onEdit,
    this.onDelete,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    if (onEdit == null && onDelete == null) {
      return const SizedBox.shrink();
    }

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
        color: iconColor,
      ),
      itemBuilder: (context) => [
        if (onEdit != null)
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
        if (onDelete != null)
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
}
