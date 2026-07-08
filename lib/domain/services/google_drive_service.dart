/// Google Drive service interface for domain layer
///
/// Defines the contract for Google Drive API operations within the
/// app data folder (drive.appdata scope). Follows the Dependency
/// Inversion Principle (DIP) by providing an abstraction for
/// the domain layer.
library;

import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/backup/drive_file_info.dart';

/// Service for Google Drive API operations in the app data folder
///
/// All operations are scoped to the app data folder — no access
/// to the user's personal Drive files.
abstract class GoogleDriveService {
  /// Uploads a file to the Google Drive app data folder
  ///
  /// [name] - The file name on Drive
  /// [bytes] - The file content as byte list
  /// [onProgress] - Optional progress callback (0.0 to 1.0)
  ///
  /// Returns:
  /// - Result.success(String) with the Drive file ID
  /// - Result.failure(BackupFailure) if upload fails
  Future<Result<String>> uploadFile({
    required String name,
    required List<int> bytes,
    void Function(double progress)? onProgress,
  });

  /// Downloads a file from Google Drive by its ID
  ///
  /// [fileId] - The Google Drive file ID
  ///
  /// Returns:
  /// - Result.success(List `int`) with the file content bytes
  /// - Result.failure(BackupFailure) if download fails
  Future<Result<List<int>>> downloadFile({required String fileId});

  /// Lists all files in the app data folder
  ///
  /// Returns files ordered by createdTime descending (newest first).
  ///
  /// Returns:
  /// - Result.success(List `DriveFileInfo`) with file metadata
  /// - Result.failure(BackupFailure) if listing fails
  Future<Result<List<DriveFileInfo>>> listFiles();

  /// Deletes a file from Google Drive by its ID
  ///
  /// [fileId] - The Google Drive file ID
  ///
  /// Returns:
  /// - Result.success(null) on successful deletion
  /// - Result.failure(BackupFailure) if deletion fails
  Future<Result<void>> deleteFile({required String fileId});

  /// Gets metadata for a specific file
  ///
  /// [fileId] - The Google Drive file ID
  ///
  /// Returns:
  /// - Result.success(DriveFileInfo) with file metadata
  /// - Result.failure(BackupFailure) if file not found or error
  Future<Result<DriveFileInfo>> getFileMetadata({required String fileId});
}
