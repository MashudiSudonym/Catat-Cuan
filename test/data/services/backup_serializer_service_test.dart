import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/services/backup_serializer_service.dart';
import 'package:catat_cuan/data/services/shared_preferences_service.dart';
import 'package:catat_cuan/domain/failures/backup_failure.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<LocalDataSource>(),
  MockSpec<SharedPreferencesService>(),
])
import 'backup_serializer_service_test.mocks.dart';

void main() {
  late BackupSerializerService service;
  late MockLocalDataSource mockDataSource;
  late MockSharedPreferencesService mockPrefs;

  setUp(() {
    mockDataSource = MockLocalDataSource();
    mockPrefs = MockSharedPreferencesService();
    service = BackupSerializerService(
      localDataSource: mockDataSource,
      sharedPreferencesService: mockPrefs,
    );
  });

  group('BackupSerializerService', () {
    group('serialize', () {
      void setupDefaultMocks() {
        // Mock all table queries
        when(mockDataSource.rawQuery(
          'SELECT * FROM transactions',
          any,
        )).thenAnswer((_) async => [
              {'id': 1, 'amount': 50000, 'note': 'Lunch'},
            ]);

        when(mockDataSource.rawQuery(
          'SELECT * FROM categories',
          any,
        )).thenAnswer((_) async => [
              {'id': 1, 'name': 'Makanan', 'icon': 'restaurant'},
            ]);

        when(mockDataSource.rawQuery(
          'SELECT * FROM budgets',
          any,
        )).thenAnswer((_) async => [
              {'id': 1, 'amount': 500000},
            ]);

        when(mockDataSource.rawQuery(
          'SELECT * FROM savings_goals',
          any,
        )).thenAnswer((_) async => []);

        when(mockDataSource.rawQuery(
          'SELECT * FROM goal_contributions',
          any,
        )).thenAnswer((_) async => []);

        // Mock settings
        when(mockPrefs.hasSeenOnboarding()).thenAnswer((_) async => true);
      }

      test('should produce valid JSON with all table keys', () async {
        // Arrange
        setupDefaultMocks();

        // Act
        final result = await service.serialize();

        // Assert
        expect(result.isSuccess, isTrue);
        final serialized = result.data!;
        final json = jsonDecode(utf8.decode(serialized.bytes))
            as Map<String, dynamic>;

        // Verify top-level structure (per D-01)
        expect(json.containsKey('version'), isTrue);
        expect(json.containsKey('schema_version'), isTrue);
        expect(json.containsKey('device'), isTrue);
        expect(json.containsKey('created_at'), isTrue);
        expect(json.containsKey('data_counts'), isTrue);
        expect(json.containsKey('data'), isTrue);

        // Verify data section has all table keys
        final data = json['data'] as Map<String, dynamic>;
        expect(data.containsKey('transactions'), isTrue);
        expect(data.containsKey('categories'), isTrue);
        expect(data.containsKey('budgets'), isTrue);
        expect(data.containsKey('savings_goals'), isTrue);
        expect(data.containsKey('goal_contributions'), isTrue);
        expect(data.containsKey('settings'), isTrue);
      });

      test('should include metadata with correct version and schema_version',
          () async {
        // Arrange
        setupDefaultMocks();

        // Act
        final result = await service.serialize();

        // Assert
        expect(result.isSuccess, isTrue);
        final serialized = result.data!;
        final json = jsonDecode(utf8.decode(serialized.bytes))
            as Map<String, dynamic>;

        // Verify version is 1 (per D-01)
        expect(json['version'], equals(1));

        // Verify schema_version matches current DB schema
        expect(json['schema_version'], isA<int>());
        expect(json['schema_version'], greaterThan(0));

        // Verify metadata object matches
        expect(serialized.metadata.version, equals(1));
        expect(serialized.metadata.schemaVersion, greaterThan(0));
      });

      test('should include data_counts reflecting actual row counts', () async {
        // Arrange
        setupDefaultMocks();

        // Act
        final result = await service.serialize();

        // Assert
        expect(result.isSuccess, isTrue);
        final serialized = result.data!;
        final json = jsonDecode(utf8.decode(serialized.bytes))
            as Map<String, dynamic>;

        final dataCounts = json['data_counts'] as Map<String, dynamic>;
        expect(dataCounts['transactions'], equals(1));
        expect(dataCounts['categories'], equals(1));
        expect(dataCounts['budgets'], equals(1));
        expect(dataCounts['savings_goals'], equals(0));
        expect(dataCounts['goal_contributions'], equals(0));
      });

      test('should return failure when database query fails', () async {
        // Arrange
        when(mockDataSource.rawQuery(any, any))
            .thenThrow(Exception('DB error'));

        // Act
        final result = await service.serialize();

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<BackupFailure>());
      });
    });

    group('deserialize', () {
      test('should parse valid backup correctly', () async {
        // Arrange
        final backupJson = {
          'version': 1,
          'schema_version': 4,
          'device': 'Test Device',
          'created_at': DateTime.now().toIso8601String(),
          'data_counts': {
            'transactions': 2,
            'categories': 1,
          },
          'data': {
            'transactions': [
              {'id': 1, 'amount': 50000},
              {'id': 2, 'amount': 30000},
            ],
            'categories': [
              {'id': 1, 'name': 'Makanan'},
            ],
            'budgets': [],
            'savings_goals': [],
            'goal_contributions': [],
            'settings': {'theme': 'dark'},
          },
        };
        final bytes = utf8.encode(jsonEncode(backupJson));

        // Act
        final result = await service.deserialize(bytes);

        // Assert
        expect(result.isSuccess, isTrue);
        final data = result.data!;
        expect(data.transactions, hasLength(2));
        expect(data.categories, hasLength(1));
        expect(data.budgets, isEmpty);
        expect(data.savingsGoals, isEmpty);
        expect(data.goalContributions, isEmpty);
        expect(data.settings['theme'], equals('dark'));
      });

      test('should reject backup with higher schema version', () async {
        // Arrange - backup with schema version higher than current
        final backupJson = {
          'version': 1,
          'schema_version': 999, // Way higher than current
          'device': 'Future Device',
          'created_at': DateTime.now().toIso8601String(),
          'data_counts': {},
          'data': {
            'transactions': [],
            'categories': [],
            'budgets': [],
            'savings_goals': [],
            'goal_contributions': [],
            'settings': {},
          },
        };
        final bytes = utf8.encode(jsonEncode(backupJson));

        // Act
        final result = await service.deserialize(bytes);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<BackupCorruptedFailure>());
        // Verify Indonesian message per D-02
        expect(
          result.failure!.message,
          contains('versi aplikasi yang lebih baru'),
        );
      });

      test('should reject backup with unsupported version', () async {
        // Arrange - backup with format version higher than supported
        final backupJson = {
          'version': 999, // Unsupported format version
          'schema_version': 4,
          'device': 'Test',
          'created_at': DateTime.now().toIso8601String(),
          'data_counts': {},
          'data': {
            'transactions': [],
            'categories': [],
            'budgets': [],
            'savings_goals': [],
            'goal_contributions': [],
            'settings': {},
          },
        };
        final bytes = utf8.encode(jsonEncode(backupJson));

        // Act
        final result = await service.deserialize(bytes);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<BackupCorruptedFailure>());
      });

      test('should reject invalid JSON bytes', () async {
        // Arrange
        final bytes = utf8.encode('not valid json {{{');

        // Act
        final result = await service.deserialize(bytes);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<BackupFailure>());
      });

      test('round-trip: serialize then deserialize produces equivalent data',
          () async {
        // Arrange
        when(mockDataSource.rawQuery(
          'SELECT * FROM transactions',
          any,
        )).thenAnswer((_) async => [
              {'id': 1, 'amount': 50000, 'note': 'Lunch'},
              {'id': 2, 'amount': 30000, 'note': 'Coffee'},
            ]);

        when(mockDataSource.rawQuery(
          'SELECT * FROM categories',
          any,
        )).thenAnswer((_) async => [
              {'id': 1, 'name': 'Makanan'},
            ]);

        when(mockDataSource.rawQuery(
          'SELECT * FROM budgets',
          any,
        )).thenAnswer((_) async => []);

        when(mockDataSource.rawQuery(
          'SELECT * FROM savings_goals',
          any,
        )).thenAnswer((_) async => []);

        when(mockDataSource.rawQuery(
          'SELECT * FROM goal_contributions',
          any,
        )).thenAnswer((_) async => []);

        when(mockPrefs.hasSeenOnboarding()).thenAnswer((_) async => true);

        // Act - serialize
        final serializeResult = await service.serialize();
        expect(serializeResult.isSuccess, isTrue);

        // Act - deserialize
        final deserializeResult =
            await service.deserialize(serializeResult.data!.bytes);
        expect(deserializeResult.isSuccess, isTrue);

        // Assert - data should be equivalent
        final data = deserializeResult.data!;
        expect(data.transactions, hasLength(2));
        expect(data.categories, hasLength(1));
        expect(data.budgets, isEmpty);
        expect(data.savingsGoals, isEmpty);
        expect(data.goalContributions, isEmpty);
      });
    });
  });
}
