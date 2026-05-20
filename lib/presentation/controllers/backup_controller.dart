import 'package:catat_cuan/domain/usecases/backup/create_backup_usecase.dart';
import 'package:catat_cuan/presentation/providers/backup/backup_providers.dart';
import 'package:catat_cuan/presentation/states/backup_progress.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'backup_controller.g.dart';

/// Controller for backup operations with progress state
///
/// Manages backup creation flow with state transitions:
/// idle → serializing → uploading(progress) → completed/failed
///
/// Per AGENTS.md: Initialize in build(), NOT constructor.
/// Per D-14: Progress stages map to UI strings.
@riverpod
class BackupController extends _$BackupController {
  @override
  BackupProgress build() => const BackupProgressIdle();

  /// Creates a full backup to Google Drive
  ///
  /// Transitions through states: idle → serializing → uploading → completed/failed
  Future<void> createBackup() async {
    state = const BackupProgressSerializing();

    final useCase = ref.read(createBackupUseCaseProvider);
    final result = await useCase(
      CreateBackupParams(
        onProgress: (progress) {
          state = BackupProgressUploading(progress);
        },
      ),
    );

    if (result.isSuccess) {
      state = BackupProgressCompleted(result.data!);
    } else {
      state = BackupProgressFailed(
        ErrorMessageMapper.getUserMessage(result.failure),
      );
    }
  }

  /// Resets to idle state
  void reset() {
    state = const BackupProgressIdle();
  }
}
