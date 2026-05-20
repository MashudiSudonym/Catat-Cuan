import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:catat_cuan/domain/entities/backup/backup_metadata.dart';

part 'backup_progress.freezed.dart';

/// Backup operation progress state
///
/// Represents all possible states during backup creation.
/// Per D-14: stages map to "Membuat backup..." → "Mengupload..." → "Selesai!"
@freezed
abstract class BackupProgress with _$BackupProgress {
  /// No backup operation in progress
  const factory BackupProgress.idle() = BackupProgressIdle;

  /// Serializing database data to JSON
  const factory BackupProgress.serializing() = BackupProgressSerializing;

  /// Uploading to Google Drive with progress (0.0 to 1.0)
  const factory BackupProgress.uploading(double progress) =
      BackupProgressUploading;

  /// Backup completed successfully
  const factory BackupProgress.completed(BackupMetadata metadata) =
      BackupProgressCompleted;

  /// Backup failed with user-friendly Indonesian message
  const factory BackupProgress.failed(String message) = BackupProgressFailed;
}
