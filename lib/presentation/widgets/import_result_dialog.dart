import 'package:flutter/material.dart';
import 'package:catat_cuan/domain/entities/import_result_entity.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

/// Dialog menampilkan hasil import CSV
///
/// Shows statistics (total, imported, skipped, errors) with glassmorphism design
class ImportResultDialog extends StatelessWidget {
  final ImportResult result;

  const ImportResultDialog({
    super.key,
    required this.result,
  });

  /// Show import result dialog
  static Future<void> show(
    BuildContext context, {
    required ImportResult result,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ImportResultDialog(result: result),
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
            Row(
              children: [
                Container(
                  padding: AppSpacing.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: (result.isFullySuccessful ? AppColors.success : AppColors.warning)
                        .withValues(alpha: 0.15),
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: Icon(
                    result.isFullySuccessful ? Icons.check_circle : Icons.info_outline,
                    color: result.isFullySuccessful ? AppColors.success : AppColors.warning,
                    size: 24,
                  ),
                ),
                const AppSpacingWidget.horizontalMD(),
                Expanded(
                  child: Text(
                    result.isFullySuccessful ? 'Impor Berhasil' : 'Impor Selesai',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const AppSpacingWidget.verticalLG(),

            // Statistics
            _buildStatsRow(context),
            const AppSpacingWidget.verticalLG(),

            // Auto-created categories info (if any)
            if (result.hasCategoriesCreated) ...[
              _buildCategoriesCreatedInfo(context),
              const AppSpacingWidget.verticalLG(),
            ],

            // Errors section (if any)
            if (result.hasErrors) ...[
              _buildErrorsSection(context),
              const AppSpacingWidget.verticalLG(),
            ],

            // Close button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: AppSpacing.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdAll,
                ),
              ),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            label: 'Total',
            value: '${result.totalRows}',
            icon: Icons.list_alt,
            color: AppColors.primary,
          ),
        ),
        const AppSpacingWidget.horizontalSM(),
        Expanded(
          child: _buildStatItem(
            context,
            label: 'Berhasil',
            value: '${result.imported}',
            icon: Icons.check_circle_outline,
            color: AppColors.success,
          ),
        ),
        const AppSpacingWidget.horizontalSM(),
        Expanded(
          child: _buildStatItem(
            context,
            label: 'Dilewati',
            value: '${result.skipped}',
            icon: Icons.skip_next,
            color: AppColors.warning,
          ),
        ),
        const AppSpacingWidget.horizontalSM(),
        Expanded(
          child: _buildStatItem(
            context,
            label: 'Error',
            value: '${result.errors.where((e) => e.errorMessage != 'Duplikat').length}',
            icon: Icons.error_outline,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: AppSpacing.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const AppSpacingWidget.verticalXS(),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesCreatedInfo(BuildContext context) {
    return Container(
      padding: AppSpacing.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.add_circle_outline,
            color: AppColors.info,
            size: 20,
          ),
          const AppSpacingWidget.horizontalSM(),
          Expanded(
            child: Text(
              '${result.categoriesCreated} kategori baru dibuat otomatis',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorsSection(BuildContext context) {
    // Show at most 5 errors, with "and X more" indicator
    final displayErrors = result.errors.take(5).toList();
    final remaining = result.errors.length - displayErrors.length;

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.only(left: AppSpacing.md, top: AppSpacing.sm, right: AppSpacing.md, bottom: AppSpacing.xs),
            child: Text(
              'Detail Error (${result.errors.length})',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: AppSpacing.only(left: AppSpacing.md, right: AppSpacing.md, bottom: AppSpacing.sm),
              itemCount: displayErrors.length + (remaining > 0 ? 1 : 0),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == displayErrors.length) {
                  return Padding(
                    padding: AppSpacing.symmetric(vertical: AppSpacing.xs),
                    child: Text(
                      '...dan $remaining error lainnya',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                final error = displayErrors[index];
                return Padding(
                  padding: AppSpacing.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Baris ${error.rowNumber}: ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          error.errorMessage,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
