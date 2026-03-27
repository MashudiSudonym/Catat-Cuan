import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/parsers/receipt_amount_parser.dart';

void main() {
  group('ReceiptAmountParser - parseAmount', () {
    group('with keyword "total"', () {
      test('should extract amount with "Total" keyword', () {
        const text = '''
TOKO MAJU JAYA
Total: Rp 75.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(75000));
        expect(result.confidence, equals(0.9));
        expect(result.source, contains('keyword'));
        expect(result.source, contains('total'));
      });

      test('should extract amount with "TOTAL" uppercase', () {
        const text = '''
TOKO MAJU JAYA
TOTAL: 75.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(75000));
        expect(result.confidence, equals(0.9));
      });

      test('should extract amount with "TOTAL BAYAR" keyword', () {
        const text = '''
TOKO MAJU JAYA
TOTAL BAYAR: Rp 100.500
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(100500));
        expect(result.confidence, equals(0.9));
      });

      test('should extract amount with "Tagihan" keyword', () {
        const text = '''
TOKO MAJU JAYA
Tagihan: Rp 50.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(50000));
        expect(result.confidence, equals(0.9));
      });
    });

    group('with keyword "jumlah"', () {
      test('should extract amount with "Jumlah" keyword', () {
        const text = '''
TOKO MAJU JAYA
Jumlah: 125.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(125000));
        expect(result.confidence, equals(0.9));
      });
    });

    group('with keyword "subtotal"', () {
      test('should extract amount with "Subtotal" keyword', () {
        const text = '''
TOKO MAJU JAYA
Subtotal: 45.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(45000));
        expect(result.confidence, equals(0.9));
      });
    });

    group('with keyword "grand total"', () {
      test('should extract amount with "Grand Total" keyword', () {
        const text = '''
TOKO MAJU JAYA
Grand Total: 200.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(200000));
        expect(result.confidence, equals(0.9));
      });
    });

    group('with keyword "amount"', () {
      test('should extract amount with "Amount" keyword', () {
        const text = '''
TOKO MAJU JAYA
Amount: 75.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(75000));
        expect(result.confidence, equals(0.9));
      });
    });

    group('with keyword "bill"', () {
      test('should extract amount with "Bill" keyword', () {
        const text = '''
TOKO MAJU JAYA
Bill: 90.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(90000));
        expect(result.confidence, equals(0.9));
      });
    });

    group('Indonesian currency formats', () {
      test('should extract amount with "Rp" prefix', () {
        const text = '''
TOKO MAJU JAYA
Total: Rp 75.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(75000));
      });

      test('should extract amount with "RP" uppercase prefix', () {
        const text = '''
TOKO MAJU JAYA
Total: RP 75.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(75000));
      });

      test('should extract amount with "Rupiah" prefix', () {
        const text = '''
TOKO MAJU JAYA
Total: Rupiah 75.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(75000));
      });

      test('should extract amount with "IDR" prefix', () {
        const text = '''
TOKO MAJU JAYA
Total: IDR 75.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(75000));
      });
    });

    group('Amount formats', () {
      test('should extract amount with dot separator (75.000)', () {
        const text = '''
TOKO MAJU JAYA
Total: 75.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(75000));
      });

      test('should extract amount without separator (75000)', () {
        const text = '''
TOKO MAJU JAYA
Total: 75000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(75000));
      });

      test('should extract amount with decimal (75.500,50)', () {
        const text = '''
TOKO MAJU JAYA
Total: 75.500,50
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(75500.50));
      });

      test('should extract large amount (1.500.000)', () {
        const text = '''
TOKO MAJU JAYA
Total: 1.500.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(1500000));
      });

      test('should extract very large amount (10.500.000)', () {
        const text = '''
TOKO MAJU JAYA
Total: 10.500.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(10500000));
      });

      test('should handle international comma format (75,000) - returns null for Indonesian parser', () {
        const text = '''
TOKO MAJU JAYA
Total: 75,000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        // Indonesian parser expects dots for thousand separators
        // Comma format is not supported for Indonesian receipts
        expect(result.amount, isNull);
      });
    });

    group('Fallback extraction - no keyword', () {
      test('should extract largest amount when no keyword found', () {
        const text = '''
TOKO MAJU JAYA
Beras 25.000
Gula 15.000
Telur 50.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(50000));
        expect(result.confidence, equals(0.5));
        expect(result.source, contains('fallback'));
      });

      test('should return null when no amount found', () {
        const text = '''
TOKO MAJU JAYA
Barang X
Barang Y
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, isNull);
        expect(result.confidence, equals(0));
        expect(result.source, contains('no amount found'));
      });
    });

    group('Amount validation', () {
      test('should reject amount below minimum (1000)', () {
        const text = '''
TOKO MAJU JAYA
Total: 500
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, isNull);
        expect(result.confidence, equals(0));
      });

      test('should reject amount above maximum (100.000.000)', () {
        const text = '''
TOKO MAJU JAYA
Total: 150.000.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, isNull);
        expect(result.confidence, equals(0));
      });

      test('should accept minimum valid amount (1000)', () {
        const text = '''
TOKO MAJU JAYA
Total: 1.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(1000));
      });

      test('should accept maximum valid amount (100.000.000)', () {
        const text = '''
TOKO MAJU JAYA
Total: 100.000.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(100000000));
      });
    });

    group('Invalid formats', () {
      test('should handle empty text', () {
        const text = '';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, isNull);
        expect(result.confidence, equals(0));
      });

      test('should handle text without numbers', () {
        const text = '''
TOKO MAJU JAYA
Total: abc
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, isNull);
        expect(result.confidence, equals(0));
      });

      test('should handle keyword without amount', () {
        const text = '''
TOKO MAJU JAYA
Total:
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, isNull);
        expect(result.confidence, equals(0));
      });
    });

    group('Real-world receipt examples', () {
      test('should parse minimarket receipt', () {
        const text = '''
MINIMARKET INDAH
18/03/2026 14:30
1. ABC123 2x 25.000 = 50.000
2. XYZ456 1x 25.000 = 25.000
----------------------
TOTAL       75.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(75000));
        expect(result.confidence, equals(0.9));
      });

      test('should parse restaurant receipt', () {
        const text = '''
RESTORAN LEZAT
No. 12345
Nasi Goreng  35.000
Es Teh        5.000
-----------------
JUMLAH       40.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(40000));
        expect(result.confidence, equals(0.9));
      });

      test('should parse pharmacy receipt', () {
        const text = '''
APOTIK SEHAT
18 Mar 2026
Paracetamol 1x 15.000
Vitamin C   1x 50.000
--------------------
GRAND TOTAL  65.000
''';
        final result = ReceiptAmountParser.parseAmount(text);

        expect(result.amount, equals(65000));
        expect(result.confidence, equals(0.9));
      });
    });
  });

  group('ReceiptAmountParser - parseCurrency', () {
    test('should parse simple number', () {
      final result = ReceiptAmountParser.parseCurrency('75000');

      expect(result, equals(75000));
    });

    test('should parse Indonesian format with dots', () {
      final result = ReceiptAmountParser.parseCurrency('75.000');

      expect(result, equals(75000));
    });

    test('should parse Indonesian format with decimal', () {
      final result = ReceiptAmountParser.parseCurrency('75.500,50');

      expect(result, equals(75500.50));
    });

    test('should handle international comma format - returns decimal for Indonesian parser', () {
      final result = ReceiptAmountParser.parseCurrency('75,000');

      // Indonesian parser interprets comma as decimal separator
      // This is expected behavior for Indonesian currency format
      expect(result, equals(75.0));
    });

    test('should return null for invalid format', () {
      final result = ReceiptAmountParser.parseCurrency('abc');

      expect(result, isNull);
    });
  });

  group('ReceiptAmountParser - findLargestReasonableAmount', () {
    test('should find largest amount in text', () {
      const text = '''
Beras 25.000
Gula 15.000
Telur 50.000
''';
      final result = ReceiptAmountParser.findLargestReasonableAmount(text);

      expect(result, equals(50000));
    });

    test('should return null when no amounts found', () {
      const text = '''
Barang X
Barang Y
''';
      final result = ReceiptAmountParser.findLargestReasonableAmount(text);

      expect(result, isNull);
    });

    test('should ignore amounts outside reasonable range', () {
      const text = '''
Barang A 500
Barang B 50.000
Barang C 150.000.000
''';
      final result = ReceiptAmountParser.findLargestReasonableAmount(text);

      expect(result, equals(50000));
    });
  });

  group('ReceiptAmountParser - isConfidentEnough', () {
    test('should return true for confidence above threshold', () {
      expect(ReceiptAmountParser.isConfidentEnough(0.8), isTrue);
      expect(ReceiptAmountParser.isConfidentEnough(0.9), isTrue);
    });

    test('should return false for confidence below threshold', () {
      expect(ReceiptAmountParser.isConfidentEnough(0.5), isFalse);
      expect(ReceiptAmountParser.isConfidentEnough(0.6), isFalse);
    });

    test('should return true for confidence at threshold', () {
      expect(ReceiptAmountParser.isConfidentEnough(0.7), isTrue);
    });
  });
}
