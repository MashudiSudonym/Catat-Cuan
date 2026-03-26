import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';
import 'package:catat_cuan/presentation/managers/transaction_grouper.dart';

void main() {
  group('TransactionGrouper', () {
    late List<TransactionEntity> testTransactions;

    setUp(() {
      final now = DateTime.now();
      testTransactions = [
        // Transaction 1: Income
        TransactionEntity(
          id: 1,
          amount: 100000,
          type: TransactionType.income,
          dateTime: DateTime(now.year, now.month, now.day, 10, 0),
          categoryId: 1,
          note: 'Gaji',
          createdAt: now,
          updatedAt: now,
        ),
        // Transaction 2: Expense
        TransactionEntity(
          id: 2,
          amount: 50000,
          type: TransactionType.expense,
          dateTime: DateTime(now.year, now.month, now.day, 14, 0),
          categoryId: 2,
          note: 'Makan siang',
          createdAt: now,
          updatedAt: now,
        ),
        // Transaction 3: Same day, different time
        TransactionEntity(
          id: 3,
          amount: 25000,
          type: TransactionType.expense,
          dateTime: DateTime(now.year, now.month, now.day, 18, 0),
          categoryId: 3,
          note: 'Transport',
          createdAt: now,
          updatedAt: now,
        ),
        // Transaction 4: Different day
        TransactionEntity(
          id: 4,
          amount: 75000,
          type: TransactionType.expense,
          dateTime: DateTime(now.year, now.month, now.day - 1, 12, 0),
          categoryId: 2,
          note: 'Makan malam',
          createdAt: now,
          updatedAt: now,
        ),
      ];
    });

    test('groupByDate should group transactions by date correctly', () {
      final result = TransactionGrouper.groupByDate(testTransactions);

      // Should have 2 date groups (today and yesterday)
      expect(result.length, equals(2));

      // First group should be today (most recent)
      final firstGroup = result.first;
      expect(firstGroup['transactions'], isA<List<TransactionEntity>>());
      expect((firstGroup['transactions'] as List<TransactionEntity>).length, equals(3));

      // Second group should be yesterday
      final secondGroup = result.last;
      expect((secondGroup['transactions'] as List<TransactionEntity>).length, equals(1));
    });

    test('groupByDate should calculate daily totals correctly', () {
      final result = TransactionGrouper.groupByDate(testTransactions);

      // First group (today): 100000 income - 50000 expense - 25000 expense = 25000
      final firstGroup = result.first;
      expect(firstGroup['total'], equals(25000.0));

      // Second group (yesterday): -75000 (only expense)
      final secondGroup = result.last;
      expect(secondGroup['total'], equals(-75000.0));
    });

    test('groupByDate should sort by date descending', () {
      final result = TransactionGrouper.groupByDate(testTransactions);

      // First group should be more recent than second group
      final firstDate = result.first['date'] as DateTime;
      final secondDate = result.last['date'] as DateTime;

      expect(firstDate.isAfter(secondDate), isTrue);
    });

    test('getDateKey should format date correctly', () {
      final date = DateTime(2024, 3, 15, 14, 30);
      final result = TransactionGrouper.getDateKey(date);

      expect(result, equals('2024-03-15'));
    });

    test('calculateDailyTotal should calculate net total correctly', () {
      final now = DateTime.now();
      final transactions = [
        TransactionEntity(
          id: 1,
          amount: 100000,
          type: TransactionType.income,
          dateTime: now,
          categoryId: 1,
          createdAt: now,
          updatedAt: now,
        ),
        TransactionEntity(
          id: 2,
          amount: 30000,
          type: TransactionType.expense,
          dateTime: now,
          categoryId: 2,
          createdAt: now,
          updatedAt: now,
        ),
        TransactionEntity(
          id: 3,
          amount: 20000,
          type: TransactionType.expense,
          dateTime: now,
          categoryId: 3,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final result = TransactionGrouper.calculateDailyTotal(transactions);

      // 100000 income - 30000 expense - 20000 expense = 50000
      expect(result, equals(50000.0));
    });

    test('groupByDate should return empty list for empty transactions', () {
      final result = TransactionGrouper.groupByDate([]);

      expect(result, isEmpty);
    });

    test('calculateDailyTotal should return 0 for empty transactions', () {
      final result = TransactionGrouper.calculateDailyTotal([]);

      expect(result, equals(0.0));
    });
  });
}
