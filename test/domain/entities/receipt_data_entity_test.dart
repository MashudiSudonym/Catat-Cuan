import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/entities/receipt_data_entity.dart';

void main() {
  group('ReceiptDataEntity', () {
    group('Entity creation', () {
      test('should create with all fields including optional fields', () {
        final scannedAt = DateTime.now();
        final entity = ReceiptDataEntity(
          rawText: 'Indomaret 15/03/2024 Total 75000',
          extractedAmount: 75000.0,
          extractedDate: DateTime(2024, 3, 15),
          merchantName: 'Indomaret',
          items: ['Item 1', 'Item 2'],
          confidenceScore: 0.85,
          scannedAt: scannedAt,
        );

        expect(entity.rawText, equals('Indomaret 15/03/2024 Total 75000'));
        expect(entity.extractedAmount, equals(75000.0));
        expect(entity.extractedDate, equals(DateTime(2024, 3, 15)));
        expect(entity.merchantName, equals('Indomaret'));
        expect(entity.items, equals(['Item 1', 'Item 2']));
        expect(entity.confidenceScore, equals(0.85));
        expect(entity.scannedAt, equals(scannedAt));
      });

      test('should create with only required fields', () {
        final scannedAt = DateTime.now();
        final entity = ReceiptDataEntity(
          confidenceScore: 0.5,
          scannedAt: scannedAt,
        );

        expect(entity.rawText, isNull);
        expect(entity.extractedAmount, isNull);
        expect(entity.extractedDate, isNull);
        expect(entity.merchantName, isNull);
        expect(entity.items, isEmpty); // Default value
        expect(entity.confidenceScore, equals(0.5));
        expect(entity.scannedAt, equals(scannedAt));
      });

      test('should use default empty list for items', () {
        final entity = ReceiptDataEntity(
          confidenceScore: 0.5,
          scannedAt: DateTime.now(),
        );

        expect(entity.items, isEmpty);
        expect(entity.items, equals([]));
      });

      test('should handle null optional fields', () {
        final entity = ReceiptDataEntity(
          rawText: null,
          extractedAmount: null,
          extractedDate: null,
          merchantName: null,
          items: [],
          confidenceScore: 0.9,
          scannedAt: DateTime.now(),
        );

        expect(entity.rawText, isNull);
        expect(entity.extractedAmount, isNull);
        expect(entity.extractedDate, isNull);
        expect(entity.merchantName, isNull);
      });

      test('should handle empty items list', () {
        final entity = ReceiptDataEntity(
          confidenceScore: 0.8,
          scannedAt: DateTime.now(),
          items: [],
        );

        expect(entity.items, isEmpty);
      });

      test('should handle single item', () {
        final entity = ReceiptDataEntity(
          confidenceScore: 0.8,
          scannedAt: DateTime.now(),
          items: ['Mie Instan'],
        );

        expect(entity.items, hasLength(1));
        expect(entity.items.first, equals('Mie Instan'));
      });

      test('should handle multiple items', () {
        final entity = ReceiptDataEntity(
          confidenceScore: 0.8,
          scannedAt: DateTime.now(),
          items: ['Mie Instan', 'Air Mineral', 'Telur'],
        );

        expect(entity.items, hasLength(3));
      });
    });

    group('Immutability', () {
      test('should be immutable with copyWith', () {
        final scannedAt = DateTime.now();
        final entity = ReceiptDataEntity(
          rawText: 'Original',
          extractedAmount: 100000.0,
          extractedDate: DateTime(2024, 3, 15),
          merchantName: 'Store A',
          items: ['Item 1'],
          confidenceScore: 0.7,
          scannedAt: scannedAt,
        );

        final updated = entity.copyWith(
          rawText: 'Updated',
          confidenceScore: 0.9,
        );

        expect(entity.rawText, equals('Original')); // Original unchanged
        expect(entity.confidenceScore, equals(0.7));
        expect(updated.rawText, equals('Updated')); // Copy updated
        expect(updated.confidenceScore, equals(0.9));
        expect(updated.extractedAmount, equals(100000.0)); // Unchanged field preserved
      });

      test('should copy with items', () {
        final entity = ReceiptDataEntity(
          confidenceScore: 0.8,
          scannedAt: DateTime.now(),
          items: ['Item 1'],
        );

        final updated = entity.copyWith(items: ['Item 1', 'Item 2']);

        expect(entity.items, hasLength(1)); // Original unchanged
        expect(updated.items, hasLength(2)); // Copy updated
      });

      test('should copy with all optional fields set', () {
        final scannedAt = DateTime.now();
        final entity = ReceiptDataEntity(
          confidenceScore: 0.5,
          scannedAt: scannedAt,
        );

        final updated = entity.copyWith(
          rawText: 'New text',
          extractedAmount: 50000.0,
          extractedDate: DateTime(2024, 3, 20),
          merchantName: 'Alfamart',
        );

        expect(updated.rawText, equals('New text'));
        expect(updated.extractedAmount, equals(50000.0));
        expect(updated.merchantName, equals('Alfamart'));
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        final scannedAt = DateTime.now();
        final entity1 = ReceiptDataEntity(
          rawText: 'Test',
          extractedAmount: 75000.0,
          extractedDate: DateTime(2024, 3, 15),
          merchantName: 'Store',
          items: ['Item'],
          confidenceScore: 0.8,
          scannedAt: scannedAt,
        );

        final entity2 = ReceiptDataEntity(
          rawText: 'Test',
          extractedAmount: 75000.0,
          extractedDate: DateTime(2024, 3, 15),
          merchantName: 'Store',
          items: ['Item'],
          confidenceScore: 0.8,
          scannedAt: scannedAt,
        );

        expect(entity1, equals(entity2));
      });

      test('should not be equal when rawText differs', () {
        final scannedAt = DateTime.now();
        final entity1 = ReceiptDataEntity(
          rawText: 'Text A',
          confidenceScore: 0.8,
          scannedAt: scannedAt,
        );

        final entity2 = ReceiptDataEntity(
          rawText: 'Text B',
          confidenceScore: 0.8,
          scannedAt: scannedAt,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when extractedAmount differs', () {
        final scannedAt = DateTime.now();
        final entity1 = ReceiptDataEntity(
          extractedAmount: 50000.0,
          confidenceScore: 0.8,
          scannedAt: scannedAt,
        );

        final entity2 = ReceiptDataEntity(
          extractedAmount: 75000.0,
          confidenceScore: 0.8,
          scannedAt: scannedAt,
        );

        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when items differ', () {
        final scannedAt = DateTime.now();
        final entity1 = ReceiptDataEntity(
          items: ['Item 1'],
          confidenceScore: 0.8,
          scannedAt: scannedAt,
        );

        final entity2 = ReceiptDataEntity(
          items: ['Item 2'],
          confidenceScore: 0.8,
          scannedAt: scannedAt,
        );

        expect(entity1, isNot(equals(entity2)));
      });
    });

    group('Real-world scenarios', () {
      test('should represent successful receipt scan from minimarket', () {
        final entity = ReceiptDataEntity(
          rawText: 'INDOMARET 15/03/2024 14:30 TOTAL 75000',
          extractedAmount: 75000.0,
          extractedDate: DateTime(2024, 3, 15),
          merchantName: 'INDOMARET',
          items: ['Mie Instan', 'Air Mineral'],
          confidenceScore: 0.92,
          scannedAt: DateTime.now(),
        );

        expect(entity.extractedAmount, equals(75000.0));
        expect(entity.merchantName, contains('INDOMARET'));
        expect(entity.items, hasLength(2));
        expect(entity.confidenceScore, greaterThan(0.9));
      });

      test('should represent receipt scan with no merchant detected', () {
        final entity = ReceiptDataEntity(
          rawText: 'Total 150000',
          extractedAmount: 150000.0,
          merchantName: null,
          items: [],
          confidenceScore: 0.65,
          scannedAt: DateTime.now(),
        );

        expect(entity.extractedAmount, equals(150000.0));
        expect(entity.merchantName, isNull);
        expect(entity.confidenceScore, greaterThan(0.5));
      });

      test('should represent failed receipt scan', () {
        final entity = ReceiptDataEntity(
          rawText: 'blurry unreadable text',
          extractedAmount: null,
          extractedDate: null,
          merchantName: null,
          items: [],
          confidenceScore: 0.15,
          scannedAt: DateTime.now(),
        );

        expect(entity.extractedAmount, isNull);
        expect(entity.confidenceScore, lessThan(0.5));
      });

      test('should represent restaurant receipt', () {
        final entity = ReceiptDataEntity(
          rawText: 'Restoran Padang 20/03/2024 Total 125000',
          extractedAmount: 125000.0,
          extractedDate: DateTime(2024, 3, 20),
          merchantName: 'Restoran Padang',
          items: ['Nasi Rendang', 'Es Teh'],
          confidenceScore: 0.88,
          scannedAt: DateTime.now(),
        );

        expect(entity.merchantName, contains('Padang'));
        expect(entity.items, contains('Nasi Rendang'));
      });
    });

    group('Edge cases', () {
      test('should handle very long raw text', () {
        final longText = 'Receipt text ' * 100;
        final entity = ReceiptDataEntity(
          rawText: longText,
          confidenceScore: 0.8,
          scannedAt: DateTime.now(),
        );

        expect(entity.rawText?.length, greaterThan(1000));
      });

      test('should handle very large amount', () {
        final entity = ReceiptDataEntity(
          extractedAmount: 999999999.99,
          confidenceScore: 0.9,
          scannedAt: DateTime.now(),
        );

        expect(entity.extractedAmount, equals(999999999.99));
      });

      test('should handle zero amount', () {
        final entity = ReceiptDataEntity(
          extractedAmount: 0.0,
          confidenceScore: 0.8,
          scannedAt: DateTime.now(),
        );

        expect(entity.extractedAmount, equals(0.0));
      });

      test('should handle empty raw text', () {
        final entity = ReceiptDataEntity(
          rawText: '',
          confidenceScore: 0.8,
          scannedAt: DateTime.now(),
        );

        expect(entity.rawText, equals(''));
      });

      test('should handle empty merchant name', () {
        final entity = ReceiptDataEntity(
          merchantName: '',
          confidenceScore: 0.8,
          scannedAt: DateTime.now(),
        );

        expect(entity.merchantName, equals(''));
      });

      test('should handle confidence score boundaries', () {
        final minScore = ReceiptDataEntity(
          confidenceScore: 0.0,
          scannedAt: DateTime.now(),
        );

        final maxScore = ReceiptDataEntity(
          confidenceScore: 1.0,
          scannedAt: DateTime.now(),
        );

        expect(minScore.confidenceScore, equals(0.0));
        expect(maxScore.confidenceScore, equals(1.0));
      });

      test('should handle special characters in raw text', () {
        final entity = ReceiptDataEntity(
          rawText: 'Total: Rp 75.000,- @Indomaret #123',
          confidenceScore: 0.85,
          scannedAt: DateTime.now(),
        );

        expect(entity.rawText, contains('@'));
        expect(entity.rawText, contains('#'));
        expect(entity.rawText, contains(':'));
      });

      test('should handle unicode/emoji in merchant name', () {
        final entity = ReceiptDataEntity(
          merchantName: '🏪 Toko Makmur ☕️',
          confidenceScore: 0.8,
          scannedAt: DateTime.now(),
        );

        expect(entity.merchantName, contains('🏪'));
        expect(entity.merchantName, contains('☕️'));
      });
    });

    group('Items list handling', () {
      test('should handle items with special characters', () {
        final entity = ReceiptDataEntity(
          items: ['Kopi Susu (Large)', 'Ice Tea @15k', 'Nasi Goreng*'],
          confidenceScore: 0.8,
          scannedAt: DateTime.now(),
        );

        expect(entity.items, contains('Kopi Susu (Large)'));
        expect(entity.items, contains('Ice Tea @15k'));
      });

      test('should handle very long item names', () {
        final longItem = 'Nasi Goreng Spesial dengan Telur, Sayuran, dan Sambal ' * 5;
        final entity = ReceiptDataEntity(
          items: [longItem],
          confidenceScore: 0.8,
          scannedAt: DateTime.now(),
        );

        expect(entity.items.first.length, greaterThan(100));
      });

      test('should handle many items', () {
        final items = List.generate(50, (i) => 'Item $i');
        final entity = ReceiptDataEntity(
          items: items,
          confidenceScore: 0.8,
          scannedAt: DateTime.now(),
        );

        expect(entity.items, hasLength(50));
      });
    });
  });
}
