import 'dart:convert';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/backup/drive_file_info.dart';
import 'package:catat_cuan/domain/repositories/backup/backup_read_repository.dart';
import 'package:catat_cuan/domain/failures/backup_failure.dart';
import 'package:catat_cuan/domain/services/google_drive_service.dart';

/// Implementation of [BackupReadRepository]
///
/// Delegates to [GoogleDriveService] for Drive API operations.
class BackupReadRepositoryImpl implements BackupReadRepository {
  final GoogleDriveService _driveService;

  BackupReadRepositoryImpl({
    required GoogleDriveService driveService,
  }) : _driveService = driveService;

  @override
  Future<Result<List<DriveFileInfo>>> listBackups() async {
    return _driveService.listFiles();
  }

  @override
  Future<Result<BackupPreview>> previewBackup(String fileId) async {
    try {
      // Get file metadata
      final metaResult = await _driveService.getFileMetadata(fileId: fileId);
      if (metaResult.isFailure) {
        return Result.failure(metaResult.failure!);
      }

      final fileInfo = metaResult.data!;

      // Download file to extract header metadata
      final downloadResult = await _driveService.downloadFile(fileId: fileId);
      if (downloadResult.isFailure) {
        return Result.failure(downloadResult.failure!);
      }

      final bytes = downloadResult.data!;
      final jsonString = utf8.decode(bytes);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      // Extract data counts from header
      final dataCounts = <String, int>{};
      final rawCounts = json['data_counts'] as Map<String, dynamic>?;
      if (rawCounts != null) {
        rawCounts.forEach((key, value) {
          dataCounts[key] = value as int;
        });
      }

      return Result.success(
        BackupPreview(
          fileId: fileInfo.id,
          name: fileInfo.name,
          size: fileInfo.size,
          createdAt: fileInfo.createdTime,
          deviceModel: json['device'] as String? ?? 'Unknown',
          dataCounts: dataCounts,
        ),
      );
    } catch (e) {
      return Result.failure(
        BackupFailure.unknown('Gagal memuat preview backup: $e'),
      );
    }
  }
}
