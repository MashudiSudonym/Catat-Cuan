import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_metadata.freezed.dart';
part 'backup_metadata.g.dart';

/// Metadata header for a backup file
///
/// Contains versioning and device information about the backup,
/// used for compatibility checks and preview display.
@freezed
abstract class BackupMetadata with _$BackupMetadata {
  const BackupMetadata._();

  const factory BackupMetadata({
    /// Backup format version (starts at 1)
    required int version,

    /// DB schema version at backup time
    required int schemaVersion,

    /// App version that created the backup
    required String appVersion,

    /// Device model that created the backup
    required String deviceModel,

    /// When the backup was created
    required DateTime createdAt,

    /// Table name → row count
    required Map<String, int> dataCounts,
  }) = _BackupMetadata;

  factory BackupMetadata.fromJson(Map<String, dynamic> json) =>
      _$BackupMetadataFromJson(json);
}
