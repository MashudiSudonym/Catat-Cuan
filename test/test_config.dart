import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/entities/category_entity.dart';
import 'package:catat_cuan/domain/entities/transaction_entity.dart';

/// Global test configuration and utilities
class TestConfig {
  // === Test Timeout Configuration ===
  static const Duration defaultTestTimeout = Duration(seconds: 5);
  static const Duration integrationTestTimeout = Duration(seconds: 30);

  // === Test Data Constants ===
  static const double defaultTestAmount = 50000.0;
  static const String defaultTestDescription = 'Test Transaction';
  static const int defaultCategoryId = 1;

  // === Test Configuration Methods ===
  static void configureTests() {
    // Set default test timeout
    TestWidgetsFlutterBinding.ensureInitialized();
  }

  // === Assertion Helpers ===
  static void expectCategoryEquals(
    CategoryEntity actual,
    CategoryEntity expected, {
    bool checkId = true,
    bool checkCreatedAt = false,
  }) {
    if (checkId) {
      expect(actual.id, equals(expected.id));
    }
    expect(actual.name, equals(expected.name));
    expect(actual.icon, equals(expected.icon));
    expect(actual.color, equals(expected.color));
    expect(actual.type, equals(expected.type));
    expect(actual.displayOrder, equals(expected.displayOrder));
    expect(actual.isActive, equals(expected.isActive));
    if (checkCreatedAt) {
      expect(actual.createdAt, equals(expected.createdAt));
    }
  }

  static void expectTransactionEquals(
    TransactionEntity actual,
    TransactionEntity expected, {
    bool checkId = true,
    bool checkCreatedAt = false,
  }) {
    if (checkId) {
      expect(actual.id, equals(expected.id));
    }
    expect(actual.categoryId, equals(expected.categoryId));
    expect(actual.description, equals(expected.description));
    expect(actual.amount, equals(expected.amount));
    expect(actual.type, equals(expected.type));
    expect(actual.date, equals(expected.date));
    if (checkCreatedAt) {
      expect(actual.createdAt, equals(expected.createdAt));
    }
  }

  // === List Assertion Helpers ===
  static void expectCategoriesUnordered(
    List<CategoryEntity> actual,
    List<CategoryEntity> expected,
  ) {
    expect(actual.length, equals(expected.length));
    for (final expectedCategory in expected) {
      final match = actual.any((cat) =>
          cat.id == expectedCategory.id &&
          cat.name == expectedCategory.name);
      expect(match, isTrue, reason: 'Category ${expectedCategory.name} not found');
    }
  }

  static void expectTransactionsUnordered(
    List<TransactionEntity> actual,
    List<TransactionEntity> expected,
  ) {
    expect(actual.length, equals(expected.length));
    for (final expectedTransaction in expected) {
      final match = actual.any((txn) =>
          txn.id == expectedTransaction.id &&
          txn.description == expectedTransaction.description);
      expect(match, isTrue, reason: 'Transaction ${expectedTransaction.description} not found');
    }
  }

  // === Test Data Validation Helpers ===
  static bool isValidCategoryColor(String color) {
    return color.startsWith('#FF') && color.length == 9;
  }

  static bool isValidCategoryIcon(String icon) {
    return icon.isNotEmpty && icon.runes.length <= 4; // Max 2 emojis or chars
  }

  static bool isValidAmount(double amount) {
    return amount > 0 && amount < 1000000000; // Max 1 billion
  }

  static bool isValidYearMonth(String yearMonth) {
    final regex = RegExp(r'^\d{4}-\d{2}$');
    if (!regex.hasMatch(yearMonth)) return false;

    final parts = yearMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    return year >= 2000 && year <= 2100 && month >= 1 && month <= 12;
  }
}

/// Custom test matchers
class CustomMatchers {
  static Matcher throwsExceptionWithMessage(String message) {
    return throwsA(predicate((e) =>
        e is Exception && e.toString().contains(message)));
  }

  static Matcher isValidCategory() {
    return predicate((CategoryEntity cat) =>
        cat.id > 0 &&
        cat.name.isNotEmpty &&
        TestConfig.isValidCategoryColor(cat.color) &&
        TestConfig.isValidCategoryIcon(cat.icon));
  }

  static Matcher isValidTransaction() {
    return predicate((TransactionEntity txn) =>
        txn.id > 0 &&
        txn.categoryId > 0 &&
        txn.description.isNotEmpty &&
        TestConfig.isValidAmount(txn.amount));
  }
}

/// Test group builders for common test scenarios
class TestGroupBuilder {
  static void runSuccessFailureTests({
    required String description,
    required Future<void> Function() successTest,
    required Future<void> Function() failureTest,
  }) {
    group(description, () {
      test('succeeds with valid input', () async {
        await successTest();
      });

      test('fails with invalid input', () async {
        await failureTest();
      });
    });
  }

  static void runValidationTests<T>({
    required String description,
    required T validValue,
    required List<T> invalidValues,
    required Future<void> Function(T value) testFunction,
  }) {
    group(description, () {
      test('accepts valid value', () async {
        await testFunction(validValue);
      });

      for (var i = 0; i < invalidValues.length; i++) {
        test('rejects invalid value $i', () async {
          await expectLater(
            () => testFunction(invalidValues[i]),
            throwsA(anything),
          );
        });
      }
    });
  }
}

/// Performance test utilities
class PerformanceTestHelper {
  static void expectExecutionTime(
    Future<void> Function() operation,
    Duration maxDuration, {
    String? description,
  }) {
    final stopwatch = Stopwatch()..start();
    operation();
    stopwatch.stop();

    expect(
      stopwatch.elapsed,
      lessThan(maxDuration),
      reason: description ?? 'Operation took too long',
    );
  }
}
