import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/entities/export_action_entity.dart';
import 'package:catat_cuan/presentation/providers/export/export_provider.dart';
import 'package:catat_cuan/presentation/providers/repositories/repository_providers.dart';
import 'package:catat_cuan/presentation/providers/transaction/transaction_filter_provider.dart';
import 'package:catat_cuan/presentation/providers/services/service_providers.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/widgets/export_action_dialog.dart';
import 'package:catat_cuan/presentation/navigation/routes/app_router.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';

/// Export options bottom sheet
class ExportOptionsBottomSheet extends ConsumerWidget {
  final TransactionType? currentTypeFilter;

  const ExportOptionsBottomSheet({
    super.key,
    this.currentTypeFilter,
  });

  /// Show export options bottom sheet
  static Future<ExportOption?> show(
    BuildContext context, {
    TransactionType? currentTypeFilter,
  }) {
    return showModalBottomSheet<ExportOption>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ExportOptionsBottomSheet(
        currentTypeFilter: currentTypeFilter,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return AppGlassContainer.glassOverlay(
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: AppSpacing.vertical(AppSpacing.md),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.getGlassBorder(alpha: 0.3),
                  borderRadius: AppRadius.xlAll,
                ),
              ),

              // Header
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Ekspor Transaksi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: AppSpacing.horizontal(AppSpacing.lg),
                  children: [
                    _buildExportOption(
                      context,
                      ref,
                      icon: Icons.download,
                      title: 'Ekspor Semua',
                      subtitle: 'Unduh semua transaksi',
                      option: ExportOption.all,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildExportOption(
                      context,
                      ref,
                      icon: Icons.filter_list,
                      title: 'Ekspor dengan Filter Saat Ini',
                      subtitle: 'Gunakan filter yang sedang aktif',
                      option: ExportOption.filtered,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportOption(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required String subtitle,
    required ExportOption option,
  }) {
    return AppGlassContainer.glassCard(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        onTap: () => _handleExport(context, ref, option),
      ),
    );
  }

  void _handleExport(BuildContext context, WidgetRef ref, ExportOption option) async {
    // Get filter parameters
    DateTime? startDate;
    DateTime? endDate;
    int? categoryId;
    TransactionType? type;

    if (option == ExportOption.filtered) {
      final filterState = ref.read(transactionFilterProvider);
      startDate = filterState.startDate;
      endDate = filterState.endDate;
      categoryId = filterState.categoryId;
      type = filterState.type;
    }

    // Get transactions for export
    final exportRepository = ref.read(transactionExportRepositoryProvider);
    final transactionsResult = await exportRepository.getTransactionsWithCategoryNames(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      type: type,
    );

    // Check for errors
    if (transactionsResult.isFailure || (transactionsResult.data?.isEmpty ?? true)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessageMapper.getUserMessage(transactionsResult.failure)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    final transactions = transactionsResult.data!;

    // Generate file name
    final fileName = _generateFileName(option);

    // Show action dialog while bottom sheet context is still valid
    if (!context.mounted) return;
    final action = await ExportActionDialog.show(
      context,
      fileName: '$fileName.csv',
      transactionCount: transactions.length,
    );

    // Close the bottom sheet
    if (context.mounted) {
      Navigator.pop(context);
    }

    // Execute export based on selected action
    if (action == null) return;

    // Show loading dialog using root navigator key (no local BuildContext variable)
    if (rootNavigatorKey.currentContext == null) return;
    showDialog(
      context: rootNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (dialogContext) => _ExportLoadingDialog(action: action),
    );

    try {
      // Call export service directly — avoids Riverpod auto-dispose issue
      // when bottom sheet closes and no widget watches exportProvider
      final exportService = ref.read(exportServiceProvider);

      if (action == ExportAction.saveToDevice) {
        // Check MANAGE_EXTERNAL_STORAGE permission before saving
        final permissionService = ref.read(permissionServiceProvider);
        final hasPermission = await permissionService.checkManageExternalStoragePermission();

        if (!hasPermission) {
          // Dismiss loading dialog before showing permission dialog
          if (rootNavigatorKey.currentContext == null) return;
          Navigator.of(rootNavigatorKey.currentContext!, rootNavigator: true).pop();

          // Show permission dialog and guide user to settings
          if (rootNavigatorKey.currentContext == null) return;
          final permissionGranted = await _showPermissionDialog(rootNavigatorKey.currentContext!, ref);

          if (!permissionGranted) {
            // User denied or cancelled
            _showResultDialog(
              rootNavigatorKey.currentContext!,
              isSuccess: false,
              errorMessage: 'Izin penyimpanan diperlukan untuk menyimpan file CSV.',
            );
            return;
          }

          // Re-show loading dialog after permission is granted
          if (rootNavigatorKey.currentContext == null) return;
          showDialog(
            context: rootNavigatorKey.currentContext!,
            barrierDismissible: false,
            builder: (dialogContext) => _ExportLoadingDialog(action: action),
          );
        }

        final result = await exportService.saveTransactionsToCsv(
          transactions: transactions,
          fileName: fileName,
        );

        // Dismiss loading dialog
        if (rootNavigatorKey.currentContext == null) return;
        Navigator.of(rootNavigatorKey.currentContext!, rootNavigator: true).pop();

        if (result.isSuccess) {
          _showResultDialog(
            rootNavigatorKey.currentContext!,
            isSuccess: true,
            action: ExportAction.saveToDevice,
            filePath: result.data,
          );
        } else {
          _showResultDialog(
            rootNavigatorKey.currentContext!,
            isSuccess: false,
            errorMessage: ErrorMessageMapper.getUserMessage(result.failure),
          );
        }
      } else {
        final result = await exportService.shareTransactionsToCsv(
          transactions: transactions,
          fileName: fileName,
        );

        // Dismiss loading dialog
        if (rootNavigatorKey.currentContext == null) return;
        Navigator.of(rootNavigatorKey.currentContext!, rootNavigator: true).pop();

        if (result.isSuccess) {
          _showResultDialog(
            rootNavigatorKey.currentContext!,
            isSuccess: true,
            action: ExportAction.share,
          );
        } else {
          _showResultDialog(
            rootNavigatorKey.currentContext!,
            isSuccess: false,
            errorMessage: ErrorMessageMapper.getUserMessage(result.failure),
          );
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e('Export failed', e, stackTrace);
      // Dismiss loading dialog if still showing
      if (rootNavigatorKey.currentContext != null &&
          Navigator.of(rootNavigatorKey.currentContext!, rootNavigator: true).canPop()) {
        Navigator.of(rootNavigatorKey.currentContext!, rootNavigator: true).pop();
      }
      if (rootNavigatorKey.currentContext == null) return;
      _showResultDialog(
        rootNavigatorKey.currentContext!,
        isSuccess: false,
        errorMessage: ErrorMessageMapper.getUserMessage(e),
      );
    }
  }

  /// Show result dialog (success or error)
  void _showResultDialog(
    BuildContext context, {
    required bool isSuccess,
    ExportAction? action,
    String? filePath,
    String? errorMessage,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: AppBorderRadius.mdShape,
        backgroundColor: AppColors.getGlassSurface(isDark: false),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? AppColors.success : AppColors.error,
              size: 48,
            ),
            const AppSpacingWidget.verticalLG(),

            // Title
            Text(
              isSuccess ? 'Ekspor Berhasil!' : 'Ekspor Gagal',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const AppSpacingWidget.verticalMD(),

            // Message
            Text(
              isSuccess
                  ? (action == ExportAction.saveToDevice
                      ? 'File CSV berhasil disimpan di:\n\n$filePath\n\nBuka folder Download > CatatCuan di File Manager Anda.'
                      : 'File CSV berhasil dibagikan')
                  : (errorMessage ?? 'Terjadi kesalahan saat mengekspor'),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show permission dialog and guide user to settings
  ///
  /// Returns true if permission was granted after returning from settings,
  /// false if user denied or cancelled.
  Future<bool> _showPermissionDialog(BuildContext context, WidgetRef ref) async {
    final permissionService = ref.read(permissionServiceProvider);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: AppBorderRadius.mdShape,
        backgroundColor: AppColors.getGlassSurface(isDark: false),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            const Icon(
              Icons.folder_outlined,
              color: AppColors.primary,
              size: 48,
            ),
            const AppSpacingWidget.verticalLG(),

            // Title
            const Text(
              'Izin Penyimpanan Diperlukan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const AppSpacingWidget.verticalMD(),

            // Message
            const Text(
              'Untuk menyimpan file CSV di folder Download, '
              'aplikasi memerlukan akses penyimpanan penuh.\n\n'
              'Silakan aktifkan izin "Semua akses file media" di Pengaturan.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              // Open app settings
              final openResult = await permissionService.openSettings();

              if (openResult.isSuccess && dialogContext.mounted) {
                // Close dialog first
                Navigator.pop(dialogContext);

                // Wait for user to return from settings
                // Check permission after user returns
                await Future.delayed(const Duration(seconds: 1));

                // Check if permission is now granted
                final hasPermission = await permissionService.checkManageExternalStoragePermission();

                // Return result to caller
                if (context.mounted) {
                  Navigator.of(context).pop(hasPermission);
                }
              } else if (openResult.isFailure && dialogContext.mounted) {
                // Failed to open settings
                Navigator.pop(dialogContext, false);

                // Show error
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ErrorMessageMapper.getUserMessage(openResult.failure)),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  /// Generate file name based on export option
  String _generateFileName(ExportOption option) {
    final now = DateTime.now();
    final dateStr = '${now.day}_${now.month}_${now.year}';
    final suffix = option == ExportOption.filtered ? 'filtered' : 'all';
    return 'catat_cuan_${dateStr}_$suffix';
  }
}

/// Export option enum
enum ExportOption { all, filtered }

/// Loading dialog for export operation
class _ExportLoadingDialog extends StatelessWidget {
  final ExportAction action;

  const _ExportLoadingDialog({
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AppGlassContainer.glassSurface(
        padding: AppSpacing.xlAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const AppSpacingWidget.verticalLG(),
            Text(
              action == ExportAction.saveToDevice
                  ? 'Menyimpan ke Perangkat...'
                  : 'Membagikan File...',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const AppSpacingWidget.verticalSM(),
            Text(
              'Mohon tunggu sebentar',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
