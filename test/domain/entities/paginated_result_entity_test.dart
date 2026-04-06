import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/entities/paginated_result_entity.dart';
import '../../helpers/test_fixtures.dart';

void main() {
  group('PaginatedResultEntity', () {
    group('.create() factory constructor', () {
      test('should create paginated result with correct metadata', () {
        final data = [1, 2, 3, 4, 5];
        final result = PaginatedResultEntity<int>.create(
          data: data,
          page: 1,
          limit: 5,
          totalItems: 20,
        );

        expect(result.data, equals(data));
        expect(result.currentPage, equals(1));
        expect(result.itemsPerPage, equals(5));
        expect(result.totalItems, equals(20));
        expect(result.totalPages, equals(4)); // 20 / 5 = 4
        expect(result.hasNextPage, isTrue);
        expect(result.hasPreviousPage, isFalse);
      });

      test('should calculate totalPages correctly for remainder', () {
        final result = PaginatedResultEntity<String>.create(
          data: ['a', 'b', 'c'],
          page: 1,
          limit: 10,
          totalItems: 23,
        );

        expect(result.totalPages, equals(3)); // ceil(23 / 10) = 3
      });

      test('should handle single page', () {
        final result = PaginatedResultEntity<int>.create(
          data: [1, 2, 3],
          page: 1,
          limit: 10,
          totalItems: 3,
        );

        expect(result.totalPages, equals(1));
        expect(result.hasNextPage, isFalse);
        expect(result.hasPreviousPage, isFalse);
      });

      test('should handle first page of multi-page', () {
        final result = PaginatedResultEntity<int>.create(
          data: [1, 2, 3],
          page: 1,
          limit: 3,
          totalItems: 10,
        );

        expect(result.totalPages, equals(4)); // ceil(10/3) = 4
        expect(result.hasNextPage, isTrue);
        expect(result.hasPreviousPage, isFalse);
      });

      test('should handle middle page', () {
        final result = PaginatedResultEntity<int>.create(
          data: [4, 5, 6],
          page: 2,
          limit: 3,
          totalItems: 10,
        );

        expect(result.totalPages, equals(4));
        expect(result.hasNextPage, isTrue);
        expect(result.hasPreviousPage, isTrue);
      });

      test('should handle last page', () {
        final result = PaginatedResultEntity<int>.create(
          data: [10],
          page: 4,
          limit: 3,
          totalItems: 10,
        );

        expect(result.totalPages, equals(4));
        expect(result.hasNextPage, isFalse);
        expect(result.hasPreviousPage, isTrue);
      });

      test('should handle page beyond totalPages', () {
        final result = PaginatedResultEntity<int>.create(
          data: [],
          page: 10,
          limit: 10,
          totalItems: 5,
        );

        expect(result.totalPages, equals(1));
        expect(result.hasNextPage, isFalse);
        expect(result.hasPreviousPage, isTrue);
      });

      test('should handle empty data with valid pagination', () {
        final result = PaginatedResultEntity<int>.create(
          data: [],
          page: 2,
          limit: 10,
          totalItems: 25,
        );

        expect(result.data, isEmpty);
        expect(result.totalPages, equals(3));
        expect(result.isDataEmpty, isTrue);
      });
    });

    group('.empty() factory constructor', () {
      test('should create empty result with correct metadata', () {
        final result = PaginatedResultEntity<String>.empty(
          page: 1,
          limit: 20,
        );

        expect(result.data, isEmpty);
        expect(result.currentPage, equals(1));
        expect(result.itemsPerPage, equals(20));
        expect(result.totalItems, equals(0));
        expect(result.totalPages, equals(0));
        expect(result.hasNextPage, isFalse);
        expect(result.hasPreviousPage, isFalse);
        expect(result.isDataEmpty, isTrue);
      });

      test('should handle empty result on page > 1', () {
        final result = PaginatedResultEntity<int>.empty(
          page: 3,
          limit: 15,
        );

        expect(result.data, isEmpty);
        expect(result.currentPage, equals(3));
        expect(result.hasPreviousPage, isTrue);
        expect(result.hasNextPage, isFalse);
      });
    });

    group('Computed properties', () {
      group('isDataEmpty', () {
        test('should return true when data list is empty', () {
          final result = PaginatedResultEntity<int>.create(
            data: [],
            page: 1,
            limit: 10,
            totalItems: 0,
          );

          expect(result.isDataEmpty, isTrue);
        });

        test('should return false when data list has items', () {
          final result = PaginatedResultEntity<int>.create(
            data: [1, 2, 3],
            page: 1,
            limit: 10,
            totalItems: 3,
          );

          expect(result.isDataEmpty, isFalse);
        });
      });

      group('isFirstPage', () {
        test('should return true when currentPage is 1', () {
          final result = PaginatedResultEntity<int>.create(
            data: [1, 2],
            page: 1,
            limit: 10,
            totalItems: 20,
          );

          expect(result.isFirstPage, isTrue);
        });

        test('should return false when currentPage > 1', () {
          final result = PaginatedResultEntity<int>.create(
            data: [3, 4],
            page: 2,
            limit: 10,
            totalItems: 20,
          );

          expect(result.isFirstPage, isFalse);
        });

        test('should return true even when no items', () {
          final result = PaginatedResultEntity<int>.empty(
            page: 1,
            limit: 10,
          );

          expect(result.isFirstPage, isTrue);
        });
      });

      group('isLastPage', () {
        test('should return true when currentPage equals totalPages', () {
          final result = PaginatedResultEntity<int>.create(
            data: [1, 2],
            page: 3,
            limit: 10,
            totalItems: 25,
          );

          expect(result.isLastPage, isTrue);
        });

        test('should return true when totalPages is 0', () {
          final result = PaginatedResultEntity<int>.empty(
            page: 1,
            limit: 10,
          );

          expect(result.isLastPage, isTrue);
        });

        test('should return false when currentPage < totalPages', () {
          final result = PaginatedResultEntity<int>.create(
            data: [1, 2],
            page: 1,
            limit: 10,
            totalItems: 25,
          );

          expect(result.isLastPage, isFalse);
        });

        test('should return true for single page result', () {
          final result = PaginatedResultEntity<int>.create(
            data: [1, 2, 3],
            page: 1,
            limit: 10,
            totalItems: 3,
          );

          expect(result.isLastPage, isTrue);
        });
      });
    });

    group('Immutability', () {
      test('should be immutable with copyWith', () {
        final result = PaginatedResultEntity<int>.create(
          data: [1, 2, 3],
          page: 1,
          limit: 10,
          totalItems: 30,
        );

        final updated = result.copyWith(
          data: [4, 5, 6],
          currentPage: 2,
        );

        expect(result.data, equals([1, 2, 3])); // Original unchanged
        expect(result.currentPage, equals(1));
        expect(updated.data, equals([4, 5, 6])); // Copy updated
        expect(updated.currentPage, equals(2));
        expect(updated.totalPages, equals(3)); // Unchanged field preserved
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        final result1 = PaginatedResultEntity<int>.create(
          data: [1, 2, 3],
          page: 1,
          limit: 10,
          totalItems: 30,
        );

        final result2 = PaginatedResultEntity<int>.create(
          data: [1, 2, 3],
          page: 1,
          limit: 10,
          totalItems: 30,
        );

        expect(result1, equals(result2));
      });

      test('should not be equal when data differs', () {
        final result1 = PaginatedResultEntity<int>.create(
          data: [1, 2, 3],
          page: 1,
          limit: 10,
          totalItems: 30,
        );

        final result2 = PaginatedResultEntity<int>.create(
          data: [4, 5, 6],
          page: 1,
          limit: 10,
          totalItems: 30,
        );

        expect(result1, isNot(equals(result2)));
      });

      test('should not be equal when currentPage differs', () {
        final result1 = PaginatedResultEntity<int>.create(
          data: [1, 2, 3],
          page: 1,
          limit: 10,
          totalItems: 30,
        );

        final result2 = PaginatedResultEntity<int>.create(
          data: [1, 2, 3],
          page: 2,
          limit: 10,
          totalItems: 30,
        );

        expect(result1, isNot(equals(result2)));
      });
    });

    group('Real-world scenarios', () {
      test('should handle transaction pagination from TestFixtures', () {
        final result = TestFixtures.paginatedTransactions();

        expect(result.data, isNotEmpty);
        expect(result.currentPage, greaterThan(0));
        expect(result.itemsPerPage, greaterThan(0));
        expect(result.totalItems, greaterThanOrEqualTo(result.data.length));
      });

      test('should handle first page of transactions', () {
        final result = PaginatedResultEntity<TransactionData>.create(
          data: List.generate(20, (i) => TransactionData(id: i + 1)),
          page: 1,
          limit: 20,
          totalItems: 100,
        );

        expect(result.isFirstPage, isTrue);
        expect(result.isLastPage, isFalse);
        expect(result.hasNextPage, isTrue);
      });

      test('should handle last page of transactions', () {
        final result = PaginatedResultEntity<TransactionData>.create(
          data: List.generate(10, (i) => TransactionData(id: i + 91)),
          page: 5,
          limit: 20,
          totalItems: 100,
        );

        expect(result.isFirstPage, isFalse);
        expect(result.isLastPage, isTrue);
        expect(result.hasPreviousPage, isTrue);
        expect(result.hasNextPage, isFalse);
      });

      test('should handle empty result set', () {
        final result = PaginatedResultEntity<int>.create(
          data: [],
          page: 1,
          limit: 20,
          totalItems: 0,
        );

        expect(result.isDataEmpty, isTrue);
        expect(result.isFirstPage, isTrue);
        expect(result.isLastPage, isTrue);
      });
    });

    group('Edge cases', () {
      test('should handle very large totalItems', () {
        final result = PaginatedResultEntity<int>.create(
          data: [1],
          page: 1,
          limit: 10,
          totalItems: 999999,
        );

        expect(result.totalPages, equals(100000));
      });

      test('should handle page number larger than totalPages', () {
        final result = PaginatedResultEntity<int>.create(
          data: [],
          page: 100,
          limit: 10,
          totalItems: 5,
        );

        expect(result.totalPages, equals(1));
        expect(result.currentPage, equals(100)); // Still preserves currentPage
      });

      test('should handle limit of 1', () {
        final result = PaginatedResultEntity<int>.create(
          data: [1],
          page: 1,
          limit: 1,
          totalItems: 5,
        );

        expect(result.totalPages, equals(5));
      });

      test('should handle very large limit', () {
        final result = PaginatedResultEntity<int>.create(
          data: [1, 2, 3],
          page: 1,
          limit: 10000,
          totalItems: 3,
        );

        expect(result.totalPages, equals(1));
        expect(result.isLastPage, isTrue);
      });
    });
  });
}

// Helper class for generic type testing
class TransactionData {
  final int id;
  TransactionData({required this.id});

  @override
  bool operator ==(Object other) =>
      other is TransactionData && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
