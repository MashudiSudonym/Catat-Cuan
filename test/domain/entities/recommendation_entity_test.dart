import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/entities/recommendation_entity.dart';

void main() {
  group('RecommendationEntity', () {
    group('Entity creation', () {
      test('should create entity with all required fields', () {
        final entity = RecommendationEntity(
          type: RecommendationType.excessiveSpending,
          title: 'Pengeluaran Berlebih',
          message: 'Pengeluaran makanan terlalu tinggi',
          value: 45.0,
          priority: RecommendationPriority.high,
        );

        expect(entity.type, equals(RecommendationType.excessiveSpending));
        expect(entity.title, equals('Pengeluaran Berlebih'));
        expect(entity.message, equals('Pengeluaran makanan terlalu tinggi'));
        expect(entity.value, equals(45.0));
        expect(entity.priority, equals(RecommendationPriority.high));
      });

      test('should create entity without optional value', () {
        final entity = RecommendationEntity(
          type: RecommendationType.healthy,
          title: 'Keuangan Sehat',
          message: 'Keuangan Anda dalam kondisi baik',
          priority: RecommendationPriority.low,
        );

        expect(entity.value, isNull);
      });

      test('should create entity with zero value', () {
        final entity = RecommendationEntity(
          type: RecommendationType.motivational,
          title: 'Semangat!',
          message: 'Teruslah menabung',
          value: 0.0,
          priority: RecommendationPriority.low,
        );

        expect(entity.value, equals(0.0));
      });
    });

    group('Immutability', () {
      test('should be immutable with copyWith', () {
        final entity = RecommendationEntity(
          type: RecommendationType.excessiveSpending,
          title: 'Original',
          message: 'Original message',
          value: 30.0,
          priority: RecommendationPriority.high,
        );

        final updated = entity.copyWith(
          title: 'Updated',
          priority: RecommendationPriority.medium,
        );

        expect(entity.title, equals('Original')); // Original unchanged
        expect(entity.priority, equals(RecommendationPriority.high));
        expect(updated.title, equals('Updated')); // Copy updated
        expect(updated.priority, equals(RecommendationPriority.medium));
      });
    });
  });

  group('RecommendationType enum', () {
    group('fromString', () {
      test('should parse excessive_spending', () {
        final type = RecommendationType.fromString('excessive_spending');
        expect(type, equals(RecommendationType.excessiveSpending));
      });

      test('should parse potential_savings', () {
        final type = RecommendationType.fromString('potential_savings');
        expect(type, equals(RecommendationType.potentialSavings));
      });

      test('should parse imbalance', () {
        final type = RecommendationType.fromString('imbalance');
        expect(type, equals(RecommendationType.imbalance));
      });

      test('should parse healthy', () {
        final type = RecommendationType.fromString('healthy');
        expect(type, equals(RecommendationType.healthy));
      });

      test('should parse motivational', () {
        final type = RecommendationType.fromString('motivational');
        expect(type, equals(RecommendationType.motivational));
      });

      test('should default to healthy for invalid value', () {
        final type = RecommendationType.fromString('invalid_type');
        expect(type, equals(RecommendationType.healthy));
      });

      test('should default to healthy for empty string', () {
        final type = RecommendationType.fromString('');
        expect(type, equals(RecommendationType.healthy));
      });

      test('should be case-sensitive (exact match required)', () {
        final type1 = RecommendationType.fromString('EXCESSIVE_SPENDING');
        final type2 = RecommendationType.fromString('Excessive_Spending');
        final type3 = RecommendationType.fromString('excessive_spending');

        expect(type1, equals(RecommendationType.healthy)); // Falls back to default
        expect(type2, equals(RecommendationType.healthy)); // Falls back to default
        expect(type3, equals(RecommendationType.excessiveSpending)); // Exact match
      });
    });

    group('displayName', () {
      test('should return Indonesian name for excessiveSpending', () {
        expect(RecommendationType.excessiveSpending.displayName, equals('Pengeluaran Berlebih'));
      });

      test('should return Indonesian name for potentialSavings', () {
        expect(RecommendationType.potentialSavings.displayName, equals('Potensi Tabungan'));
      });

      test('should return Indonesian name for imbalance', () {
        expect(RecommendationType.imbalance.displayName, equals('Ketidakseimbangan'));
      });

      test('should return Indonesian name for healthy', () {
        expect(RecommendationType.healthy.displayName, equals('Keuangan Sehat'));
      });

      test('should return Indonesian name for motivational', () {
        expect(RecommendationType.motivational.displayName, equals('Motivasi'));
      });
    });

    group('icon', () {
      test('should return icon for excessiveSpending', () {
        expect(RecommendationType.excessiveSpending.icon, equals('⚠️'));
      });

      test('should return icon for potentialSavings', () {
        expect(RecommendationType.potentialSavings.icon, equals('💰'));
      });

      test('should return icon for imbalance', () {
        expect(RecommendationType.imbalance.icon, equals('📉'));
      });

      test('should return icon for healthy', () {
        expect(RecommendationType.healthy.icon, equals('✅'));
      });

      test('should return icon for motivational', () {
        expect(RecommendationType.motivational.icon, equals('💡'));
      });
    });

    group('value property', () {
      test('should return "excessive_spending" for excessiveSpending', () {
        expect(RecommendationType.excessiveSpending.value, equals('excessive_spending'));
      });

      test('should return "potential_savings" for potentialSavings', () {
        expect(RecommendationType.potentialSavings.value, equals('potential_savings'));
      });

      test('should return "imbalance" for imbalance', () {
        expect(RecommendationType.imbalance.value, equals('imbalance'));
      });

      test('should return "healthy" for healthy', () {
        expect(RecommendationType.healthy.value, equals('healthy'));
      });

      test('should return "motivational" for motivational', () {
        expect(RecommendationType.motivational.value, equals('motivational'));
      });
    });
  });

  group('RecommendationPriority enum', () {
    group('fromString', () {
      test('should parse high', () {
        final priority = RecommendationPriority.fromString('high');
        expect(priority, equals(RecommendationPriority.high));
      });

      test('should parse medium', () {
        final priority = RecommendationPriority.fromString('medium');
        expect(priority, equals(RecommendationPriority.medium));
      });

      test('should parse low', () {
        final priority = RecommendationPriority.fromString('low');
        expect(priority, equals(RecommendationPriority.low));
      });

      test('should default to low for invalid value', () {
        final priority = RecommendationPriority.fromString('invalid');
        expect(priority, equals(RecommendationPriority.low));
      });

      test('should default to low for empty string', () {
        final priority = RecommendationPriority.fromString('');
        expect(priority, equals(RecommendationPriority.low));
      });

      test('should be case-sensitive', () {
        final priority1 = RecommendationPriority.fromString('HIGH');
        final priority2 = RecommendationPriority.fromString('High');
        final priority3 = RecommendationPriority.fromString('high');

        expect(priority1, equals(RecommendationPriority.low)); // Falls back to default
        expect(priority2, equals(RecommendationPriority.low)); // Falls back to default
        expect(priority3, equals(RecommendationPriority.high)); // Exact match
      });
    });

    group('displayName', () {
      test('should return Indonesian name for high', () {
        expect(RecommendationPriority.high.displayName, equals('Tinggi'));
      });

      test('should return Indonesian name for medium', () {
        expect(RecommendationPriority.medium.displayName, equals('Sedang'));
      });

      test('should return Indonesian name for low', () {
        expect(RecommendationPriority.low.displayName, equals('Rendah'));
      });
    });

    group('sortValue', () {
      test('should return 3 for high priority', () {
        expect(RecommendationPriority.high.sortValue, equals(3));
      });

      test('should return 2 for medium priority', () {
        expect(RecommendationPriority.medium.sortValue, equals(2));
      });

      test('should return 1 for low priority', () {
        expect(RecommendationPriority.low.sortValue, equals(1));
      });

      test('should allow sorting by importance', () {
        final priorities = [
          RecommendationPriority.low,
          RecommendationPriority.high,
          RecommendationPriority.medium,
        ];

        final sorted = List.from(priorities)..sort((a, b) => b.sortValue.compareTo(a.sortValue));

        expect(sorted, equals([
          RecommendationPriority.high,
          RecommendationPriority.medium,
          RecommendationPriority.low,
        ]));
      });
    });

    group('colorValue', () {
      test('should return red hex for high priority', () {
        expect(RecommendationPriority.high.colorValue, equals('#EF4444'));
      });

      test('should return orange hex for medium priority', () {
        expect(RecommendationPriority.medium.colorValue, equals('#F59E0B'));
      });

      test('should return green hex for low priority', () {
        expect(RecommendationPriority.low.colorValue, equals('#10B981'));
      });
    });

    group('value property', () {
      test('should return "high" for high priority', () {
        expect(RecommendationPriority.high.value, equals('high'));
      });

      test('should return "medium" for medium priority', () {
        expect(RecommendationPriority.medium.value, equals('medium'));
      });

      test('should return "low" for low priority', () {
        expect(RecommendationPriority.low.value, equals('low'));
      });
    });
  });

  group('Real-world scenarios', () {
    test('should create excessive spending recommendation', () {
      final entity = RecommendationEntity(
        type: RecommendationType.excessiveSpending,
        title: 'Pengeluaran Makanan Berlebih',
        message: 'Pengeluaran makanan mencapai 45% dari total pengeluaran',
        value: 45.0,
        priority: RecommendationPriority.high,
      );

      expect(entity.type.icon, equals('⚠️'));
      expect(entity.priority.colorValue, equals('#EF4444'));
      expect(entity.priority.sortValue, equals(3));
    });

    test('should create healthy financial recommendation', () {
      final entity = RecommendationEntity(
        type: RecommendationType.healthy,
        title: 'Keuangan Sehat',
        message: 'Keuangan Anda dalam kondisi sehat dan seimbang',
        priority: RecommendationPriority.low,
      );

      expect(entity.type.icon, equals('✅'));
      expect(entity.priority.displayName, equals('Rendah'));
      expect(entity.priority.colorValue, equals('#10B981'));
    });

    test('should create potential savings recommendation', () {
      final entity = RecommendationEntity(
        type: RecommendationType.potentialSavings,
        title: 'Potensi Hemat Transport',
        message: 'Anda bisa hemat hingga Rp 500.000 dengan menggunakan transport umum',
        value: 500000,
        priority: RecommendationPriority.medium,
      );

      expect(entity.type.icon, equals('💰'));
      expect(entity.priority.displayName, equals('Sedang'));
      expect(entity.priority.colorValue, equals('#F59E0B'));
    });

    test('should create imbalance recommendation', () {
      final entity = RecommendationEntity(
        type: RecommendationType.imbalance,
        title: 'Ketidakseimbangan',
        message: 'Pengeluaran melebihi pemasukan bulan ini',
        priority: RecommendationPriority.high,
      );

      expect(entity.type.icon, equals('📉'));
      expect(entity.type.displayName, equals('Ketidakseimbangan'));
    });

    test('should create motivational recommendation', () {
      final entity = RecommendationEntity(
        type: RecommendationType.motivational,
        title: 'Hebat!',
        message: 'Anda berhasil menabung 30% dari pemasukan',
        value: 30.0,
        priority: RecommendationPriority.low,
      );

      expect(entity.type.icon, equals('💡'));
      expect(entity.priority.sortValue, equals(1));
    });
  });
}
