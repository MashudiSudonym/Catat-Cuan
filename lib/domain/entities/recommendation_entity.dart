import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommendation_entity.freezed.dart';

/// Entity untuk rekomendasi keuangan
@freezed
abstract class RecommendationEntity with _$RecommendationEntity {
  const factory RecommendationEntity({
    /// Type of recommendation
    required RecommendationType type,

    /// Recommendation title
    required String title,

    /// Detailed recommendation message
    required String message,

    /// Related value (e.g., percentage)
    double? value,

    /// Priority level
    required RecommendationPriority priority,
  }) = _RecommendationEntity;
}

/// Enum untuk tipe rekomendasi
enum RecommendationType {
  excessiveSpending('excessive_spending'),
  potentialSavings('potential_savings'),
  imbalance('imbalance'),
  healthy('healthy'),
  motivational('motivational');

  const RecommendationType(this.value);

  final String value;

  /// Get enum dari string value
  static RecommendationType fromString(String value) {
    return RecommendationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => RecommendationType.healthy,
    );
  }

  /// Get display name dalam Bahasa Indonesia
  String get displayName {
    switch (this) {
      case RecommendationType.excessiveSpending:
        return 'Pengeluaran Berlebih';
      case RecommendationType.potentialSavings:
        return 'Potensi Tabungan';
      case RecommendationType.imbalance:
        return 'Ketidakseimbangan';
      case RecommendationType.healthy:
        return 'Keuangan Sehat';
      case RecommendationType.motivational:
        return 'Motivasi';
    }
  }

  /// Get icon untuk tipe rekomendasi
  String get icon {
    switch (this) {
      case RecommendationType.excessiveSpending:
        return '⚠️';
      case RecommendationType.potentialSavings:
        return '💰';
      case RecommendationType.imbalance:
        return '📉';
      case RecommendationType.healthy:
        return '✅';
      case RecommendationType.motivational:
        return '💡';
    }
  }
}

/// Enum untuk prioritas rekomendasi
enum RecommendationPriority {
  high('high'),
  medium('medium'),
  low('low');

  const RecommendationPriority(this.value);

  final String value;

  /// Get enum dari string value
  static RecommendationPriority fromString(String value) {
    return RecommendationPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => RecommendationPriority.low,
    );
  }

  /// Get display name dalam Bahasa Indonesia
  String get displayName {
    switch (this) {
      case RecommendationPriority.high:
        return 'Tinggi';
      case RecommendationPriority.medium:
        return 'Sedang';
      case RecommendationPriority.low:
        return 'Rendah';
    }
  }

  /// Get nilai untuk sorting (higher = more important)
  int get sortValue {
    switch (this) {
      case RecommendationPriority.high:
        return 3;
      case RecommendationPriority.medium:
        return 2;
      case RecommendationPriority.low:
        return 1;
    }
  }

  /// Get color untuk prioritas
  String get colorValue {
    switch (this) {
      case RecommendationPriority.high:
        return '#EF4444'; // Red
      case RecommendationPriority.medium:
        return '#F59E0B'; // Orange
      case RecommendationPriority.low:
        return '#10B981'; // Green
    }
  }
}
