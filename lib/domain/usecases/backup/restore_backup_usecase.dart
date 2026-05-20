import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/backup/backup_metadata.dart';
import 'package:catat_cuan/domain/repositories/backup/auth_repository.dart';
import 'package:catat_cuan/domain/services/google_drive_service.dart';
import 'package:catat_cuan/data/services/backup_serializer_service.dart';
import 'package:catat_cuan/data/services/backup_restore_service.dart';

/// Parameters for restore backup operation
class RestoreBackupParams {
  /// Google Drive file ID to restore
  final String fileId;

  /// Optional progress callback (0.0 to 1.0)
  final void Function(double progress)? onProgress;

  const RestoreBackupParams({
    required this.fileId,
    this.onProgress,
  });
}

/// Use case for restoring a backup from Google Drive
///
/// Orchestrates the restore flow:
/// 1. Ensure user is authenticated (sign in if needed)
/// 2. Download backup file from Drive
/// 3. Deserialize backup data
/// 4. Restore data to local database (atomic transaction)
/// 5. Return backup metadata
///
/// Per D-10: Sign-in on demand when user triggers restore.
/// Per T-04-09: Atomic restore — either all data restored or none.
class RestoreBackupUseCase extends UseCase<BackupMetadata, RestoreBackupParams> {
  final GoogleDriveService _driveService;
  final BackupSerializerService _serializer;
  final BackupRestoreService _restoreService;
  final AuthRepository _authRepo;

  RestoreBackupUseCase({
    required GoogleDriveService driveService,
    required BackupSerializerService serializer,
    required BackupRestoreService restoreService,
    required AuthRepository authRepo,
  })  : _driveService = driveService,
        _serializer = serializer,
        _restoreService = restoreService,
        _authRepo = authRepo;

  @override
  Future<Result<BackupMetadata>> call(RestoreBackupParams params) async {
    // Step 1: Ensure authenticated
    final authResult = await _authRepo.getSignedInUser();
    if (authResult.isFailure || authResult.data == null) {
      final signInResult = await _authRepo.signIn();
      if (signInResult.isFailure) {
        return Result.failure(signInResult.failure!);
      }
    }

    // Step 2: Download backup file
    params.onProgress?.call(0.0);
    final downloadResult = await _driveService.downloadFile(
      fileId: params.fileId,
    );
    if (downloadResult.isFailure) {
      return Result.failure(downloadResult.failure!);
    }

    // Step 3: Deserialize backup data
    params.onProgress?.call(0.5);
    final deserializeResult = await _serializer.deserialize(
      downloadResult.data!,
    );
    if (deserializeResult.isFailure) {
      return Result.failure(deserializeResult.failure!);
    }

    // Step 4: Restore to local database
    final restoreResult = await _restoreService.restoreFromData(
      deserializeResult.data!,
    );
    if (restoreResult.isFailure) {
      return Result.failure(restoreResult.failure!);
    }

    // Step 5: Return metadata from deserialized data
    params.onProgress?.call(1.0);

    final backupData = deserializeResult.data!;
    return Result.success(
      BackupMetadata(
        version: 1,
        schemaVersion: 4,
        appVersion: '1.0.0',
        deviceModel: 'Restored Device',
        createdAt: DateTime.now(),
        dataCounts: {
          'transactions': backupData.transactions.length,
          'categories': backupData.categories.length,
          'budgets': backupData.budgets.length,
          'savings_goals': backupData.savingsGoals.length,
          'goal_contributions': backupData.goalContributions.length,
        },
      ),
    );
  }
}
