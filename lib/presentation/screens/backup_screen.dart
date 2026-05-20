import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:catat_cuan/data/services/shared_preferences_service.dart';
import 'package:catat_cuan/domain/entities/backup/backup_metadata.dart';
import 'package:catat_cuan/presentation/controllers/backup_controller.dart';
import 'package:catat_cuan/presentation/navigation/routes/app_routes.dart';
import 'package:catat_cuan/presentation/states/backup_progress.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';

/// Main backup management screen per D-17
///
/// Shows connected account info, backup button, last backup info,
/// and navigation to backup list.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  String? _lastBackupDate;
  String? _connectedEmail;

  @override
  void initState() {
    super.initState();
    _loadBackupMetadata();
  }

  Future<void> _loadBackupMetadata() async {
    final prefs = SharedPreferencesService();
    final date = await prefs.getLastBackupDate();
    final email = await prefs.getConnectedAccountEmail();
    if (mounted) {
      setState(() {
        _lastBackupDate = date;
        _connectedEmail = email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final backupProgress = ref.watch(backupControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: ListView(
        padding: AppSpacing.all(AppSpacing.md),
        children: [
          // Connected account info
          AppGlassContainer.glassCard(
            child: Padding(
              padding: AppSpacing.all(AppSpacing.lg),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 32,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Akun Google',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _connectedEmail ?? 'Belum terhubung',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _connectedEmail != null
                                    ? AppColors.textSecondary
                                    : AppColors.error,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Backup button
          if (backupProgress is BackupProgressIdle ||
              backupProgress is BackupProgressFailed)
            _buildBackupButton(context, ref),

          // Progress display
          if (backupProgress is BackupProgressSerializing ||
              backupProgress is BackupProgressUploading)
            _buildProgressBar(context, backupProgress),

          // Success state
          if (backupProgress is BackupProgressCompleted)
            _buildSuccessState(context, ref, backupProgress.metadata),

          // Error state
          if (backupProgress is BackupProgressFailed)
            Padding(
              padding: AppSpacing.vertical(AppSpacing.md),
              child: Text(
                backupProgress.message,
                style: TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: AppSpacing.lg),

          // Last backup info
          AppGlassContainer.glassCard(
            child: Padding(
              padding: AppSpacing.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Backup Terakhir',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _lastBackupDate != null
                        ? AppDateFormatter.formatDayMonthYearDate(
                            DateTime.parse(_lastBackupDate!),
                          )
                        : 'Belum pernah backup',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Navigate to backup list
          AppGlassContainer.glassCard(
            child: ListTile(
              leading: Icon(
                Icons.list_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              title: const Text('Lihat Daftar Backup'),
              subtitle: const Text('Lihat dan pulihkan backup sebelumnya'),
              trailing: Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
              onTap: () => context.push(AppRoutes.backupList),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await ref.read(backupControllerProvider.notifier).createBackup();
          // Update last backup date after success
          final prefs = SharedPreferencesService();
          await prefs.setLastBackupDate(DateTime.now().toIso8601String());
          if (mounted) {
            setState(() {
              _lastBackupDate = DateTime.now().toIso8601String();
            });
          }
        },
        icon: const Icon(Icons.cloud_upload_outlined),
        label: const Text('Buat Backup'),
        style: ElevatedButton.styleFrom(
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, BackupProgress progress) {
    final String stageLabel;
    final double progressValue;

    if (progress is BackupProgressSerializing) {
      stageLabel = 'Membuat backup...';
      progressValue = 0.0;
    } else if (progress is BackupProgressUploading) {
      stageLabel = 'Mengupload...';
      progressValue = progress.progress;
    } else {
      stageLabel = 'Memproses...';
      progressValue = 0.0;
    }

    return AppGlassContainer.glassCard(
      child: Padding(
        padding: AppSpacing.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              stageLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            LinearProgressIndicator(value: progressValue > 0 ? progressValue : null),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(
    BuildContext context,
    WidgetRef ref,
    BackupMetadata metadata,
  ) {
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
            Text(
              '${metadata.dataCounts['transactions'] ?? 0} transaksi, '
              '${metadata.dataCounts['categories'] ?? 0} kategori tersimpan',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () {
                ref.read(backupControllerProvider.notifier).reset();
              },
              child: const Text('Buat Backup Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
