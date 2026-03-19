import 'package:flutter/material.dart';
import 'package:catat_cuan/domain/entities/export_action_entity.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

/// Export action dialog for choosing between save and share
///
/// Shows a glassmorphism dialog with two options:
/// - Save to Device: Saves CSV file to local storage
/// - Share: Shares CSV file via share_plus
class ExportActionDialog extends StatelessWidget {
  final String fileName;
  final int transactionCount;

  const ExportActionDialog({
    super.key,
    required this.fileName,
    required this.transactionCount,
  });

  /// Show export action dialog
  ///
  /// Returns the selected ExportAction, or null if dismissed
  static Future<ExportAction?> show(
    BuildContext context, {
    required String fileName,
    required int transactionCount,
  }) {
    return showDialog<ExportAction>(
      context: context,
      builder: (context) => ExportActionDialog(
        fileName: fileName,
        transactionCount: transactionCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AppGlassContainer.glassSurface(
        padding: AppSpacing.lgAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Text(
              'Pilih Aksi Ekspor',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const AppSpacingWidget.verticalLG(),

            // Transaction count preview
            Container(
              padding: AppSpacing.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.getGlassPill(isDark: false, alpha: 0.5),
                borderRadius: AppRadius.mdAll,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const AppSpacingWidget.horizontalSM(),
                  Text(
                    '$transactionCount transaksi akan diekspor',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const AppSpacingWidget.verticalXL(),

            // Action options
            _buildActionOption(
              context,
              action: ExportAction.saveToDevice,
              icon: Icons.download,
              label: ExportAction.saveToDevice.label,
              description: ExportAction.saveToDevice.description,
              color: AppColors.success,
            ),
            const AppSpacingWidget.verticalMD(),
            _buildActionOption(
              context,
              action: ExportAction.share,
              icon: Icons.share,
              label: ExportAction.share.label,
              description: ExportAction.share.description,
              color: AppColors.primary,
            ),
            const AppSpacingWidget.verticalMD(),

            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionOption(
    BuildContext context, {
    required ExportAction action,
    required IconData icon,
    required String label,
    required String description,
    required Color color,
  }) {
    return AppGlassContainer.glassCard(
      onTap: () => Navigator.pop(context, action),
      padding: AppSpacing.all(AppSpacing.md),
      child: Row(
        children: [
          // Icon container
          Container(
            padding: AppSpacing.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: AppRadius.mdAll,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const AppSpacingWidget.horizontalMD(),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const AppSpacingWidget.verticalXS(),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Arrow icon
          Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
