import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/backup/backup_preview.dart' as bp;
import 'package:catat_cuan/presentation/navigation/routes/app_routes.dart';
import 'package:catat_cuan/presentation/providers/backup/backup_providers.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';
import 'package:catat_cuan/presentation/utils/utils.dart';
import 'package:catat_cuan/presentation/widgets/base/base.dart';

/// Screen showing list of available backups as glass cards per D-16
class BackupListScreen extends ConsumerStatefulWidget {
  const BackupListScreen({super.key});

  @override
  ConsumerState<BackupListScreen> createState() => _BackupListScreenState();
}

class _BackupListScreenState extends ConsumerState<BackupListScreen> {
  List<bp.BackupPreview>? _backups;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final useCase = ref.read(listBackupsUseCaseProvider);
      final result = await useCase(NoParams());
      if (!mounted) return;
      setState(() {
        if (result.isSuccess) {
          _backups = result.data!;
        } else {
          _error = ErrorMessageMapper.getUserMessage(result.failure);
        }
      });
    } finally {
      // Guarantee the spinner clears on every exit path (BKP-03). The use
      // case returns a Result rather than throwing, but the finally also
      // covers any unexpected throw so the list is never stuck loading.
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Backup'),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: AppSpacing.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: AppSpacing.md),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: _loadBackups,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_backups == null || _backups!.isEmpty) {
      return Center(
        child: AppEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Belum ada backup',
          subtitle: 'Backup pertama Anda akan muncul di sini',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBackups,
      child: ListView.builder(
        padding: AppSpacing.all(AppSpacing.md),
        itemCount: _backups!.length,
        itemBuilder: (context, index) {
          final backup = _backups![index];
          return _BackupCard(
            backup: backup,
            onTap: () => context.push(
              '${AppRoutes.backupPreview}?fileId=${backup.fileId}',
            ),
            onDelete: () => _confirmDelete(context, backup),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    bp.BackupPreview backup,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Backup?'),
        content: Text(
          'Backup dari ${AppDateFormatter.formatDayMonthYearDate(backup.backupDate)} '
          'akan dihapus secara permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final useCase = ref.read(deleteBackupUseCaseProvider);
    final result = await useCase(backup.fileId);
    if (!mounted) return;
    if (result.isSuccess) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Backup dihapus')),
      );
      try {
        await _loadBackups();
      } catch (e) {
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(ErrorMessageMapper.getUserMessage(e))),
        );
      }
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(ErrorMessageMapper.getUserMessage(result.failure)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

/// Single backup item as a glass card per D-16
class _BackupCard extends StatelessWidget {
  final bp.BackupPreview backup;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BackupCard({
    required this.backup,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.vertical(AppSpacing.sm),
      child: Dismissible(
        key: ValueKey(backup.fileId),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          onDelete();
          return false; // We handle deletion in the callback
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: AppSpacing.horizontal(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: AppRadius.mdAll,
          ),
          child: Icon(Icons.delete_outline, color: AppColors.error),
        ),
        child: AppGlassContainer.glassCard(
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.mdAll,
            child: Padding(
              padding: AppSpacing.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and size row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppDateFormatter.formatDayMonthYearDate(backup.backupDate),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Text(
                        backup.formattedSize,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Device name
                  Row(
                    children: [
                      Icon(
                        Icons.phone_android,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        backup.deviceName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Data summary
                  Text(
                    _buildDataSummary(backup.backupDataCounts),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildDataSummary(Map<String, int> counts) {
    final parts = <String>[];
    final tx = counts['transactions'] ?? 0;
    final cat = counts['categories'] ?? 0;
    final bud = counts['budgets'] ?? 0;
    final sav = counts['savings_goals'] ?? 0;

    if (tx > 0) parts.add('$tx transaksi');
    if (cat > 0) parts.add('$cat kategori');
    if (bud > 0) parts.add('$bud anggaran');
    if (sav > 0) parts.add('$sav tujuan');

    return parts.isEmpty ? 'Tidak ada data' : parts.join(', ');
  }
}
