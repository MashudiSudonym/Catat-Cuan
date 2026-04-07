import 'package:freezed_annotation/freezed_annotation.dart';

part 'merchant_pattern_entity.freezed.dart';

/// Entity untuk merepresentasikan pola merchant pada struk
///
/// Entity ini digunakan untuk mengenali merchant berdasarkan
/// pola teks pada struk (e.g., "INDOMARET", "ALFAMART")
@freezed
abstract class MerchantPatternEntity with _$MerchantPatternEntity {
  const MerchantPatternEntity._();

  const factory MerchantPatternEntity({
    /// ID unik untuk pola merchant
    required String id,

    /// Nama merchant yang akan ditampilkan ke user
    required String merchantName,

    /// Daftar pola nama yang dicari dalam struk
    /// Contoh: ['INDOMARET', 'INdicart', 'Point']
    required List<String> namePatterns,

    /// Daftar pola alamat yang dicari (opsional)
    /// Contoh: ['Jl.', 'Jalan', 'KAB', 'KOTA']
    required List<String> addressPatterns,

    /// Daftar pola header yang dicari (opsional)
    /// Contoh: ['TOKO', 'MINIMARKET', 'SUPERMARKET']
    required List<String> headerPatterns,

    /// Nama kategori default untuk merchant ini
    /// Ini adalah *nama kategori* yang harus cocok dengan CategoryEntity.name
    /// Contoh: 'Belanja Harian', 'Makanan & Minuman', 'Transportasi'
    required String defaultCategoryName,

    /// Nama alternatif/alias untuk merchant
    /// Contoh: ['Indo', 'Indomaret Point'] untuk Indomaret
    required List<String> aliases,

    /// Prioritas pencocokan (semakin tinggi semakin diprioritaskan)
    /// Digunakan ketika ada multiple merchant yang cocok
    required int priority,
  }) = _MerchantPatternEntity;

  /// Cek apakah teks cocok dengan pola nama merchant ini
  bool matchesName(String text) {
    final upperText = text.toUpperCase();
    return namePatterns.any((pattern) => upperText.contains(pattern));
  }

  /// Cek apakah teks cocok dengan pola alamat merchant ini
  bool matchesAddress(String text) {
    final upperText = text.toUpperCase();
    return addressPatterns.any((pattern) => upperText.contains(pattern));
  }

  /// Cek apakah teks cocok dengan pola header merchant ini
  bool matchesHeader(String text) {
    final upperText = text.toUpperCase();
    return headerPatterns.any((pattern) => upperText.contains(pattern));
  }
}

/// Entity untuk hasil parsing merchant dari struk
@freezed
abstract class MerchantParseResult with _$MerchantParseResult {
  const factory MerchantParseResult({
    /// Nama merchant yang terdeteksi (null jika tidak ditemukan)
    String? merchantName,

    /// Skor keyakinan (0.0 - 1.0)
    required double confidence,

    /// Pola merchant yang cocok (null jika tidak ditemukan)
    MerchantPatternEntity? matchedPattern,
  }) = _MerchantParseResult;

  const MerchantParseResult._();

  /// Cek apakah hasil cukup yakin
  bool get isConfident => confidence >= 0.7;

  /// Cek apakah merchant ditemukan
  bool get hasMerchant => merchantName != null && merchantName!.isNotEmpty;
}
