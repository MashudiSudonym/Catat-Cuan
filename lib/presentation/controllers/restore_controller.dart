import 'package:catat_cuan/domain/entities/backup/backup_metadata.dart';
import 'package:catat_cuan/domain/usecases/backup/restore_backup_usecase.dart';
import 'package:catat_cuan/presentation/providers/backup/backup_providers.dart';
import 'package:catat_cuan/presentation/utils/error/error_message_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'restore_controller.g.dart';
part 'restore_controller.freezed.dart';

/// Restore operation progress state
///
/// Per D-14: stages map to "Mengunduh..." → "Memulihkan data..." → "Selesai!"
@freezed
abstract class RestoreProgress with _$RestoreProgress {
  const factory RestoreProgress.idle() = RestoreProgressIdle;
  const factory RestoreProgress.downloading() = RestoreProgressDownloading;
  const factory RestoreProgress.restoring() = RestoreProgressRestoring;
  const factory RestoreProgress.completed(BackupMetadata metadata) =
      RestoreProgressCompleted;
  const factory RestoreProgress.failed(String message) = RestoreProgressFailed;
}

/// Controller for restore operations with progress state
///
/// Manages restore flow with state transitions:
/// idle → downloading → restoring → completed/failed
///
/// Per AGENTS.md: Initialize in build(), NOT constructor.
/// Per D-14: Progress stages map to UI strings.
@riverpod
class RestoreController extends _$RestoreController {
  @override
  RestoreProgress build() => const RestoreProgressIdle();

  /// Restores a backup from Google Drive by its file ID
  ///
  /// Transitions through states:
  /// idle → downloading → restoring → completed/failed
  Future<void> restoreBackup(String fileId) async {
    state = const RestoreProgressDownloading();

    final useCase = ref.read(restoreBackupUseCaseProvider);
    final result = await useCase(
      RestoreBackupParams(
        fileId: fileId,
        onProgress: (progress) {
          if (progress < 0.5) {
            state = const RestoreProgressDownloading();
          } else {
            state = const RestoreProgressRestoring();
          }
        },
      ),
    );

    if (result.isSuccess) {
      state = RestoreProgressCompleted(result.data!);
    } else {
      state = RestoreProgressFailed(
        ErrorMessageMapper.getUserMessage(result.failure),
      );
    }
  }

  /// Resets to idle state
  void reset() {
    state = const RestoreProgressIdle();
  }
}
