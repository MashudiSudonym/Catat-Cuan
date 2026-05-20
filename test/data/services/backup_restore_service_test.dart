import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/backup/backup_data.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/services/backup_restore_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<LocalDataSource>()])
import 'backup_restore_service_test.mocks.dart';

void main() {
  late BackupRestoreService service;
  late MockLocalDataSource mockLocalDataSource;

  setUp(() {
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
      when(mockLocalDataSource.rawDelete(any, any))
          .thenAnswer((_) async => 0);
      // Insert for each table
      when(mockLocalDataSource.insert(any, any))
          .thenAnswer((_) async => 1);

      // Act
      final result = await service.restoreFromData(testBackupData);

      // Assert
      expect(result.isSuccess, isTrue);
      // Verify deletes called for all tables in FK order
      verify(mockLocalDataSource.rawDelete(
        argThat(contains('goal_contributions')),
        any,
      )).called(1);
      verify(mockLocalDataSource.rawDelete(
        argThat(contains('savings_goals')),
        any,
      )).called(1);
      verify(mockLocalDataSource.rawDelete(
        argThat(contains('budgets')),
        any,
      )).called(1);
      verify(mockLocalDataSource.rawDelete(
        argThat(contains('transactions')),
        any,
      )).called(1);
      verify(mockLocalDataSource.rawDelete(
        argThat(contains('categories')),
        any,
      )).called(1);
      // Verify inserts called for all tables
      verify(mockLocalDataSource.insert('categories', any)).called(2);
      verify(mockLocalDataSource.insert('transactions', any)).called(2);
      verify(mockLocalDataSource.insert('budgets', any)).called(1);
      verify(mockLocalDataSource.insert('savings_goals', any)).called(1);
      verify(mockLocalDataSource.insert('goal_contributions', any)).called(1);
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
      when(mockLocalDataSource.rawDelete(any, any))
          .thenAnswer((_) async => 0);

      // Act
      final result = await service.restoreFromData(emptyData);

      // Assert
      expect(result.isSuccess, isTrue);
      // No inserts called for empty data
      verifyNever(mockLocalDataSource.insert(any, any));
    });
  });
}
