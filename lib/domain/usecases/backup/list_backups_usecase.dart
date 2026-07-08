import 'dart:convert';
import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/core/usecase.dart';
import 'package:catat_cuan/domain/entities/backup/backup_preview.dart';
import 'package:catat_cuan/domain/entities/backup/drive_file_info.dart';
import 'package:catat_cuan/domain/failures/backup_failure.dart';
import 'package:catat_cuan/domain/services/google_drive_service.dart';

/// Use case for listing available backups from Google Drive
///
/// Lists files from Drive, downloads each file's header to extract
/// metadata, and combines with current DB row counts for preview.
/// Per D-16: Sorted newest first.
class ListBackupsUseCase extends UseCase<List<BackupPreview>, NoParams> {
  final GoogleDriveService _driveService;
  final LocalDataSource _localDataSource;

  ListBackupsUseCase({
    required GoogleDriveService driveService,
    required LocalDataSource localDataSource,
  })  : _driveService = driveService,
        _localDataSource = localDataSource;

  @override
  Future<Result<List<BackupPreview>>> call(NoParams params) async {
    try {
      // List all files from Drive
      final listResult = await _driveService.listFiles();
      if (listResult.isFailure) {
        return Result.failure(listResult.failure!);
      }

      final files = listResult.data!;

      // Get current DB row counts for comparison
      final currentCounts = await _getCurrentDataCounts();

      // Build preview for each file
      final previews = <BackupPreview>[];
      for (final file in files) {
        // Try to download and parse header for metadata
        final preview = await _buildPreview(file, currentCounts);
        if (preview != null) {
          previews.add(preview);
        }
      }

      // Sort newest first (per D-16)
      previews.sort((a, b) => b.backupDate.compareTo(a.backupDate));

      return Result.success(previews);
    } catch (e) {
      return Result.failure(
        BackupFailure.unknown('Gagal memuat daftar backup: $e'),
      );
    }
  }

  /// Build a BackupPreview from a DriveFileInfo
  ///
  /// Downloads the file header to extract backup metadata.
  /// Returns null if the file cannot be parsed.
  Future<BackupPreview?> _buildPreview(
    DriveFileInfo file,
    Map<String, int> currentCounts,
  ) async {
    try {
      // Download the file to extract metadata
      final downloadResult = await _driveService.downloadFile(fileId: file.id);
      if (downloadResult.isFailure) return null;

      final bytes = downloadResult.data!;
      final jsonString = utf8.decode(bytes);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      // Extract metadata from header
      final dataCounts = <String, int>{};
      final rawCounts = json['data_counts'] as Map<String, dynamic>?;
      if (rawCounts != null) {
        rawCounts.forEach((key, value) {
          dataCounts[key] = value as int;
        });
      }

      return BackupPreview(
        fileId: file.id,
        fileName: file.name,
        fileSize: file.size,
        backupDate: file.modifiedTime,
        deviceName: json['device'] as String? ?? 'Unknown',
        backupDataCounts: dataCounts,
        currentDataCounts: currentCounts,
      );
    } catch (_) {
      // If we can't parse this file, skip it
      return null;
    }
  }

  /// Get current row counts for all tables
  Future<Map<String, int>> _getCurrentDataCounts() async {
    final counts = <String, int>{};

    final tables = {
      'transactions': DatabaseHelper.tableTransactions,
      'categories': DatabaseHelper.tableCategories,
      'budgets': DatabaseHelper.tableBudgets,
      'savings_goals': DatabaseHelper.tableSavingsGoals,
      'goal_contributions': DatabaseHelper.tableGoalContributions,
    };

    for (final entry in tables.entries) {
      try {
        final rows = await _localDataSource.rawQuery(
          'SELECT COUNT(*) as count FROM ${entry.value}',
          null,
        );
        counts[entry.key] = rows.first['count'] as int;
      } catch (_) {
        counts[entry.key] = 0;
      }
    }

    return counts;
  }
}
