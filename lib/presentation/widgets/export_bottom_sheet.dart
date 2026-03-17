import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/presentation/providers/export/export_provider.dart';
import 'package:catat_cuan/presentation/providers/transaction/transaction_filter_provider.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';
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
    final exportState = ref.watch(exportNotifierProvider);

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
                        SizedBox(height: 16),
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

  void _handleExport(BuildContext context, WidgetRef ref, ExportOption option) {
    Navigator.pop(context, option);

    DateTime? startDate;
    DateTime? endDate;
    int? categoryId;
    TransactionType? type;

    if (option == ExportOption.filtered) {
      // Apply current filter
      final filterState = ref.read(transactionFilterNotifierProvider);
      startDate = filterState.startDate;
      endDate = filterState.endDate;
      categoryId = filterState.categoryId;
      type = filterState.type;
    }

    // Execute export
    ref.read(exportNotifierProvider.notifier).exportTransactions(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      type: type,
    );

    // Show result
    ref.listen(exportNotifierProvider, (previous, next) {
      if (next.isSuccess && next.isIdle == false) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ekspor berhasil: ${next.filePath}'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Reset state
          ref.read(exportNotifierProvider.notifier).reset();
        }
      } else if (next.isError) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage ?? 'Gagal mengekspor'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Reset state
          ref.read(exportNotifierProvider.notifier).reset();
        }
      }
    });
  }
}

/// Export option enum
enum ExportOption { all, filtered }
