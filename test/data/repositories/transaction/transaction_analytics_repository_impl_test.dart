import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/repositories/transaction/transaction_analytics_repository_impl.dart';
import 'package:catat_cuan/domain/entities/category_breakdown_entity.dart';
import 'package:catat_cuan/domain/entities/monthly_summary_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
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

  late TransactionAnalyticsRepositoryImpl repository;
  late MockLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockLocalDataSource();
    repository = TransactionAnalyticsRepositoryImpl(mockDataSource);
  });

  group('TransactionAnalyticsRepositoryImpl', () {
    group('getMonthlySummary', () {
      test('should return empty summary when no transactions found', () async {
        // Arrange
        when(mockDataSource.rawQuery(any, any))
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getMonthlySummary('2026-03');

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.yearMonth, '2026-03');
        expect(result.data?.totalIncome, 0);
        expect(result.data?.totalExpense, 0);
        expect(result.data?.balance, 0);
        expect(result.data?.transactionCount, 0);
        verify(mockDataSource.rawQuery(
          argThat(contains('strftime')),
          ['2026-03'],
        )).called(1);
      });

      test('should return summary with calculated values', () async {
        // Arrange
        final summaryMap = {
          'year_month': '2026-03',
          'total_income': 5000000.0,
          'total_expense': 3000000.0,
          'balance': 2000000.0,
          'transaction_count': 25,
        };
        when(mockDataSource.rawQuery(any, any))
            .thenAnswer((_) async => [summaryMap]);

        // Act
        final result = await repository.getMonthlySummary('2026-03');

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.totalIncome, 5000000.0);
        expect(result.data?.totalExpense, 3000000.0);
        expect(result.data?.balance, 2000000.0);
        expect(result.data?.transactionCount, 25);
      });

      test('should return DatabaseFailure on exception', () async {
        // Arrange
        when(mockDataSource.rawQuery(any, any))
            .thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getMonthlySummary('2026-03');

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<DatabaseFailure>());
      });
    });

    group('getAllTimeSummary', () {
      test('should return empty summary when no transactions exist', () async {
        // Arrange
        when(mockDataSource.rawQuery(any, any))
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllTimeSummary();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.yearMonth, 'all');
        expect(result.data?.totalIncome, 0);
        expect(result.data?.totalExpense, 0);
      });

      test('should return all-time summary correctly', () async {
        // Arrange
        final summaryMap = {
          'year_month': 'all',
          'total_income': 15000000.0,
          'total_expense': 10000000.0,
          'balance': 5000000.0,
          'transaction_count': 150,
        };
        when(mockDataSource.rawQuery(any, any))
            .thenAnswer((_) async => [summaryMap]);

        // Act
        final result = await repository.getAllTimeSummary();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.totalIncome, 15000000.0);
        expect(result.data?.totalExpense, 10000000.0);
        expect(result.data?.balance, 5000000.0);
        expect(result.data?.transactionCount, 150);
      });
    });

    group('getCategoryBreakdown', () {
      test('should return empty list when no categories found', () async {
        // Arrange
        when(mockDataSource.rawQuery(any, any))
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getCategoryBreakdown(
          '2026-03',
          TransactionType.expense,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.isEmpty, isTrue);
      });

      test('should calculate percentage correctly', () async {
        // Arrange - Two categories with amounts 300000 and 200000 (total 500000)
        final breakdownMaps = [
          {
            'id': 1,
            'name': 'Makan',
            'icon': '🍽️',
            'color': '#FF64748B',
            'total_amount': 300000.0,
            'transaction_count': 10,
          },
          {
            'id': 2,
            'name': 'Transport',
            'icon': '🚗',
            'color': '#FF59E6C6',
            'total_amount': 200000.0,
            'transaction_count': 5,
          },
        ];
        when(mockDataSource.rawQuery(any, any))
            .thenAnswer((_) async => breakdownMaps);

        // Act
        final result = await repository.getCategoryBreakdown(
          '2026-03',
          TransactionType.expense,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.length, 2);
        // First category: 300000/500000 = 60%
        expect(result.data?.first.percentage, closeTo(60.0, 0.01));
        expect(result.data?.first.totalAmount, 300000.0);
        // Second category: 200000/500000 = 40%
        expect(result.data?.last.percentage, closeTo(40.0, 0.01));
        expect(result.data?.last.totalAmount, 200000.0);
      });

      test('should handle zero total amount gracefully', () async {
        // Arrange - All amounts are 0
        final breakdownMaps = [
          {
            'id': 1,
            'name': 'Makan',
            'icon': '🍽️',
            'color': '#FF64748B',
            'total_amount': 0.0,
            'transaction_count': 0,
          },
        ];
        when(mockDataSource.rawQuery(any, any))
            .thenAnswer((_) async => breakdownMaps);

        // Act
        final result = await repository.getCategoryBreakdown(
          '2026-03',
          TransactionType.expense,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.first.percentage, 0.0);
      });
    });

    group('getAllCategoryBreakdown', () {
      test('should return all-time category breakdown', () async {
        // Arrange
        final breakdownMaps = [
          {
            'id': 1,
            'name': 'Makan',
            'icon': '🍽️',
            'color': '#FF64748B',
            'total_amount': 5000000.0,
            'transaction_count': 100,
          },
        ];
        when(mockDataSource.rawQuery(any, any))
            .thenAnswer((_) async => breakdownMaps);

        // Act
        final result = await repository.getAllCategoryBreakdown(
          TransactionType.expense,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.length, 1);
        expect(result.data?.first.totalAmount, 5000000.0);
        expect(result.data?.first.transactionCount, 100);
        // Single category = 100%
        expect(result.data?.first.percentage, 100.0);
      });
    });

    group('getMultiMonthSummary', () {
      test('should return summaries for multiple months', () async {
        // Arrange
        final summaryMaps = [
          {
            'year_month': '2026-01',
            'total_income': 4000000.0,
            'total_expense': 2000000.0,
            'balance': 2000000.0,
            'transaction_count': 15,
          },
          {
            'year_month': '2026-02',
            'total_income': 5000000.0,
            'total_expense': 3000000.0,
            'balance': 2000000.0,
            'transaction_count': 20,
          },
        ];
        when(mockDataSource.rawQuery(any, any))
            .thenAnswer((_) async => summaryMaps);

        // Act
        final result = await repository.getMultiMonthSummary(
          '2026-01',
          '2026-02',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.length, 2);
        expect(result.data?.first.yearMonth, '2026-01');
        expect(result.data?.last.yearMonth, '2026-02');
      });

      test('should return empty list when no data in range', () async {
        // Arrange
        when(mockDataSource.rawQuery(any, any))
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getMultiMonthSummary(
          '2026-01',
          '2026-02',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.isEmpty, isTrue);
      });
    });
  });
}
