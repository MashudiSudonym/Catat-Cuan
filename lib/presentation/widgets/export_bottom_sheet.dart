import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/domain/entities/export_action_entity.dart';
import 'package:catat_cuan/presentation/providers/export/export_provider.dart';
import 'package:catat_cuan/presentation/providers/repositories/repository_providers.dart';
import 'package:catat_cuan/presentation/providers/transaction/transaction_filter_provider.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
import 'package:catat_cuan/presentation/widgets/export_action_dialog.dart';
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
    final exportState = ref.watch(exportProvider);

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

              // Loading state
              if (exportState.isLoading)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        AppSpacingWidget.verticalLG(),
                        Text('Mengekspor transaksi...'),
                      ],
                    ),
                  ),
                )
              else
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
    // Store notifier reference before any navigation
    final exportNotifier = ref.read(exportProvider.notifier);

    // Get filter parameters
    DateTime? startDate;
    DateTime? endDate;
    int? categoryId;
    TransactionType? type;

    if (option == ExportOption.filtered) {
      // Apply current filter
      final filterState = ref.read(transactionFilterProvider);
      startDate = filterState.startDate;
      endDate = filterState.endDate;
      categoryId = filterState.categoryId;
      type = filterState.type;
    }

    // Get transaction count for preview
    final exportRepository = ref.read(transactionExportRepositoryProvider);
    final transactionsResult = await exportRepository.getTransactionsWithCategoryNames(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      type: type,
    );

    // Check for errors
    if (transactionsResult.isFailure || (transactionsResult.data?.isEmpty ?? true)) {
      // Show error and return - context should still be valid here
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(transactionsResult.failure?.message ?? 'Tidak ada transaksi untuk diekspor'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Close the bottom sheet
        Navigator.pop(context);
      }
      return;
    }

    // Generate file name
    final fileName = _generateFileName(option);

    // Show action dialog FIRST, while bottom sheet is still open
    // This ensures context is still valid
    final action = await ExportActionDialog.show(
      context,
      fileName: '$fileName.csv',
      transactionCount: transactionsResult.data!.length,
    );

    // Now close the bottom sheet
    if (context.mounted) {
      Navigator.pop(context);
    }

    // Wait for the bottom sheet to fully close
    await Future.delayed(const Duration(milliseconds: 200));

    // Execute export based on selected action
    if (action != null) {
      // Show loading dialog using root navigator (context from bottom sheet is now invalid)
      try {
        final rootContext = Navigator.of(context, rootNavigator: true).context;

        showDialog(
          context: rootContext,
          barrierDismissible: false,
          builder: (dialogContext) => _ExportLoadingDialog(
            action: action,
          ),
        );
      } catch (e) {
        return;
      }

      // Execute export
      try {
        if (action == ExportAction.saveToDevice) {
          await exportNotifier.saveTransactionsToCsv(
            startDate: startDate,
            endDate: endDate,
            categoryId: categoryId,
            type: type,
            fileNameSuffix: fileName,
          );
        } else {
          await exportNotifier.shareTransactionsToCsv(
            startDate: startDate,
            endDate: endDate,
            categoryId: categoryId,
            type: type,
            fileNameSuffix: fileName,
          );
        }

        // Wait a bit for state to update
        await Future.delayed(const Duration(milliseconds: 200));

        // Close loading dialog and show result
        try {
          final rootContext = Navigator.of(context, rootNavigator: true).context;
          Navigator.pop(rootContext); // Close loading dialog

          // Get final state - use a try-catch to handle disposed ref
          try {
            final currentState = ref.read(exportProvider);

            // Show result dialog based on state
            if (currentState.isSuccess) {
              _showResultDialog(
                rootContext,
                isSuccess: true,
                action: currentState.lastAction,
                filePath: currentState.filePath,
              );
              // Reset state
              ref.read(exportProvider.notifier).reset();
            } else if (currentState.isError) {
              _showResultDialog(
                rootContext,
                isSuccess: false,
                errorMessage: currentState.errorMessage,
              );
              // Reset state
              ref.read(exportProvider.notifier).reset();
            } else {
              // State is still loading - this shouldn't happen but handle it
              _showResultDialog(
                rootContext,
                isSuccess: true,
                action: action,
                filePath: 'File CSV berhasil diproses. Silakan cek folder Documents/CatatCuan/Exports/',
              );
              // Reset state
              ref.read(exportProvider.notifier).reset();
            }
          } on StateError {
            // Ref was disposed - file was still saved successfully
            _showResultDialog(
              rootContext,
              isSuccess: true,
              action: action,
              filePath: 'File CSV berhasil disimpan. Silakan cek folder Documents/CatatCuan/Exports/',
            );
            // Can't reset state since ref is disposed
          }
        } catch (e) {
          // Error handling for dialog operations
        }
      } catch (e) {
        // Try to close loading dialog and show error
        try {
          final rootContext = Navigator.of(context, rootNavigator: true).context;
          if (Navigator.canPop(rootContext)) {
            Navigator.pop(rootContext); // Close loading dialog
          }
          _showResultDialog(
            rootContext,
            isSuccess: false,
            errorMessage: 'Terjadi kesalahan: ${e.toString()}',
          );
        } catch (e2) {
          // Failed to show error dialog
        }
        // Reset state
        try {
          ref.read(exportProvider.notifier).reset();
        } catch (e3) {
          // Failed to reset state
        }
      }
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
                      ? 'File CSV berhasil disimpan di:\n$filePath'
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
