import 'package:catat_cuan/data/services/indonesian_merchant_pattern_service_impl.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Initialize logger for tests
  setUpAll(() {
    AppLogger.initialize();
  });

  late IndonesianMerchantPatternServiceImpl service;

  setUp(() {
    service = IndonesianMerchantPatternServiceImpl();
  });

  group('IndonesianMerchantPatternServiceImpl', () {
    group('findMatch', () {
      test('should return Indomaret with high score for name match', () {
        // Arrange
        final receiptText = 'INDOMARET JL. JAKARTA SELATAN NO. 123';

        // Act
        final result = service.findMatch(receiptText);

        // Assert
        expect(result, isNotNull);
        expect(result?.merchantName, 'Indomaret');
        expect(result?.defaultCategoryName, 'Belanja Harian');
        expect(result?.id, 'indomaret');
      });

      test('should return Alfamart with high score for name match', () async {
        // Arrange
        final receiptText = 'ALFAMART 0123456 JAKARTA';

        // Act
        final result = service.findMatch(receiptText);

        // Assert
        expect(result, isNotNull);
        expect(result?.merchantName, 'Alfamart');
        expect(result?.defaultCategoryName, 'Belanja Harian');
        expect(result?.id, 'alfamart');
      });

      test('should return Starbucks for coffee shop', () {
        // Arrange
        final receiptText = 'STARBUCKS COFFEE GRAND INDONESIA';

        // Act
        final result = service.findMatch(receiptText);

        // Assert
        expect(result, isNotNull);
        expect(result?.merchantName, 'Starbucks');
        expect(result?.defaultCategoryName, 'Makanan & Minuman');
      });

      test('should return KFC for fast food', () {
        // Arrange
        final receiptText = 'KFC INDONESIA FRIED CHICKEN';

        // Act
        final result = service.findMatch(receiptText);

        // Assert
        expect(result, isNotNull);
        expect(result?.merchantName, 'KFC');
        expect(result?.defaultCategoryName, 'Makanan & Minuman');
      });

      test('should return Gojek for transportation', () {
        // Arrange
        final receiptText = 'GOJEK ROUTE FROM A TO B';

        // Act
        final result = service.findMatch(receiptText);

        // Assert
        expect(result, isNotNull);
        expect(result?.merchantName, 'Gojek');
        expect(result?.defaultCategoryName, 'Transportasi');
      });

      test('should return Tokopedia for e-commerce', () {
        // Arrange
        final receiptText = 'TOKOPEDIA ORDER #12345';

        // Act
        final result = service.findMatch(receiptText);

        // Assert
        expect(result, isNotNull);
        expect(result?.merchantName, 'Tokopedia');
        expect(result?.defaultCategoryName, 'Belanja');
      });

      test('should return PLN for utilities', () {
        // Arrange
        final receiptText = 'PLN TOKEN LISTRIK 50000';

        // Act
        final result = service.findMatch(receiptText);

        // Assert
        expect(result, isNotNull);
        expect(result?.merchantName, 'PLN');
        expect(result?.defaultCategoryName, 'Tagihan & Utilitas');
      });

      test('should return null when no pattern matches', () {
        // Arrange
        final receiptText = 'UNKNOWN MERCHANT NAME XYZ';

        // Act
        final result = service.findMatch(receiptText);

        // Assert
        expect(result, isNull);
      });

      test('should return null when score is below threshold', () {
        // Arrange - Text that might contain some keywords but not enough
        final receiptText = 'STORE JAKARTA';

        // Act
        final result = service.findMatch(receiptText);

        // Assert - 'STORE' is not a strong pattern match
        expect(result, isNull);
      });

      test('should match using alias patterns', () {
        // Arrange - Using "Indo" which is an alias for Indomaret
        final receiptText = 'Indo Point Jalan Mawar';

        // Act
        final result = service.findMatch(receiptText);

        // Assert
        expect(result, isNotNull);
        expect(result?.merchantName, 'Indomaret');
      });

      test('should prefer higher priority merchants', () {
        // Arrange - Text that contains both a high priority and lower priority pattern
        // But only one will match clearly
        final receiptText = 'INDOMARET JL. MERDEKA';

        // Act
        final result = service.findMatch(receiptText);

        // Assert
        expect(result, isNotNull);
        expect(result?.merchantName, 'Indomaret');
        expect(result?.priority, 100); // High priority
      });

      test('should match pattern variations', () {
        // Arrange - Different Indomaret pattern variations
        // The implementation converts receipt text to uppercase before matching
        final variations = [
          'INDOMARET',
          'POINT', // From the pattern list
        ];

        for (final text in variations) {
          // Act
          final result = service.findMatch(text);

          // Assert
          expect(result, isNotNull, reason: 'Should match: $text');
          expect(result?.merchantName, 'Indomaret');
        }
      });
    });

    group('findMatchInHeader', () {
      test('should return merchant when header contains name pattern', () {
        // Arrange
        final headerLines = [
          'STRUK PEMBELIAN',
          'INDOMARET POINT',
          'JL. JAKARTA NO. 1',
        ];

        // Act
        final result = service.findMatchInHeader(headerLines);

        // Assert
        expect(result, isNotNull);
        expect(result?.merchantName, 'Indomaret');
      });

      test('should return null when header does not contain known merchant', () {
        // Arrange
        final headerLines = [
          'STRUK PEMBELIAN',
          'TOKO UNKNOWN',
          'JL. JAKARTA NO. 1',
        ];

        // Act
        final result = service.findMatchInHeader(headerLines);

        // Assert
        expect(result, isNull);
      });

      test('should prioritize by priority when multiple matches possible', () {
        // Arrange - Header that could match multiple patterns
        final headerLines = [
          'MCDONALDS',
          'FAST FOOD',
        ];

        // Act
        final result = service.findMatchInHeader(headerLines);

        // Assert
        expect(result, isNotNull);
        expect(result?.merchantName, 'McDonald\'s');
      });
    });

    group('findByName', () {
      test('should find merchant by exact name match', () {
        // Act
        final result = service.findByName('Indomaret');

        // Assert
        expect(result, isNotNull);
        expect(result?.merchantName, 'Indomaret');
        expect(result?.id, 'indomaret');
      });

      test('should find merchant by alias', () {
        // Act
        final result = service.findByName('Indo');

        // Assert
        expect(result, isNotNull);
        expect(result?.merchantName, 'Indomaret');
      });

      test('should be case insensitive', () {
        // Act
        final result = service.findByName('indomaret');

        // Assert
        expect(result, isNotNull);
        expect(result?.merchantName, 'Indomaret');
      });

      test('should return null when name not found', () {
        // Act
        final result = service.findByName('UnknownMerchant');

        // Assert
        expect(result, isNull);
      });

      test('should find by alias list for Alfamart', () {
        // Act - "Alfa" is an alias for Alfamart
        final result = service.findByName('Alfa');

        // Assert
        expect(result, isNotNull);
        expect(result?.merchantName, 'Alfamart');
      });

      test('should find by alias for McDonalds', () {
        // Act - Use full alias or merchant name
        final result = service.findByName('McDonald\'s');

        // Assert
        expect(result, isNotNull);
        expect(result?.merchantName, 'McDonald\'s');
      });
    });

    group('findById', () {
      test('should find merchant by exact ID', () {
        // Act
        final result = service.findById('indomaret');

        // Assert
        expect(result, isNotNull);
        expect(result?.id, 'indomaret');
        expect(result?.merchantName, 'Indomaret');
      });

      test('should return null when ID not found', () {
        // Act
        final result = service.findById('unknown_id');

        // Assert
        expect(result, isNull);
      });

      test('should return all pattern details when found by ID', () {
        // Act
        final result = service.findById('starbucks');

        // Assert
        expect(result, isNotNull);
        expect(result?.id, 'starbucks');
        expect(result?.merchantName, 'Starbucks');
        expect(result?.defaultCategoryName, 'Makanan & Minuman');
        expect(result?.namePatterns, contains('STARBUCKS'));
        expect(result?.priority, 100);
      });
    });

    group('getPatterns', () {
      test('should return all 50+ merchant patterns', () {
        // Act
        final patterns = service.getPatterns();

        // Assert
        expect(patterns.length, greaterThan(50));
      });

      test('should return unmodifiable list', () {
        // Act
        final patterns = service.getPatterns();

        // Assert - The list should be unmodifiable
        // Trying to add to it should throw UnsupportedError
        expect(
          () {
            patterns.add(
              // This should throw
              patterns.first,
            );
          },
          throwsUnsupportedError,
        );
      });

      test('should contain all major merchant categories', () {
        // Act
        final patterns = service.getPatterns();

        // Assert - Check for presence of major categories
        final ids = patterns.map((p) => p.id).toSet();

        expect(ids, contains('indomaret'));
        expect(ids, contains('alfamart'));
        expect(ids, contains('starbucks'));
        expect(ids, contains('kfc'));
        expect(ids, contains('mcdonalds'));
        expect(ids, contains('tokopedia'));
        expect(ids, contains('gojek'));
        expect(ids, contains('pln'));
      });
    });

    group('Category mapping', () {
      test('should map minimarkets to Belanja Harian', () {
        final minimarkets = ['indomaret', 'alfamart', 'superindo', 'giant'];

        for (final id in minimarkets) {
          final result = service.findById(id);
          expect(result?.defaultCategoryName, 'Belanja Harian',
              reason: 'Merchant $id should map to Belanja Harian');
        }
      });

      test('should map coffee shops to Makanan & Minuman', () {
        final coffeeShops = ['starbucks', 'excelso', 'coffee_bean'];

        for (final id in coffeeShops) {
          final result = service.findById(id);
          expect(result?.defaultCategoryName, 'Makanan & Minuman',
              reason: 'Merchant $id should map to Makanan & Minuman');
        }
      });

      test('should map fast food to Makanan & Minuman', () {
        final fastFood = ['kfc', 'mcdonalds', 'burger_king', 'pizza_hut'];

        for (final id in fastFood) {
          final result = service.findById(id);
          expect(result?.defaultCategoryName, 'Makanan & Minuman',
              reason: 'Merchant $id should map to Makanan & Minuman');
        }
      });

      test('should map food delivery to Makanan & Minuman', () {
        final foodDelivery = ['gofood', 'grabfood', 'shopee_food'];

        for (final id in foodDelivery) {
          final result = service.findById(id);
          expect(result?.defaultCategoryName, 'Makanan & Minuman',
              reason: 'Merchant $id should map to Makanan & Minuman');
        }
      });

      test('should map e-commerce to Belanja', () {
        final ecommerce = ['tokopedia', 'shopee', 'lazada', 'blibli'];

        for (final id in ecommerce) {
          final result = service.findById(id);
          expect(result?.defaultCategoryName, 'Belanja',
              reason: 'Merchant $id should map to Belanja');
        }
      });

      test('should map transportation to Transportasi', () {
        final transportation = ['traveloka', 'gojek', 'grab', 'blue_bird'];

        for (final id in transportation) {
          final result = service.findById(id);
          expect(result?.defaultCategoryName, 'Transportasi',
              reason: 'Merchant $id should map to Transportasi');
        }
      });

      test('should map utilities to Tagihan & Utilitas', () {
        final utilities = ['pln', 'pdam', 'telkom', 'xl', 'telkomsel'];

        for (final id in utilities) {
          final result = service.findById(id);
          expect(result?.defaultCategoryName, 'Tagihan & Utilitas',
              reason: 'Merchant $id should map to Tagihan & Utilitas');
        }
      });

      test('should map pharmacies to Kesehatan', () {
        final pharmacies = ['kimia_farma', 'k24', 'century'];

        for (final id in pharmacies) {
          final result = service.findById(id);
          expect(result?.defaultCategoryName, 'Kesehatan',
              reason: 'Merchant $id should map to Kesehatan');
        }
      });
    });
  });
}
