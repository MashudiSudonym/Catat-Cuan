import '../entities/merchant_pattern_entity.dart';

/// Service interface untuk merchant pattern matching
///
/// Service ini menyediakan pola-pola merchant Indonesia
/// dan mencocokkannya dengan teks struk.
abstract class MerchantPatternService {
  /// Mendapatkan semua pola merchant yang tersedia
  ///
  /// Returns daftar semua pola merchant yang dikonfigurasi
  List<MerchantPatternEntity> getPatterns();

  /// Mencari merchant yang cocok dengan teks struk
  ///
  /// Parameters:
  /// - [receiptText]: Teks penuh dari struk
  ///
  /// Returns pola merchant yang cocok, atau null jika tidak ada yang cocok
  MerchantPatternEntity? findMatch(String receiptText);

  /// Mencari merchant berdasarkan pola nama di header struk
  ///
  /// Parameters:
  /// - [headerLines]: 5-10 baris pertama dari struk (header)
  ///
  /// Returns pola merchant yang cocok, atau null jika tidak ada yang cocok
  MerchantPatternEntity? findMatchInHeader(List<String> headerLines);

  /// Mendapatkan pola merchant berdasarkan ID
  ///
  /// Parameters:
  /// - [id]: ID pola merchant
  ///
  /// Returns pola merchant dengan ID tersebut, atau null jika tidak ditemukan
  MerchantPatternEntity? findById(String id);

  /// Mendapatkan pola merchant berdasarkan nama merchant
  ///
  /// Parameters:
  /// - [merchantName]: Nama merchant yang dicari
  ///
  /// Returns pola merchant dengan nama tersebut, atau null jika tidak ditemukan
  MerchantPatternEntity? findByName(String merchantName);
}
