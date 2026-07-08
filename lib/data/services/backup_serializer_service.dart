import 'dart:convert';
import 'dart:io';
import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/services/shared_preferences_service.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/backup/backup_data.dart';
import 'package:catat_cuan/domain/entities/backup/backup_metadata.dart';
import 'package:catat_cuan/domain/failures/backup_failure.dart';

/// Result of serialization containing bytes and metadata
class BackupSerializationResult {
  final List<int> bytes;
  final BackupMetadata metadata;

  const BackupSerializationResult({
    required this.bytes,
    required this.metadata,
  });
}

/// Service for serializing and deserializing backup data
///
/// Handles the conversion between database tables and backup JSON format.
/// Follows D-01 format: single JSON file with version, schema, device, and data sections.
class BackupSerializerService {
  final LocalDataSource localDataSource;
  final SharedPreferencesService sharedPreferencesService;

  /// Current backup format version
  static const int backupFormatVersion = 1;

  BackupSerializerService({
    required this.localDataSource,
    required this.sharedPreferencesService,
  });

  /// Serializes all database tables and settings to a JSON backup
  ///
  /// Queries all 5 tables, reads settings, builds metadata header,
  /// and produces UTF-8 encoded JSON bytes.
  Future<Result<BackupSerializationResult>> serialize() async {
    try {
      // Query all tables
      final transactions = await localDataSource.rawQuery(
        'SELECT * FROM ${DatabaseHelper.tableTransactions}',
        null,
      );
      final categories = await localDataSource.rawQuery(
        'SELECT * FROM ${DatabaseHelper.tableCategories}',
        null,
      );
      final budgets = await localDataSource.rawQuery(
        'SELECT * FROM ${DatabaseHelper.tableBudgets}',
        null,
      );
      final savingsGoals = await localDataSource.rawQuery(
        'SELECT * FROM ${DatabaseHelper.tableSavingsGoals}',
        null,
      );
      final goalContributions = await localDataSource.rawQuery(
        'SELECT * FROM ${DatabaseHelper.tableGoalContributions}',
        null,
      );

      // Read settings
      final hasSeenOnboarding =
          await sharedPreferencesService.hasSeenOnboarding();
      final settings = <String, dynamic>{
        'show_onboarding': !hasSeenOnboarding,
      };

      // Build metadata
      final dataCounts = <String, int>{
        'transactions': transactions.length,
        'categories': categories.length,
        'budgets': budgets.length,
        'savings_goals': savingsGoals.length,
        'goal_contributions': goalContributions.length,
      };

      String deviceModel;
      try {
        deviceModel = Platform.isAndroid
            ? 'Android Device'
            : Platform.isIOS
                ? 'iOS Device'
                : 'Unknown';
      } catch (_) {
        deviceModel = 'Test Device';
      }

      final metadata = BackupMetadata(
        version: backupFormatVersion,
        schemaVersion: DatabaseSchemaManager.currentVersion,
        appVersion: '1.0.0', // Will be replaced with package_info_plus in production
        deviceModel: deviceModel,
        createdAt: DateTime.now(),
        dataCounts: dataCounts,
      );

      // Build full backup JSON (per D-01)
      final backupJson = {
        'version': metadata.version,
        'schema_version': metadata.schemaVersion,
        'device': metadata.deviceModel,
        'created_at': metadata.createdAt.toIso8601String(),
        'data_counts': metadata.dataCounts,
        'data': {
          'transactions': transactions,
          'categories': categories,
          'budgets': budgets,
          'savings_goals': savingsGoals,
          'goal_contributions': goalContributions,
          'settings': settings,
        },
      };

      final bytes = utf8.encode(jsonEncode(backupJson));

      return Result.success(
        BackupSerializationResult(bytes: bytes, metadata: metadata),
      );
    } catch (e) {
      return Result.failure(
        BackupFailure.unknown('Gagal membuat backup: $e'),
      );
    }
  }

  /// Deserializes backup bytes back to BackupData
  ///
  /// Validates format version and schema compatibility.
  /// Per D-02: rejects backups with higher schema versions.
  Future<Result<BackupData>> deserialize(List<int> bytes) async {
    try {
      // Decode UTF-8 → parse JSON
      final jsonString = utf8.decode(bytes);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate format version (only version 1 supported)
      final version = json['version'] as int?;
      if (version == null || version > backupFormatVersion) {
        return Result.failure(
          BackupFailure.corrupted(
            'Format backup tidak didukung. Silakan perbarui aplikasi.',
          ),
        );
      }

      // Check schema version compatibility (per D-02)
      final backupSchemaVersion = json['schema_version'] as int?;
      if (backupSchemaVersion != null &&
          backupSchemaVersion > DatabaseSchemaManager.currentVersion) {
        return Result.failure(
          BackupFailure.corrupted(
            'Data backup dibuat dengan versi aplikasi yang lebih baru. '
            'Silakan perbarui aplikasi.',
          ),
        );
      }

      // Extract data section
      final data = json['data'] as Map<String, dynamic>;

      // Build BackupData from JSON maps
      return Result.success(
        BackupData(
          transactions: _parseListOfMaps(data['transactions']),
          categories: _parseListOfMaps(data['categories']),
          budgets: _parseListOfMaps(data['budgets']),
          savingsGoals: _parseListOfMaps(data['savings_goals']),
          goalContributions: _parseListOfMaps(data['goal_contributions']),
          settings: _parseMap(data['settings']),
        ),
      );
    } on FormatException {
      return Result.failure(
        BackupFailure.corrupted('Format file backup tidak valid.'),
      );
    } catch (e) {
      return Result.failure(
        BackupFailure.corrupted('Gagal membaca backup: $e'),
      );
    }
  }

  /// Generates backup filename per D-05
  String generateFilename() {
    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    return 'catatcuan_backup_$timestamp.json';
  }

  List<Map<String, dynamic>> _parseListOfMaps(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];
    return value.cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> _parseMap(dynamic value) {
    if (value == null) return {};
    if (value is! Map) return {};
    return Map<String, dynamic>.from(value);
  }
}
