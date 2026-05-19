import 'package:freezed_annotation/freezed_annotation.dart';

part 'drive_file_info.freezed.dart';

/// Metadata for a Google Drive file in the app data folder
///
/// Contains identifying information and timestamps for
/// backup files stored in the drive.appdata space.
@freezed
abstract class DriveFileInfo with _$DriveFileInfo {
  const factory DriveFileInfo({
    required String id,
    required String name,
    required int size,
    required DateTime createdTime,
    required DateTime modifiedTime,
  }) = _DriveFileInfo;
}
