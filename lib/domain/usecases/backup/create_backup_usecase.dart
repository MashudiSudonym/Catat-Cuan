import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/backup/backup_metadata.dart';
import 'package:catat_cuan/domain/repositories/backup/auth_repository.dart';
import 'package:catat_cuan/domain/repositories/backup/backup_write_repository.dart';

/// Parameters for backup creation
class CreateBackupParams {
  /// Optional progress callback (0.0 to 1.0)
  final void Function(double progress)? onProgress;

  const CreateBackupParams({this.onProgress});
}

/// Use case for creating a full backup to Google Drive
///
/// Orchestrates the backup flow:
/// 1. Check if user is authenticated (sign in if not)
/// 2. Create backup via repository (serialize → upload → cleanup)
/// 3. Return backup metadata
///
/// Per D-10: Sign-in on demand when user triggers backup.
class CreateBackupUseCase extends UseCase<BackupMetadata, CreateBackupParams> {
  final BackupWriteRepository _backupRepo;
  final AuthRepository _authRepo;

  CreateBackupUseCase({
    required BackupWriteRepository backupRepo,
    required AuthRepository authRepo,
  })  : _backupRepo = backupRepo,
        _authRepo = authRepo;

  @override
  Future<Result<BackupMetadata>> call(CreateBackupParams params) async {
    // Step 1: Ensure authenticated
    final authResult = await _authRepo.getSignedInUser();
    if (authResult.isFailure || authResult.data == null) {
      final signInResult = await _authRepo.signIn();
      if (signInResult.isFailure) {
        return Result.failure(signInResult.failure!);
      }
    }

    // Step 2: Create backup with progress callback
    return _backupRepo.createBackup(onProgress: params.onProgress);
  }
}
