/// Backup write repository interface
///
/// Provides operations for creating, deleting, and managing backups
/// on Google Drive. Follows ISP — only write operations here.
library;

import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/backup/backup_metadata.dart';

/// Repository for backup write operations
///
/// Handles backup creation with progress tracking, deletion,
/// and automatic cleanup of old backups (max 5, per D-15).
abstract class BackupWriteRepository {
  /// Creates a full backup and uploads to Google Drive
  ///
  /// [onProgress] - Optional callback with progress 0.0 to 1.0
  ///
  /// Returns the backup metadata on success.
  Future<Result<BackupMetadata>> createBackup({
    void Function(double progress)? onProgress,
  });

  /// Deletes a backup by its Google Drive file ID
  Future<Result<void>> deleteBackup(String fileId);

  /// Removes old backups beyond [maxBackups] count
  ///
  /// Keeps the newest [maxBackups] backups, deletes the rest.
  /// Per D-15: default keeps 5 backups.
  Future<Result<void>> cleanupOldBackups({int maxBackups = 5});
}
