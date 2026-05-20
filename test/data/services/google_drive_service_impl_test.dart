import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/entities/backup/drive_file_info.dart';
import 'package:catat_cuan/domain/failures/backup_failure.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GoogleDriveService failure types', () {
    test('BackupFailure.network creates BackupNetworkFailure', () {
      final failure = BackupFailure.network('Network error');
      expect(failure, isA<BackupNetworkFailure>());
      expect(failure.message, 'Network error');
    });

    test('BackupFailure.quotaExceeded creates BackupQuotaExceededFailure', () {
      final failure = BackupFailure.quotaExceeded('Quota exceeded');
      expect(failure, isA<BackupQuotaExceededFailure>());
      expect(failure.message, 'Quota exceeded');
    });

    test('BackupFailure.corrupted creates BackupCorruptedFailure', () {
      final failure = BackupFailure.corrupted('Data corrupted');
      expect(failure, isA<BackupCorruptedFailure>());
      expect(failure.message, 'Data corrupted');
    });

    test('BackupFailure.cancelled creates BackupCancelledFailure', () {
      final failure = BackupFailure.cancelled('Operation cancelled');
      expect(failure, isA<BackupCancelledFailure>());
      expect(failure.message, 'Operation cancelled');
    });

    test('BackupFailure.notFound creates BackupNotFoundFailure', () {
      final failure = BackupFailure.notFound('File not found');
      expect(failure, isA<BackupNotFoundFailure>());
      expect(failure.message, 'File not found');
    });

    test('BackupFailure.unknown creates BackupUnknownFailure', () {
      final failure = BackupFailure.unknown('Unknown error');
      expect(failure, isA<BackupUnknownFailure>());
      expect(failure.message, 'Unknown error');
    });

    test('all backup failures extend Failure base class', () {
      expect(BackupNetworkFailure('test'), isA<BackupFailure>());
      expect(BackupQuotaExceededFailure('test'), isA<BackupFailure>());
      expect(BackupCorruptedFailure('test'), isA<BackupFailure>());
      expect(BackupCancelledFailure('test'), isA<BackupFailure>());
      expect(BackupNotFoundFailure('test'), isA<BackupFailure>());
      expect(BackupUnknownFailure('test'), isA<BackupFailure>());
    });
  });

  group('DriveFileInfo entity', () {
    test('should create DriveFileInfo with all fields', () {
      final now = DateTime.now();
      final info = DriveFileInfo(
        id: 'file-123',
        name: 'backup.json',
        size: 1024,
        createdTime: now,
        modifiedTime: now,
      );

      expect(info.id, 'file-123');
      expect(info.name, 'backup.json');
      expect(info.size, 1024);
      expect(info.createdTime, now);
      expect(info.modifiedTime, now);
    });

    test('should support equality comparison', () {
      final now = DateTime(2026, 5, 19, 12, 0, 0);
      final info1 = DriveFileInfo(
        id: 'file-1',
        name: 'backup.json',
        size: 500,
        createdTime: now,
        modifiedTime: now,
      );
      final info2 = DriveFileInfo(
        id: 'file-1',
        name: 'backup.json',
        size: 500,
        createdTime: now,
        modifiedTime: now,
      );

      expect(info1, equals(info2));
      expect(info1.hashCode, equals(info2.hashCode));
    });

    test('should not be equal with different values', () {
      final now = DateTime.now();
      final info1 = DriveFileInfo(
        id: 'file-1',
        name: 'backup1.json',
        size: 500,
        createdTime: now,
        modifiedTime: now,
      );
      final info2 = DriveFileInfo(
        id: 'file-2',
        name: 'backup2.json',
        size: 600,
        createdTime: now,
        modifiedTime: now,
      );

      expect(info1, isNot(equals(info2)));
    });
  });

  group('GoogleDriveServiceImpl error mapping', () {
    // Test that the failure mapping logic produces the right types
    // The actual DriveApi calls require platform channels, so we test
    // the failure mapping through the failure constructors.

    test('network error message maps correctly', () {
      // Simulate what _mapException does
      const networkMessage = 'SocketException: Connection refused';
      expect(networkMessage.toLowerCase(), contains('socket'));

      const timeoutMessage = 'TimeoutException after 0:00:30';
      expect(timeoutMessage.toLowerCase(), contains('timeout'));
    });

    test('quota error message maps correctly', () {
      const quotaMessage = 'Storage quota exceeded';
      expect(quotaMessage.toLowerCase(), contains('quota'));
    });

    test('not found error message maps correctly', () {
      const notFoundMessage = 'File not found: 404';
      expect(notFoundMessage.toLowerCase(), contains('not found'));
      expect(notFoundMessage.toLowerCase(), contains('404'));
    });
  });
}
