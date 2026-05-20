import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_preview.freezed.dart';

/// Preview of a backup for display before restoring
///
/// Shows backup metadata alongside current data counts
/// for comparison (per D-12).
@freezed
abstract class BackupPreview with _$BackupPreview {
  const BackupPreview._();

  const factory BackupPreview({
    /// Google Drive file ID
    required String fileId,

    /// File name on Drive
    required String fileName,

    /// File size in bytes
    required int fileSize,

    /// When the backup was created
    required DateTime backupDate,

    /// Device that created the backup
    required String deviceName,

    /// Row counts per table in the backup
    required Map<String, int> backupDataCounts,

    /// Current row counts per table in the local DB
    required Map<String, int> currentDataCounts,
  }) = _BackupPreview;

  /// Format file size to human-readable string
  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
