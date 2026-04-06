import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/entities/pagination_params_entity.dart';

void main() {
  group('PaginationParamsEntity', () {
    group('Entity creation', () {
      test('should create with default values', () {
        final params = PaginationParamsEntity();

        expect(params.page, equals(1));
        expect(params.limit, equals(20));
      });

      test('should create with custom values', () {
        final params = PaginationParamsEntity(
          page: 3,
          limit: 50,
        );

        expect(params.page, equals(3));
        expect(params.limit, equals(50));
      });

      test('should create with page only', () {
        final params = PaginationParamsEntity(page: 5);

        expect(params.page, equals(5));
        expect(params.limit, equals(20)); // Default
      });

      test('should create with limit only', () {
        final params = PaginationParamsEntity(limit: 100);

        expect(params.page, equals(1)); // Default
        expect(params.limit, equals(100));
      });

      test('should handle page of 0', () {
        final params = PaginationParamsEntity(page: 0);

        expect(params.page, equals(0));
        expect(params.offset, equals(-20)); // (0-1)*20 = -20
      });

      test('should handle negative page', () {
        final params = PaginationParamsEntity(page: -1);

        expect(params.page, equals(-1));
      });
    });

    group('offset getter', () {
      test('should calculate offset for page 1', () {
        final params = PaginationParamsEntity(page: 1, limit: 20);

        expect(params.offset, equals(0)); // (1-1)*20 = 0
      });

      test('should calculate offset for page 2', () {
        final params = PaginationParamsEntity(page: 2, limit: 20);

        expect(params.offset, equals(20)); // (2-1)*20 = 20
      });

      test('should calculate offset for page 5', () {
        final params = PaginationParamsEntity(page: 5, limit: 10);

        expect(params.offset, equals(40)); // (5-1)*10 = 40
      });

      test('should calculate offset with custom limit', () {
        final params = PaginationParamsEntity(page: 3, limit: 50);

        expect(params.offset, equals(100)); // (3-1)*50 = 100
      });

      test('should calculate offset for default values', () {
        final params = PaginationParamsEntity();

        expect(params.offset, equals(0)); // (1-1)*20 = 0
      });

      test('should handle page 0 offset', () {
        final params = PaginationParamsEntity(page: 0, limit: 20);

        expect(params.offset, equals(-20)); // (0-1)*20 = -20
      });

      test('should handle large page number', () {
        final params = PaginationParamsEntity(page: 100, limit: 25);

        expect(params.offset, equals(2475)); // (100-1)*25 = 2475
      });

      test('should handle limit of 1', () {
        final params = PaginationParamsEntity(page: 10, limit: 1);

        expect(params.offset, equals(9)); // (10-1)*1 = 9
      });
    });

    group('nextPage() method', () {
      test('should increment page by 1', () {
        final params = PaginationParamsEntity(page: 1, limit: 20);
        final next = params.nextPage();

        expect(next.page, equals(2));
        expect(next.limit, equals(20));
      });

      test('should preserve limit', () {
        final params = PaginationParamsEntity(page: 3, limit: 50);
        final next = params.nextPage();

        expect(next.page, equals(4));
        expect(next.limit, equals(50));
      });

      test('should work from page 1', () {
        final params = PaginationParamsEntity();
        final next = params.nextPage();

        expect(next.page, equals(2));
        expect(next.offset, equals(20));
      });

      test('should work from large page number', () {
        final params = PaginationParamsEntity(page: 999, limit: 10);
        final next = params.nextPage();

        expect(next.page, equals(1000));
      });

      test('should not modify original', () {
        final params = PaginationParamsEntity(page: 1, limit: 20);
        params.nextPage();

        expect(params.page, equals(1));
      });
    });

    group('previousPage() method', () {
      test('should decrement page by 1', () {
        final params = PaginationParamsEntity(page: 5, limit: 20);
        final previous = params.previousPage();

        expect(previous.page, equals(4));
        expect(previous.limit, equals(20));
      });

      test('should preserve limit', () {
        final params = PaginationParamsEntity(page: 10, limit: 50);
        final previous = params.previousPage();

        expect(previous.page, equals(9));
        expect(previous.limit, equals(50));
      });

      test('should not go below page 1', () {
        final params = PaginationParamsEntity(page: 1, limit: 20);
        final previous = params.previousPage();

        expect(previous.page, equals(1));
      });

      test('should not go below page 1 from page 2', () {
        final params = PaginationParamsEntity(page: 2, limit: 20);
        final previous = params.previousPage();

        expect(previous.page, equals(1));
      });

      test('should stay at page 1 for multiple calls', () {
        final params = PaginationParamsEntity(page: 1, limit: 20);
        final prev1 = params.previousPage();
        final prev2 = prev1.previousPage();
        final prev3 = prev2.previousPage();

        expect(prev1.page, equals(1));
        expect(prev2.page, equals(1));
        expect(prev3.page, equals(1));
      });

      test('should not modify original', () {
        final params = PaginationParamsEntity(page: 3, limit: 20);
        params.previousPage();

        expect(params.page, equals(3));
      });
    });

    group('reset() method', () {
      test('should reset to page 1', () {
        final params = PaginationParamsEntity(page: 5, limit: 20);
        final reset = params.reset();

        expect(reset.page, equals(1));
        expect(reset.limit, equals(20));
      });

      test('should preserve limit', () {
        final params = PaginationParamsEntity(page: 10, limit: 50);
        final reset = params.reset();

        expect(reset.page, equals(1));
        expect(reset.limit, equals(50));
      });

      test('should work from page 1 (no-op)', () {
        final params = PaginationParamsEntity();
        final reset = params.reset();

        expect(reset.page, equals(1));
        expect(reset.limit, equals(20));
      });

      test('should not modify original', () {
        final params = PaginationParamsEntity(page: 7, limit: 15);
        params.reset();

        expect(params.page, equals(7));
      });
    });

    group('Immutability', () {
      test('should be immutable with copyWith', () {
        final params = PaginationParamsEntity(page: 1, limit: 20);

        final updated = params.copyWith(
          page: 3,
          limit: 50,
        );

        expect(params.page, equals(1)); // Original unchanged
        expect(params.limit, equals(20));
        expect(updated.page, equals(3)); // Copy updated
        expect(updated.limit, equals(50));
      });

      test('should copy with page only', () {
        final params = PaginationParamsEntity(page: 1, limit: 20);
        final updated = params.copyWith(page: 5);

        expect(params.page, equals(1));
        expect(updated.page, equals(5));
        expect(updated.limit, equals(20));
      });

      test('should copy with limit only', () {
        final params = PaginationParamsEntity(page: 1, limit: 20);
        final updated = params.copyWith(limit: 100);

        expect(params.limit, equals(20));
        expect(updated.limit, equals(100));
        expect(updated.page, equals(1));
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        final params1 = PaginationParamsEntity(page: 3, limit: 20);
        final params2 = PaginationParamsEntity(page: 3, limit: 20);

        expect(params1, equals(params2));
      });

      test('should be equal with default values', () {
        final params1 = PaginationParamsEntity();
        final params2 = PaginationParamsEntity();

        expect(params1, equals(params2));
      });

      test('should not be equal when page differs', () {
        final params1 = PaginationParamsEntity(page: 1, limit: 20);
        final params2 = PaginationParamsEntity(page: 2, limit: 20);

        expect(params1, isNot(equals(params2)));
      });

      test('should not be equal when limit differs', () {
        final params1 = PaginationParamsEntity(page: 1, limit: 20);
        final params2 = PaginationParamsEntity(page: 1, limit: 50);

        expect(params1, isNot(equals(params2)));
      });

      test('should not be equal when both differ', () {
        final params1 = PaginationParamsEntity(page: 1, limit: 20);
        final params2 = PaginationParamsEntity(page: 5, limit: 50);

        expect(params1, isNot(equals(params2)));
      });
    });

    group('Real-world scenarios', () {
      test('should handle typical pagination (page 1, limit 20)', () {
        final params = PaginationParamsEntity();

        expect(params.page, equals(1));
        expect(params.limit, equals(20));
        expect(params.offset, equals(0));
      });

      test('should handle second page navigation', () {
        final params = PaginationParamsEntity();
        final page2 = params.nextPage();

        expect(page2.page, equals(2));
        expect(page2.offset, equals(20));
      });

      test('should handle going back to first page', () {
        final params = PaginationParamsEntity(page: 3, limit: 20);
        final first = params.reset();

        expect(first.page, equals(1));
        expect(first.offset, equals(0));
      });

      test('should handle navigating through pages', () {
        final params = PaginationParamsEntity();
        final page2 = params.nextPage();
        final page3 = page2.nextPage();
        final backTo2 = page3.previousPage();

        expect(backTo2.page, equals(2));
        expect(backTo2.offset, equals(20));
      });
    });

    group('Edge cases', () {
      test('should handle very large page number', () {
        final params = PaginationParamsEntity(page: 10000, limit: 20);

        expect(params.page, equals(10000));
        expect(params.offset, equals(199980)); // (10000-1)*20
      });

      test('should handle very large limit', () {
        final params = PaginationParamsEntity(page: 1, limit: 10000);

        expect(params.limit, equals(10000));
        expect(params.offset, equals(0));
      });

      test('should handle limit of 1', () {
        final params = PaginationParamsEntity(page: 50, limit: 1);

        expect(params.offset, equals(49)); // (50-1)*1
      });

      test('should handle very small limit', () {
        final params = PaginationParamsEntity(page: 10, limit: 5);

        expect(params.offset, equals(45)); // (10-1)*5
      });

      test('should handle non-round total items scenario', () {
        final params = PaginationParamsEntity(page: 3, limit: 20);

        // For 55 total items: page 3 would have items 41-55
        expect(params.offset, equals(40)); // (3-1)*20 = 40
      });
    });
  });
}
