import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/models/category_model.dart';
import 'package:catat_cuan/data/repositories/category/category_read_repository_impl.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../data_mocks.mocks.dart';

void main() {
  // Initialize logger for tests
  setUpAll(() {
    AppLogger.initialize();
  });

  late CategoryReadRepositoryImpl repository;
  late MockLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockLocalDataSource();
    repository = CategoryReadRepositoryImpl(mockDataSource);
  });

  group('CategoryReadRepositoryImpl', () {
    // Test data helpers
    List<Map<String, dynamic>> createTestCategoryMaps() {
      return [
        {
          CategoryFields.id: 1,
          CategoryFields.name: 'Makan',
          CategoryFields.type: 'expense',
          CategoryFields.color: '#FF64748B',
          CategoryFields.icon: '🍽️',
          CategoryFields.sortOrder: 1,
          CategoryFields.isActive: 1,
          CategoryFields.createdAt: '2026-03-18T14:30:00.000Z',
          CategoryFields.updatedAt: '2026-03-18T14:30:00.000Z',
        },
        {
          CategoryFields.id: 2,
          CategoryFields.name: 'Transport',
          CategoryFields.type: 'expense',
          CategoryFields.color: '#FF59E6C6',
          CategoryFields.icon: '🚗',
          CategoryFields.sortOrder: 2,
          CategoryFields.isActive: 1,
          CategoryFields.createdAt: '2026-03-18T14:30:00.000Z',
          CategoryFields.updatedAt: '2026-03-18T14:30:00.000Z',
        },
      ];
    }

    group('getCategoryById', () {
      test('should return category when found', () async {
        // Arrange
        final testMaps = createTestCategoryMaps();
        when(mockDataSource.query(
          DatabaseHelper.tableCategories,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        )).thenAnswer((_) async => testMaps);

        // Act
        final result = await repository.getCategoryById(1);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.id, 1);
        expect(result.data?.name, 'Makan');
        verify(mockDataSource.query(
          DatabaseHelper.tableCategories,
          where: '${CategoryFields.id} = ?',
          whereArgs: [1],
        )).called(1);
      });

      test('should return NotFoundFailure when category not found', () async {
        // Arrange
        when(mockDataSource.query(
          DatabaseHelper.tableCategories,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        )).thenAnswer((_) async => []);

        // Act
        final result = await repository.getCategoryById(999);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<NotFoundFailure>());
        expect(result.failure?.message, contains('tidak ditemukan'));
      });

      test('should return DatabaseFailure on exception', () async {
        // Arrange
        when(mockDataSource.query(
          any,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        )).thenThrow(Exception('Database connection error'));

        // Act
        final result = await repository.getCategoryById(1);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<DatabaseFailure>());
      });
    });

    group('getCategoriesByType', () {
      test('should return categories filtered by type and isActive', () async {
        // Arrange
        final testMaps = createTestCategoryMaps();
        when(mockDataSource.query(
          DatabaseHelper.tableCategories,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          orderBy: anyNamed('orderBy'),
        )).thenAnswer((_) async => testMaps);

        // Act
        final result = await repository.getCategoriesByType(CategoryType.expense);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.length, 2);
        expect(result.data?.first.type, CategoryType.expense);
        verify(mockDataSource.query(
          DatabaseHelper.tableCategories,
          where:
              '${CategoryFields.type} = ? AND ${CategoryFields.isActive} = ?',
          whereArgs: ['expense', 1],
          orderBy: '${CategoryFields.sortOrder} ASC',
        )).called(1);
      });

      test('should return empty list when no categories found', () async {
        // Arrange
        when(mockDataSource.query(
          DatabaseHelper.tableCategories,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          orderBy: anyNamed('orderBy'),
        )).thenAnswer((_) async => []);

        // Act
        final result = await repository.getCategoriesByType(CategoryType.income);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.isEmpty, isTrue);
      });
    });

    group('getCategoryByName', () {
      test('should return category when found by name and type', () async {
        // Arrange
        final testMaps = createTestCategoryMaps();
        when(mockDataSource.query(
          DatabaseHelper.tableCategories,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => testMaps);

        // Act
        final result = await repository.getCategoryByName(
          'Makan',
          CategoryType.expense,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.name, 'Makan');
        verify(mockDataSource.query(
          DatabaseHelper.tableCategories,
          where:
              '${CategoryFields.name} = ? AND ${CategoryFields.type} = ?',
          whereArgs: ['Makan', 'expense'],
          limit: 1,
        )).called(1);
      });

      test('should return null when category not found by name', () async {
        // Arrange
        when(mockDataSource.query(
          DatabaseHelper.tableCategories,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => []);

        // Act
        final result = await repository.getCategoryByName(
          'NonExistent',
          CategoryType.expense,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, isNull);
      });

      test('should exclude ID from WHERE clause when provided', () async {
        // Arrange
        final testMaps = createTestCategoryMaps();
        when(mockDataSource.query(
          DatabaseHelper.tableCategories,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => testMaps);

        // Act
        final result = await repository.getCategoryByName(
          'Makan',
          CategoryType.expense,
          excludeId: 1,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockDataSource.query(
          DatabaseHelper.tableCategories,
          where:
              '${CategoryFields.name} = ? AND ${CategoryFields.type} = ? AND ${CategoryFields.id} != ?',
          whereArgs: ['Makan', 'expense', 1],
          limit: 1,
        )).called(1);
      });

      test('should not exclude ID when excludeId is null', () async {
        // Arrange
        final testMaps = createTestCategoryMaps();
        when(mockDataSource.query(
          DatabaseHelper.tableCategories,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => testMaps);

        // Act
        final result = await repository.getCategoryByName(
          'Makan',
          CategoryType.expense,
          excludeId: null,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        // Verify the WHERE clause does NOT contain the ID exclusion
        final captured = verify(mockDataSource.query(
          DatabaseHelper.tableCategories,
          where: captureAnyNamed('where'),
          whereArgs: captureAnyNamed('whereArgs'),
          limit: anyNamed('limit'),
        )).captured;

        final whereClause = captured[0] as String;
        expect(whereClause, isNot(contains('${CategoryFields.id} !=')));
      });
    });

    group('getTransactionCount', () {
      test('should return transaction count for category', () async {
        // Arrange
        when(mockDataSource.rawQuery(any, any)).thenAnswer((_) async => [
          {'count': 5}
        ]);

        // Act
        final result = await repository.getTransactionCount(1);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, 5);
        verify(mockDataSource.rawQuery(
          argThat(contains('COUNT(*)')),
          [1],
        )).called(1);
      });

      test('should return 0 when no transactions found', () async {
        // Arrange
        when(mockDataSource.rawQuery(any, any)).thenAnswer((_) async => [
          {'count': null}
        ]);

        // Act
        final result = await repository.getTransactionCount(1);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, 0);
      });
    });

    group('getCategoriesWithCount', () {
      test('should return categories with transaction count', () async {
        // Arrange
        final testMapsWithCount = [
          {
            ...createTestCategoryMaps().first,
            'transaction_count': 10,
          },
        ];
        when(mockDataSource.rawQuery(any, any))
            .thenAnswer((_) async => testMapsWithCount);

        // Act
        final result = await repository.getCategoriesWithCount(CategoryType.expense);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.length, 1);
        expect(result.data?.first.name, 'Makan');
        verify(mockDataSource.rawQuery(
          argThat(allOf([
            contains('LEFT JOIN'),
            contains('COUNT(t.id)'),
          ])),
          argThat(containsAll([
            'expense',
            1,
          ])),
        )).called(1);
      });
    });
  });
}
