import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/domain/entities/backup/backup_preview.dart' as bp;
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/presentation/controllers/restore_controller.dart';
import 'package:catat_cuan/presentation/providers/backup/backup_providers.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';

/// Preview screen showing backup contents before restore per D-12
///
/// Shows backup metadata, data comparison table, and destructive
/// confirm dialog per D-13.
class BackupPreviewScreen extends ConsumerStatefulWidget {
  final String fileId;

  const BackupPreviewScreen({super.key, required this.fileId});

  @override
  ConsumerState<BackupPreviewScreen> createState() => _BackupPreviewScreenState();
}

class _BackupPreviewScreenState extends ConsumerState<BackupPreviewScreen> {
  bp.BackupPreview? _preview;
  bool _isLoading = true;
  String? _error;
  final _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _loadPreview() async {
    final useCase = ref.read(listBackupsUseCaseProvider);
    final result = await useCase(NoParams());

    if (mounted) {
      if (result.isSuccess) {
        final preview = result.data!.where((p) => p.fileId == widget.fileId).firstOrNull;
        if (preview != null) {
          setState(() {
            _preview = preview;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'Backup tidak ditemukan';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = ErrorMessageMapper.getUserMessage(result.failure);
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final restoreProgress = ref.watch(restoreControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Backup'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(context)
              : _buildContent(context, restoreProgress),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(_error!, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, RestoreProgress progress) {
    final preview = _preview!;

    return ListView(
      padding: AppSpacing.all(AppSpacing.md),
      children: [
        // Backup metadata card
        AppGlassContainer.glassCard(
          child: Padding(
            padding: AppSpacing.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Backup',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildInfoRow(context, Icons.calendar_today, 'Tanggal',
                    AppDateFormatter.formatDayMonthYearDate(preview.backupDate)),
                _buildInfoRow(context, Icons.phone_android, 'Perangkat', preview.deviceName),
                _buildInfoRow(context, Icons.storage, 'Ukuran', preview.formattedSize),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Data comparison table per D-12
        AppGlassContainer.glassCard(
          child: Padding(
            padding: AppSpacing.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perbandingan Data',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Header row
                Padding(
                  padding: AppSpacing.vertical(AppSpacing.xs),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Data',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Backup',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Saat Ini',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Data rows
                _buildDataRow(context, 'Transaksi',
                    preview.backupDataCounts['transactions'] ?? 0,
                    preview.currentDataCounts['transactions'] ?? 0),
                _buildDataRow(context, 'Kategori',
                    preview.backupDataCounts['categories'] ?? 0,
                    preview.currentDataCounts['categories'] ?? 0),
                _buildDataRow(context, 'Anggaran',
                    preview.backupDataCounts['budgets'] ?? 0,
                    preview.currentDataCounts['budgets'] ?? 0),
                _buildDataRow(context, 'Tujuan',
                    preview.backupDataCounts['savings_goals'] ?? 0,
                    preview.currentDataCounts['savings_goals'] ?? 0),
                _buildDataRow(context, 'Setoran',
                    preview.backupDataCounts['goal_contributions'] ?? 0,
                    preview.currentDataCounts['goal_contributions'] ?? 0),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Restore progress or button
        if (progress is RestoreProgressIdle || progress is RestoreProgressFailed)
          _buildRestoreButton(context),

        if (progress is RestoreProgressDownloading || progress is RestoreProgressRestoring)
          _buildRestoreProgress(context, progress),

        if (progress is RestoreProgressCompleted)
          _buildRestoreSuccess(context),

        if (progress is RestoreProgressFailed)
          Padding(
            padding: AppSpacing.vertical(AppSpacing.sm),
            child: Text(
              progress.message,
              style: TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: AppSpacing.vertical(AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, String label, int backupCount, int currentCount) {
    return Padding(
      padding: AppSpacing.vertical(AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              '$backupCount',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '$currentCount',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: backupCount != currentCount ? AppColors.error : null,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showDestructiveConfirmDialog(context),
        icon: const Icon(Icons.restore),
        label: const Text('Pulihkan Data'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }

  Widget _buildRestoreProgress(BuildContext context, RestoreProgress progress) {
    final String stageLabel;
    if (progress is RestoreProgressDownloading) {
      stageLabel = 'Mengunduh...';
    } else {
      stageLabel = 'Memulihkan data...';
    }

    return AppGlassContainer.glassCard(
      child: Padding(
        padding: AppSpacing.all(AppSpacing.lg),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
            Text(
              stageLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestoreSuccess(BuildContext context) {
    return AppGlassContainer.glassCard(
      child: Padding(
        padding: AppSpacing.all(AppSpacing.lg),
        child: Column(
          children: [
            Icon(Icons.check_circle, color: AppColors.primary, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Selesai!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text('Data berhasil dipulihkan'),
          ],
        ),
      ),
    );
  }

  /// Destructive confirm dialog per D-13
  ///
  /// User must type "GANTI" to confirm.
  Future<void> _showDestructiveConfirmDialog(BuildContext context) async {
    _confirmController.clear();
    bool canConfirm = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Pulihkan Data?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Semua data saat ini akan diganti dengan data backup. '
                    'Tindakan ini tidak dapat dibatalkan.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Show current vs backup data counts
                  if (_preview != null) ...[
                    Text(
                      'Backup: ${_buildDataSummary(_preview!.backupDataCounts)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      'Saat ini: ${_buildDataSummary(_preview!.currentDataCounts)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Ketik "GANTI" untuk mengkonfirmasi:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _confirmController,
                    onChanged: (value) {
                      setDialogState(() {
                        canConfirm = value.trim() == 'GANTI';
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'GANTI',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: canConfirm
                      ? () {
                          Navigator.pop(dialogContext);
                          _executeRestore();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canConfirm ? AppColors.error : null,
                  ),
                  child: const Text('Pulihkan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _executeRestore() {
    ref.read(restoreControllerProvider.notifier).restoreBackup(widget.fileId);
  }

  String _buildDataSummary(Map<String, int> counts) {
    final tx = counts['transactions'] ?? 0;
    final cat = counts['categories'] ?? 0;
    return '$tx transaksi, $cat kategori';
  }
}
