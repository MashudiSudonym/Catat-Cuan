import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/entities/backup/backup_data.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/services/backup_restore_service.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<LocalDataSource>()])
import 'backup_restore_service_test.mocks.dart';

void main() {
  late BackupRestoreService service;
  late MockLocalDataSource mockLocalDataSource;

  setUp(() {
    AppLogger.initialize();
    mockLocalDataSource = MockLocalDataSource();
    service = BackupRestoreService(localDataSource: mockLocalDataSource);
  });

  group('BackupRestoreService', () {
    final testBackupData = BackupData(
      transactions: [
        {'id': 1, 'amount': 50000, 'category_id': 1},
        {'id': 2, 'amount': 30000, 'category_id': 2},
      ],
      categories: [
        {'id': 1, 'name': 'Makanan'},
        {'id': 2, 'name': 'Transportasi'},
      ],
      budgets: [
        {'id': 1, 'category_id': 1, 'amount': 500000},
      ],
      savingsGoals: [
        {'id': 1, 'name': 'Dana Darurat', 'target_amount': 10000000},
      ],
      goalContributions: [
        {'id': 1, 'goal_id': 1, 'amount': 1000000},
      ],
      settings: {'show_onboarding': true},
    );

    test('should atomically replace all data in transaction', () async {
      // Arrange
      when(mockLocalDataSource.transaction(any)).thenAnswer((invocation) async {
        final action = invocation.positionalArguments[0]
            as Future<void> Function(LocalDataSource);
        await action(mockLocalDataSource);
      });
      // Delete all from each table
      when(mockLocalDataSource.delete(any))
          .thenAnswer((_) async => 0);
      // Batch insert per table
      when(mockLocalDataSource.batchInsert(any, any))
          .thenAnswer((_) async => 1);

      // Act
      final result = await service.restoreFromData(testBackupData);

      // Assert
      expect(result.isSuccess, isTrue);
      // Verify deletes called for all tables in FK order
      verify(mockLocalDataSource.delete(
        DatabaseHelper.tableGoalContributions,
      )).called(1);
      verify(mockLocalDataSource.delete(
        DatabaseHelper.tableSavingsGoals,
      )).called(1);
      verify(mockLocalDataSource.delete(
        DatabaseHelper.tableBudgets,
      )).called(1);
      verify(mockLocalDataSource.delete(
        DatabaseHelper.tableTransactions,
      )).called(1);
      verify(mockLocalDataSource.delete(
        DatabaseHelper.tableCategories,
      )).called(1);
      // Verify one batched insert per table (not per-row inserts)
      verify(mockLocalDataSource.batchInsert(DatabaseHelper.tableCategories, any)).called(1);
      verify(mockLocalDataSource.batchInsert(DatabaseHelper.tableTransactions, any)).called(1);
      verify(mockLocalDataSource.batchInsert(DatabaseHelper.tableBudgets, any)).called(1);
      verify(mockLocalDataSource.batchInsert(DatabaseHelper.tableSavingsGoals, any)).called(1);
      verify(mockLocalDataSource.batchInsert(DatabaseHelper.tableGoalContributions, any)).called(1);
      // Per-row insert is never used anymore
      verifyNever(mockLocalDataSource.insert(any, any));
    });

    test('should return failure when transaction fails', () async {
      // Arrange
      when(mockLocalDataSource.transaction(any)).thenAnswer((_) async {
        throw Exception('DB error');
      });

      // Act
      final result = await service.restoreFromData(testBackupData);

      // Assert
      expect(result.isFailure, isTrue);
    });

    test('should handle empty backup data', () async {
      // Arrange
      final emptyData = BackupData(
        transactions: [],
        categories: [],
        budgets: [],
        savingsGoals: [],
        goalContributions: [],
        settings: {},
      );

      when(mockLocalDataSource.transaction(any)).thenAnswer((invocation) async {
        final action = invocation.positionalArguments[0]
            as Future<void> Function(LocalDataSource);
        await action(mockLocalDataSource);
      });
      when(mockLocalDataSource.delete(any))
          .thenAnswer((_) async => 0);

      // Act
      final result = await service.restoreFromData(emptyData);

      // Assert
      expect(result.isSuccess, isTrue);
      // No inserts/batches called for empty data
      verifyNever(mockLocalDataSource.batchInsert(any, any));
      verifyNever(mockLocalDataSource.insert(any, any));
    });
  });
}
