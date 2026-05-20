/// Backup read repository interface
///
/// Provides operations for listing and previewing backups.
/// Follows ISP — only read operations here.
library;

import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/backup/drive_file_info.dart';

/// Preview information about a backup file
///
/// Contains metadata extracted from the backup header for
/// display in the backup list without downloading the full file.
class BackupPreview {
  /// Google Drive file ID
  final String fileId;

  /// File name on Drive
  final String name;

  /// File size in bytes
  final int size;

  /// When the backup was created
  final DateTime createdAt;

  /// Device that created the backup
  final String deviceModel;

  /// Row counts per table
  final Map<String, int> dataCounts;

  const BackupPreview({
    required this.fileId,
    required this.name,
    required this.size,
    required this.createdAt,
    required this.deviceModel,
    required this.dataCounts,
  });
}

/// Repository for backup read operations
///
/// Handles listing available backups and previewing their contents.
abstract class BackupReadRepository {
  /// Lists all available backups from Google Drive
  ///
  /// Returns DriveFileInfo ordered by createdTime descending.
  Future<Result<List<DriveFileInfo>>> listBackups();

  /// Previews a backup's metadata without full download
  ///
  /// Downloads only enough to extract the header metadata.
  Future<Result<BackupPreview>> previewBackup(String fileId);
}
