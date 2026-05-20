import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/data/repositories/backup/backup_write_repository_impl.dart';
import 'package:catat_cuan/data/services/backup_serializer_service.dart';
import 'package:catat_cuan/data/services/shared_preferences_service.dart';
import 'package:catat_cuan/domain/repositories/backup/backup_write_repository.dart';
import 'package:catat_cuan/domain/usecases/backup/create_backup_usecase.dart';
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

/// Provider for CreateBackupUseCase
///
/// Wires auth and backup repositories for the use case.
final createBackupUseCaseProvider = Provider<CreateBackupUseCase>((ref) {
  return CreateBackupUseCase(
    backupRepo: ref.read(backupWriteRepositoryProvider),
    authRepo: ref.read(authRepositoryProvider),
  );
});
