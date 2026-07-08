/// Google Drive API implementation of GoogleDriveService
///
/// Uses the googleapis package to interact with the Drive API
/// within the app data folder (drive.appdata scope).
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/backup/drive_file_info.dart';
import 'package:catat_cuan/domain/failures/backup_failure.dart';
import 'package:catat_cuan/domain/services/google_drive_service.dart';

/// Authenticated HTTP client for Google APIs
class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner;

  _GoogleAuthClient(this._headers) : _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}

/// Implementation of GoogleDriveService using googleapis
///
/// All operations are scoped to the appDataFolder — no access
/// to the user's personal Drive files (T-04-04 mitigation).
class GoogleDriveServiceImpl implements GoogleDriveService {
  final Map<String, String> Function() _authHeadersProvider;

  GoogleDriveServiceImpl(this._authHeadersProvider);

  /// Creates an authenticated DriveApi client
  drive.DriveApi _createDriveApi() {
    final headers = _authHeadersProvider();
    if (headers.isEmpty) {
      throw BackupCancelledFailure(
        'Belum masuk akun Google. Silakan masuk kembali.',
      );
    }
    final client = _GoogleAuthClient(headers);
    return drive.DriveApi(client);
  }

  @override
  Future<Result<String>> uploadFile({
    required String name,
    required List<int> bytes,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final driveApi = _createDriveApi();

      final file = drive.File()
        ..name = name
        ..parents = ['appDataFolder'];

      final media = drive.Media(
        Stream.value(bytes),
        bytes.length,
        contentType: 'application/json',
      );

      final uploaded = await driveApi.files.create(
        file,
        uploadMedia: media,
        $fields: 'id',
      );

      // Report completion
      onProgress?.call(1.0);

      return Result.success(uploaded.id!);
    } on BackupFailure catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(_mapException(e));
    }
  }

  @override
  Future<Result<List<int>>> downloadFile({required String fileId}) async {
    try {
      final driveApi = _createDriveApi();

      final media = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final bytesBuilder = BytesBuilder();
      await for (final chunk in media.stream) {
        bytesBuilder.add(chunk);
      }

      return Result.success(bytesBuilder.toBytes());
    } on BackupFailure catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(_mapException(e));
    }
  }

  @override
  Future<Result<List<DriveFileInfo>>> listFiles() async {
    try {
      final driveApi = _createDriveApi();

      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        orderBy: 'createdTime desc',
        $fields: 'files(id,name,size,createdTime,modifiedTime)',
      );

      final files = fileList.files?.map((f) {
        return DriveFileInfo(
          id: f.id!,
          name: f.name!,
          size: int.tryParse(f.size ?? '0') ?? 0,
          createdTime: f.createdTime!,
          modifiedTime: f.modifiedTime!,
        );
      }).toList() ?? [];

      return Result.success(files);
    } on BackupFailure catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(_mapException(e));
    }
  }

  @override
  Future<Result<void>> deleteFile({required String fileId}) async {
    try {
      final driveApi = _createDriveApi();
      await driveApi.files.delete(fileId);
      return Result.success(null);
    } on BackupFailure catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(_mapException(e));
    }
  }

  @override
  Future<Result<DriveFileInfo>> getFileMetadata({required String fileId}) async {
    try {
      final driveApi = _createDriveApi();

      final file = await driveApi.files.get(
        fileId,
        $fields: 'id,name,size,createdTime,modifiedTime',
      ) as drive.File;

      return Result.success(
        DriveFileInfo(
          id: file.id!,
          name: file.name!,
          size: int.tryParse(file.size ?? '0') ?? 0,
          createdTime: file.createdTime!,
          modifiedTime: file.modifiedTime!,
        ),
      );
    } on BackupFailure catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(_mapException(e));
    }
  }

  /// Maps exceptions to appropriate BackupFailure types
  BackupFailure _mapException(Object e) {
    final message = e.toString().toLowerCase();

    if (message.contains('quota') || message.contains('storage')) {
      return BackupQuotaExceededFailure(
        'Ruang Google Drive penuh. Hapus beberapa file dan coba lagi.',
      );
    }
    if (message.contains('network') || message.contains('connection') ||
        message.contains('socket') || message.contains('timeout')) {
      return BackupNetworkFailure(
        'Koneksi gagal. Periksa internet Anda.',
      );
    }
    if (message.contains('not found') || message.contains('404')) {
      return BackupNotFoundFailure(
        'File backup tidak ditemukan.',
      );
    }
    if (message.contains('cancel')) {
      return BackupCancelledFailure('Operasi dibatalkan.');
    }
    return BackupUnknownFailure('Gagal mengakses Google Drive: $e');
  }
}
