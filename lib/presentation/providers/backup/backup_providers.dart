import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/data/repositories/backup/backup_read_repository_impl.dart';
import 'package:catat_cuan/data/repositories/backup/backup_write_repository_impl.dart';
import 'package:catat_cuan/data/services/backup_restore_service.dart';
import 'package:catat_cuan/data/services/backup_serializer_service.dart';
import 'package:catat_cuan/data/services/shared_preferences_service.dart';
import 'package:catat_cuan/domain/repositories/backup/backup_read_repository.dart';
import 'package:catat_cuan/domain/repositories/backup/backup_write_repository.dart';
import 'package:catat_cuan/domain/usecases/backup/create_backup_usecase.dart';
import 'package:catat_cuan/domain/usecases/backup/delete_backup_usecase.dart';
import 'package:catat_cuan/domain/usecases/backup/list_backups_usecase.dart';
import 'package:catat_cuan/domain/usecases/backup/restore_backup_usecase.dart';
import 'package:catat_cuan/presentation/providers/repositories/repository_providers.dart';
import 'package:catat_cuan/presentation/providers/services/service_providers.dart';

/// ============================================================================
/// Cloud Backup Providers
/// ============================================================================

/// Provider for BackupSerializerService
///
/// Takes LocalDataSource and SharedPreferencesService for data access.
final backupSerializerServiceProvider = Provider<BackupSerializerService>((ref) {
  return BackupSerializerService(
    localDataSource: ref.read(localDataSourceProvider),
    sharedPreferencesService: SharedPreferencesService(),
  );
});

/// Provider for BackupRestoreService
///
/// Handles atomic data restoration into local database.
final backupRestoreServiceProvider = Provider<BackupRestoreService>((ref) {
  return BackupRestoreService(
    localDataSource: ref.read(localDataSourceProvider),
  );
});

/// Provider for BackupWriteRepository (abstract type - DIP)
///
/// Following the Dependency Inversion Principle, this provider
/// exposes the abstraction (BackupWriteRepository) rather than the
/// concrete implementation (BackupWriteRepositoryImpl).
final backupWriteRepositoryProvider = Provider<BackupWriteRepository>((ref) {
  return BackupWriteRepositoryImpl(
    serializer: ref.read(backupSerializerServiceProvider),
    driveService: ref.read(googleDriveServiceProvider),
  );
});

/// Provider for BackupReadRepository (abstract type - DIP)
///
/// Following DIP: Exposes the abstraction, not the implementation.
final backupReadRepositoryProvider = Provider<BackupReadRepository>((ref) {
  return BackupReadRepositoryImpl(
    driveService: ref.read(googleDriveServiceProvider),
  );
});

/// Provider for CreateBackupUseCase
///
/// Wires auth and backup repositories for the use case.
final createBackupUseCaseProvider = Provider<CreateBackupUseCase>((ref) {
  return CreateBackupUseCase(
    backupRepo: ref.read(backupWriteRepositoryProvider),
    authRepo: ref.read(authRepositoryProvider),
  );
});

/// Provider for RestoreBackupUseCase
///
/// Wires drive service, serializer, restore service, and auth.
final restoreBackupUseCaseProvider = Provider<RestoreBackupUseCase>((ref) {
  return RestoreBackupUseCase(
    driveService: ref.read(googleDriveServiceProvider),
    serializer: ref.read(backupSerializerServiceProvider),
    restoreService: ref.read(backupRestoreServiceProvider),
    authRepo: ref.read(authRepositoryProvider),
  );
});

/// Provider for ListBackupsUseCase
///
/// Wires drive service and local data source for preview.
final listBackupsUseCaseProvider = Provider<ListBackupsUseCase>((ref) {
  return ListBackupsUseCase(
    driveService: ref.read(googleDriveServiceProvider),
    localDataSource: ref.read(localDataSourceProvider),
  );
});

/// Provider for DeleteBackupUseCase
///
/// Simple delegation to BackupWriteRepository.
final deleteBackupUseCaseProvider = Provider<DeleteBackupUseCase>((ref) {
  return DeleteBackupUseCase(
    backupRepo: ref.read(backupWriteRepositoryProvider),
  );
});

/// Provider for SharedPreferencesService
///
/// Used for backup metadata storage (last backup date, account email).
final sharedPreferencesServiceProvider = Provider<SharedPreferencesService>((ref) {
  return SharedPreferencesService();
});
