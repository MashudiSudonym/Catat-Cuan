import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/backup/auth_user.dart';
import 'package:catat_cuan/domain/entities/backup/backup_metadata.dart';
import 'package:catat_cuan/domain/failures/auth_failure.dart';
import 'package:catat_cuan/domain/failures/backup_failure.dart';
import 'package:catat_cuan/domain/repositories/backup/auth_repository.dart';
import 'package:catat_cuan/domain/repositories/backup/backup_write_repository.dart';
import 'package:catat_cuan/domain/usecases/backup/create_backup_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<BackupWriteRepository>(),
  MockSpec<AuthRepository>(),
])
import 'create_backup_usecase_test.mocks.dart';

void main() {
  late CreateBackupUseCase useCase;
  late MockBackupWriteRepository mockBackupRepo;
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockBackupRepo = MockBackupWriteRepository();
    mockAuthRepo = MockAuthRepository();
    useCase = CreateBackupUseCase(
      backupRepo: mockBackupRepo,
      authRepo: mockAuthRepo,
    );
  });

  group('CreateBackupUseCase', () {
    final testMetadata = BackupMetadata(
      version: 1,
      schemaVersion: 4,
      appVersion: '1.0.0',
      deviceModel: 'Test Device',
      createdAt: DateTime.now(),
      dataCounts: {'transactions': 5},
    );

    test('should create backup successfully when already authenticated',
        () async {
      // Arrange - user already signed in
      when(mockAuthRepo.getSignedInUser()).thenAnswer(
        (_) async => Result.success(
          AuthUser(
            email: 'test@gmail.com',
            displayName: 'Test User',
            authHeaders: {'Authorization': 'Bearer token'},
          ),
        ),
      );
      when(mockBackupRepo.createBackup(onProgress: anyNamed('onProgress')))
          .thenAnswer((_) async => Result.success(testMetadata));

      // Act
      final result = await useCase(CreateBackupParams());

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(testMetadata));
      verify(mockAuthRepo.getSignedInUser()).called(1);
      verifyNever(mockAuthRepo.signIn());
      verify(mockBackupRepo.createBackup(onProgress: anyNamed('onProgress')))
          .called(1);
    });

    test('should trigger sign-in when not authenticated', () async {
      // Arrange - no signed in user
      when(mockAuthRepo.getSignedInUser()).thenAnswer(
        (_) async => Result.success(null),
      );
      when(mockAuthRepo.signIn()).thenAnswer(
        (_) async => Result.success(
          AuthUser(
            email: 'test@gmail.com',
            displayName: 'Test User',
            authHeaders: {'Authorization': 'Bearer token'},
          ),
        ),
      );
      when(mockBackupRepo.createBackup(onProgress: anyNamed('onProgress')))
          .thenAnswer((_) async => Result.success(testMetadata));

      // Act
      final result = await useCase(CreateBackupParams());

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockAuthRepo.getSignedInUser()).called(1);
      verify(mockAuthRepo.signIn()).called(1);
      verify(mockBackupRepo.createBackup(onProgress: anyNamed('onProgress')))
          .called(1);
    });

    test('should return failure when sign-in fails', () async {
      // Arrange
      when(mockAuthRepo.getSignedInUser()).thenAnswer(
        (_) async => Result.success(null),
      );
      when(mockAuthRepo.signIn()).thenAnswer(
        (_) async => Result.failure(AuthFailure.cancelled('Dibatalkan')),
      );

      // Act
      final result = await useCase(CreateBackupParams());

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<AuthFailure>());
      verifyNever(
          mockBackupRepo.createBackup(onProgress: anyNamed('onProgress')));
    });

    test('should return failure when backup creation fails', () async {
      // Arrange
      when(mockAuthRepo.getSignedInUser()).thenAnswer(
        (_) async => Result.success(
          AuthUser(
            email: 'test@gmail.com',
            displayName: 'Test User',
            authHeaders: {'Authorization': 'Bearer token'},
          ),
        ),
      );
      when(mockBackupRepo.createBackup(onProgress: anyNamed('onProgress')))
          .thenAnswer(
        (_) async =>
            Result.failure(BackupFailure.network('Koneksi gagal')),
      );

      // Act
      final result = await useCase(CreateBackupParams());

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<BackupFailure>());
    });

    test('should forward progress callback', () async {
      // Arrange
      double? receivedProgress;

      when(mockAuthRepo.getSignedInUser()).thenAnswer(
        (_) async => Result.success(
          AuthUser(
            email: 'test@gmail.com',
            displayName: 'Test User',
            authHeaders: {'Authorization': 'Bearer token'},
          ),
        ),
      );
      when(mockBackupRepo.createBackup(onProgress: anyNamed('onProgress')))
          .thenAnswer((invocation) async {
        // Extract the progress callback and invoke it
        final onProgress = invocation.namedArguments[#onProgress]
            as void Function(double)?;
        if (onProgress != null) {
          onProgress(0.5);
        }
        return Result.success(testMetadata);
      });

      // Act
      final result = await useCase(
        CreateBackupParams(
          onProgress: (progress) {
            receivedProgress = progress;
          },
        ),
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(receivedProgress, equals(0.5));
    });

    test('should handle auth result failure gracefully', () async {
      // Arrange - getSignedInUser returns failure
      when(mockAuthRepo.getSignedInUser()).thenAnswer(
        (_) async =>
            Result.failure(AuthFailure.expired('Token expired')),
      );
      when(mockAuthRepo.signIn()).thenAnswer(
        (_) async => Result.success(
          AuthUser(
            email: 'test@gmail.com',
            displayName: 'Test User',
            authHeaders: {'Authorization': 'Bearer new-token'},
          ),
        ),
      );
      when(mockBackupRepo.createBackup(onProgress: anyNamed('onProgress')))
          .thenAnswer((_) async => Result.success(testMetadata));

      // Act
      final result = await useCase(CreateBackupParams());

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockAuthRepo.signIn()).called(1);
    });
  });
}
