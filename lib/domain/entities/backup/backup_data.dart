import 'package:freezed_annotation/freezed_annotation.dart';

part 'backup_data.freezed.dart';

/// Complete backup data containing all app tables
///
/// Wraps all table data for serialization to JSON.
/// Each table is represented as a list of row maps.
@freezed
abstract class BackupData with _$BackupData {
  const BackupData._();

  const factory BackupData({
    required List<Map<String, dynamic>> transactions,
    required List<Map<String, dynamic>> categories,
    required List<Map<String, dynamic>> budgets,
    required List<Map<String, dynamic>> savingsGoals,
    required List<Map<String, dynamic>> goalContributions,
    required Map<String, dynamic> settings,
  }) = _BackupData;
}
