import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';
import 'package:catat_cuan/data/models/transaction_model.dart';
import 'package:catat_cuan/data/repositories/transaction/transaction_write_repository_impl.dart';
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

  late TransactionWriteRepositoryImpl repository;
  late MockLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockLocalDataSource();
    repository = TransactionWriteRepositoryImpl(mockDataSource);
  });

  // Test data helpers
  Map<String, dynamic> createTestTransactionMap() {
    return {
      TransactionFields.id: 1,
      TransactionFields.amount: 25000.0,
      TransactionFields.type: 'expense',
      TransactionFields.dateTime: '2026-03-18T14:30:00.000Z',
      TransactionFields.categoryId: 1,
      TransactionFields.note: 'Makan siang',
      TransactionFields.createdAt: '2026-03-18T14:30:00.000Z',
      TransactionFields.updatedAt: '2026-03-18T14:30:00.000Z',
    };
  }

  group('TransactionWriteRepositoryImpl', () {
    group('addTransaction', () {
      test('should add transaction and return with ID', () async {
        // Arrange
        final transaction = TransactionEntity(
          id: null,
          amount: 25000.0,
          type: TransactionType.expense,
          dateTime: DateTime.parse('2026-03-18T14:30:00.000Z'),
          categoryId: 1,
          note: 'Makan siang',
          createdAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
          updatedAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
        );

        final insertedMap = createTestTransactionMap();
        when(mockDataSource.insert(DatabaseHelper.tableTransactions, any))
            .thenAnswer((_) async => 1);
        when(mockDataSource.query(
          DatabaseHelper.tableTransactions,
          where: 'id = ?',
          whereArgs: [1],
        )).thenAnswer((_) async => [insertedMap]);

        // Act
        final result = await repository.addTransaction(transaction);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.id, 1);
        expect(result.data?.amount, 25000.0);
        verify(mockDataSource.insert(DatabaseHelper.tableTransactions, any))
            .called(1);
        verify(mockDataSource.query(
          DatabaseHelper.tableTransactions,
          where: 'id = ?',
          whereArgs: [1],
        )).called(1);
      });

      test('should return DatabaseFailure when insert fails', () async {
        // Arrange
        final transaction = TransactionEntity(
          id: null,
          amount: 25000.0,
          type: TransactionType.expense,
          dateTime: DateTime.parse('2026-03-18T14:30:00.000Z'),
          categoryId: 1,
          note: 'Makan siang',
          createdAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
          updatedAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
        );

        when(mockDataSource.insert(DatabaseHelper.tableTransactions, any))
            .thenThrow(Exception('Database error'));

        // Act
        final result = await repository.addTransaction(transaction);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<DatabaseFailure>());
      });
    });

    group('updateTransaction', () {
      test('should return ValidationFailure when ID is null', () async {
        // Arrange - Transaction without ID
        final transaction = TransactionEntity(
          id: null, // Missing ID for update
          amount: 50000.0,
          type: TransactionType.expense,
          dateTime: DateTime.parse('2026-03-18T14:30:00.000Z'),
          categoryId: 2,
          note: 'Bensin',
          createdAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
          updatedAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
        );

        // Act
        final result = await repository.updateTransaction(transaction);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<ValidationFailure>());
        expect(result.failure?.message, contains('wajib diisi'));
        verifyNever(mockDataSource.update(any, any, where: anyNamed('where')));
      });

      test('should update transaction successfully', () async {
        // Arrange
        final transaction = TransactionEntity(
          id: 1,
          amount: 30000.0, // Updated amount
          type: TransactionType.expense,
          dateTime: DateTime.parse('2026-03-18T14:30:00.000Z'),
          categoryId: 1,
          note: 'Makan malam',
          createdAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
          updatedAt: DateTime.parse('2026-03-18T14:35:00.000Z'),
        );

        final updatedMap = {
          ...createTestTransactionMap(),
          TransactionFields.amount: 30000.0,
          TransactionFields.note: 'Makan malam',
        };

        when(mockDataSource.update(
          DatabaseHelper.tableTransactions,
          any,
          where: 'id = ?',
          whereArgs: [1],
        )).thenAnswer((_) async => 1);
        when(mockDataSource.query(
          DatabaseHelper.tableTransactions,
          where: 'id = ?',
          whereArgs: [1],
        )).thenAnswer((_) async => [updatedMap]);

        // Act
        final result = await repository.updateTransaction(transaction);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.amount, 30000.0);
        expect(result.data?.note, 'Makan malam');
        verify(mockDataSource.update(
          DatabaseHelper.tableTransactions,
          any,
          where: 'id = ?',
          whereArgs: [1],
        )).called(1);
      });

      test('should return NotFoundFailure when transaction not found', () async {
        // Arrange
        final transaction = TransactionEntity(
          id: 999,
          amount: 25000.0,
          type: TransactionType.expense,
          dateTime: DateTime.parse('2026-03-18T14:30:00.000Z'),
          categoryId: 1,
          createdAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
          updatedAt: DateTime.parse('2026-03-18T14:30:00.000Z'),
        );

        when(mockDataSource.update(
          DatabaseHelper.tableTransactions,
          any,
          where: 'id = ?',
          whereArgs: [999],
        )).thenAnswer((_) async => 0); // 0 rows affected

        // Act
        final result = await repository.updateTransaction(transaction);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<NotFoundFailure>());
        expect(result.failure?.message, contains('tidak ditemukan'));
      });
    });

    group('deleteTransaction', () {
      test('should delete transaction successfully', () async {
        // Arrange
        when(mockDataSource.delete(
          DatabaseHelper.tableTransactions,
          where: 'id = ?',
          whereArgs: [1],
        )).thenAnswer((_) async => 1);

        // Act
        final result = await repository.deleteTransaction(1);

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockDataSource.delete(
          DatabaseHelper.tableTransactions,
          where: 'id = ?',
          whereArgs: [1],
        )).called(1);
      });

      test('should return NotFoundFailure when transaction not found', () async {
        // Arrange
        when(mockDataSource.delete(
          DatabaseHelper.tableTransactions,
          where: 'id = ?',
          whereArgs: [999],
        )).thenAnswer((_) async => 0);

        // Act
        final result = await repository.deleteTransaction(999);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<NotFoundFailure>());
      });
    });

    group('deleteAllTransactions', () {
      test('should delete all transactions successfully', () async {
        // Arrange
        when(mockDataSource.delete(DatabaseHelper.tableTransactions))
            .thenAnswer((_) async => 100);

        // Act
        final result = await repository.deleteAllTransactions();

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockDataSource.delete(DatabaseHelper.tableTransactions))
            .called(1);
      });
    });

    group('deleteMultipleTransactions', () {
      test('should return ValidationFailure when ids list is empty', () async {
        // Arrange
        final emptyIds = <int>[];

        // Act
        final result = await repository.deleteMultipleTransactions(emptyIds);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<ValidationFailure>());
        expect(result.failure?.message, contains('tidak boleh kosong'));
        verifyNever(mockDataSource.delete(any, where: anyNamed('where')));
      });

      test('should delete multiple transactions successfully', () async {
        // Arrange
        final ids = [1, 2, 3];
        when(mockDataSource.delete(
          DatabaseHelper.tableTransactions,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        )).thenAnswer((_) async => 3);

        // Act
        final result = await repository.deleteMultipleTransactions(ids);

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockDataSource.delete(
          DatabaseHelper.tableTransactions,
          where: anyNamed('where'),
          whereArgs: ids,
        )).called(1);
      });

      test('should return NotFoundFailure when no transactions found', () async {
        // Arrange
        final ids = [999, 1000];
        when(mockDataSource.delete(
          DatabaseHelper.tableTransactions,
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
        )).thenAnswer((_) async => 0);

        // Act
        final result = await repository.deleteMultipleTransactions(ids);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<NotFoundFailure>());
      });
    });
  });
}
