/// Backup failure types
///
/// Represents various errors that can occur during backup/restore
/// operations including network, quota, corruption, and cancellation.
library;

import 'package:catat_cuan/domain/failures/failure.dart';

/// Base class for backup-related failures
class BackupFailure extends Failure {
  const BackupFailure._(super.message);

  /// Network error during backup/restore
  factory BackupFailure.network(String message) = BackupNetworkFailure;

  /// Google Drive storage quota exceeded
  factory BackupFailure.quotaExceeded(String message) = BackupQuotaExceededFailure;

  /// Backup data is corrupted or invalid
  factory BackupFailure.corrupted(String message) = BackupCorruptedFailure;

  /// User cancelled the backup/restore operation
  factory BackupFailure.cancelled(String message) = BackupCancelledFailure;

  /// Backup file not found on Google Drive
  factory BackupFailure.notFound(String message) = BackupNotFoundFailure;

  /// Unknown backup error
  factory BackupFailure.unknown(String message) = BackupUnknownFailure;
}

/// Network error during backup
class BackupNetworkFailure extends BackupFailure {
  const BackupNetworkFailure(super.message) : super._();
}

/// Quota exceeded failure
class BackupQuotaExceededFailure extends BackupFailure {
  const BackupQuotaExceededFailure(super.message) : super._();
}

/// Corrupted backup data
class BackupCorruptedFailure extends BackupFailure {
  const BackupCorruptedFailure(super.message) : super._();
}

/// User cancelled operation
class BackupCancelledFailure extends BackupFailure {
  const BackupCancelledFailure(super.message) : super._();
}

/// Backup not found
class BackupNotFoundFailure extends BackupFailure {
  const BackupNotFoundFailure(super.message) : super._();
}

/// Unknown backup error
class BackupUnknownFailure extends BackupFailure {
  const BackupUnknownFailure(super.message) : super._();
}
