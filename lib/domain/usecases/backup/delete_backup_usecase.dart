import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/repositories/backup/backup_write_repository.dart';

/// Use case for deleting a backup from Google Drive
///
/// Simple delegation to BackupWriteRepository.deleteBackup().
class DeleteBackupUseCase extends UseCase<void, String> {
  final BackupWriteRepository _backupRepo;

  DeleteBackupUseCase({required BackupWriteRepository backupRepo})
      : _backupRepo = backupRepo;

  @override
  Future<Result<void>> call(String fileId) async {
    return _backupRepo.deleteBackup(fileId);
  }
}
