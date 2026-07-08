import 'package:catat_cuan/data/services/backup_serializer_service.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/backup/backup_metadata.dart';
import 'package:catat_cuan/domain/failures/backup_failure.dart';
import 'package:catat_cuan/domain/repositories/backup/backup_write_repository.dart';
import 'package:catat_cuan/domain/services/google_drive_service.dart';

/// Implementation of [BackupWriteRepository]
///
/// Orchestrates backup creation: serialize → upload → cleanup.
/// Delegates to [BackupSerializerService] for data serialization
/// and [GoogleDriveService] for Drive API operations.
class BackupWriteRepositoryImpl implements BackupWriteRepository {
  final BackupSerializerService _serializer;
  final GoogleDriveService _driveService;

  BackupWriteRepositoryImpl({
    required BackupSerializerService serializer,
    required GoogleDriveService driveService,
  })  : _serializer = serializer,
        _driveService = driveService;

  @override
  Future<Result<BackupMetadata>> createBackup({
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Step 1: Serialize all data
      final serializeResult = await _serializer.serialize();
      if (serializeResult.isFailure) {
        return Result.failure(serializeResult.failure!);
      }

      final serialized = serializeResult.data!;

      // Step 2: Upload to Google Drive with progress
      final filename = _serializer.generateFilename();
      final uploadResult = await _driveService.uploadFile(
        name: filename,
        bytes: serialized.bytes,
        onProgress: onProgress,
      );

      if (uploadResult.isFailure) {
        return Result.failure(uploadResult.failure!);
      }

      // Step 3: Cleanup old backups (per D-15: max 5)
      await cleanupOldBackups();

      return Result.success(serialized.metadata);
    } catch (e) {
      return Result.failure(
        BackupFailure.unknown('Gagal membuat backup: $e'),
      );
    }
  }

  @override
  Future<Result<void>> deleteBackup(String fileId) async {
    return _driveService.deleteFile(fileId: fileId);
  }

  @override
  Future<Result<void>> cleanupOldBackups({int maxBackups = 5}) async {
    try {
      final listResult = await _driveService.listFiles();
      if (listResult.isFailure) {
        // Don't fail the backup if cleanup fails — just log
        return Result.success(null);
      }

      final files = listResult.data!;

      // Sort by createdTime descending (newest first)
      files.sort((a, b) => b.createdTime.compareTo(a.createdTime));

      // If more than maxBackups, delete the oldest ones
      if (files.length > maxBackups) {
        final toDelete = files.skip(maxBackups).toList();
        for (final file in toDelete) {
          await _driveService.deleteFile(fileId: file.id);
        }
      }

      return Result.success(null);
    } catch (e) {
      // Don't fail the backup if cleanup fails
      return Result.success(null);
    }
  }
}
