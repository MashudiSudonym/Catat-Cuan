import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/backup/auth_user.dart';
import 'package:catat_cuan/domain/entities/backup/backup_data.dart';
import 'package:catat_cuan/domain/failures/auth_failure.dart';
import 'package:catat_cuan/domain/failures/backup_failure.dart';
import 'package:catat_cuan/domain/repositories/backup/auth_repository.dart';
import 'package:catat_cuan/domain/services/google_drive_service.dart';
import 'package:catat_cuan/data/services/backup_serializer_service.dart';
import 'package:catat_cuan/data/services/backup_restore_service.dart';
import 'package:catat_cuan/domain/usecases/backup/restore_backup_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<GoogleDriveService>(),
  MockSpec<BackupSerializerService>(),
  MockSpec<BackupRestoreService>(),
  MockSpec<AuthRepository>(),
])
import 'restore_backup_usecase_test.mocks.dart';

void main() {
  late RestoreBackupUseCase useCase;
  late MockGoogleDriveService mockDriveService;
  late MockBackupSerializerService mockSerializer;
  late MockBackupRestoreService mockRestoreService;
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockDriveService = MockGoogleDriveService();
    mockSerializer = MockBackupSerializerService();
    mockRestoreService = MockBackupRestoreService();
    mockAuthRepo = MockAuthRepository();
    useCase = RestoreBackupUseCase(
      driveService: mockDriveService,
      serializer: mockSerializer,
      restoreService: mockRestoreService,
      authRepo: mockAuthRepo,
    );
  });

  group('RestoreBackupUseCase', () {
    final testBackupData = BackupData(
      transactions: [],
      categories: [],
      budgets: [],
      savingsGoals: [],
      goalContributions: [],
      settings: {},
    );

    final testBytes = [1, 2, 3, 4, 5];

    test('should restore backup successfully when authenticated', () async {
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
      when(mockDriveService.downloadFile(fileId: 'file123'))
          .thenAnswer((_) async => Result.success(testBytes));
      when(mockSerializer.deserialize(testBytes))
          .thenAnswer((_) async => Result.success(testBackupData));
      when(mockRestoreService.restoreFromData(testBackupData))
          .thenAnswer((_) async => Result.success(null));

      // Act
      final result = await useCase(
        RestoreBackupParams(fileId: 'file123'),
      );

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockDriveService.downloadFile(fileId: 'file123')).called(1);
      verify(mockSerializer.deserialize(testBytes)).called(1);
      verify(mockRestoreService.restoreFromData(testBackupData)).called(1);
    });

    test('should trigger sign-in when not authenticated', () async {
      // Arrange
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
      when(mockDriveService.downloadFile(fileId: 'file123'))
          .thenAnswer((_) async => Result.success(testBytes));
      when(mockSerializer.deserialize(testBytes))
          .thenAnswer((_) async => Result.success(testBackupData));
      when(mockRestoreService.restoreFromData(testBackupData))
          .thenAnswer((_) async => Result.success(null));

      // Act
      final result = await useCase(
        RestoreBackupParams(fileId: 'file123'),
      );

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockAuthRepo.signIn()).called(1);
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
      final result = await useCase(
        RestoreBackupParams(fileId: 'file123'),
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<AuthFailure>());
      verifyNever(mockDriveService.downloadFile(fileId: anyNamed('fileId')));
    });

    test('should return failure when download fails', () async {
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
      when(mockDriveService.downloadFile(fileId: 'file123')).thenAnswer(
        (_) async => Result.failure(BackupFailure.network('Koneksi gagal')),
      );

      // Act
      final result = await useCase(
        RestoreBackupParams(fileId: 'file123'),
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<BackupFailure>());
      verifyNever(mockSerializer.deserialize(any));
    });

    test('should return failure when deserialization fails', () async {
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
      when(mockDriveService.downloadFile(fileId: 'file123'))
          .thenAnswer((_) async => Result.success(testBytes));
      when(mockSerializer.deserialize(testBytes)).thenAnswer(
        (_) async =>
            Result.failure(BackupFailure.corrupted('Data rusak')),
      );

      // Act
      final result = await useCase(
        RestoreBackupParams(fileId: 'file123'),
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<BackupFailure>());
      verifyNever(mockRestoreService.restoreFromData(any));
    });

    test('should return failure when restore fails', () async {
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
      when(mockDriveService.downloadFile(fileId: 'file123'))
          .thenAnswer((_) async => Result.success(testBytes));
      when(mockSerializer.deserialize(testBytes))
          .thenAnswer((_) async => Result.success(testBackupData));
      when(mockRestoreService.restoreFromData(testBackupData)).thenAnswer(
        (_) async => Result.failure(
            BackupFailure.unknown('Gagal memulihkan data')),
      );

      // Act
      final result = await useCase(
        RestoreBackupParams(fileId: 'file123'),
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<BackupFailure>());
    });

    test('should forward progress callbacks through pipeline', () async {
      // Arrange
      final progressCalls = <double>[];

      when(mockAuthRepo.getSignedInUser()).thenAnswer(
        (_) async => Result.success(
          AuthUser(
            email: 'test@gmail.com',
            displayName: 'Test User',
            authHeaders: {'Authorization': 'Bearer token'},
          ),
        ),
      );
      when(mockDriveService.downloadFile(fileId: 'file123'))
          .thenAnswer((_) async => Result.success(testBytes));
      when(mockSerializer.deserialize(testBytes))
          .thenAnswer((_) async => Result.success(testBackupData));
      when(mockRestoreService.restoreFromData(testBackupData))
          .thenAnswer((_) async => Result.success(null));

      // Act
      final result = await useCase(
        RestoreBackupParams(
          fileId: 'file123',
          onProgress: (progress) {
            progressCalls.add(progress);
          },
        ),
      );

      // Assert
      expect(result.isSuccess, isTrue);
      // Progress: 0.0 (download start), 0.5 (after download), 1.0 (after restore)
      expect(progressCalls, containsAll([0.0, 0.5, 1.0]));
    });
  });
}
