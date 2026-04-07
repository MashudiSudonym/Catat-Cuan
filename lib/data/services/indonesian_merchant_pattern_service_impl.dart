import 'package:catat_cuan/domain/entities/merchant_pattern_entity.dart';
import 'package:catat_cuan/domain/services/merchant_pattern_service.dart';

/// Implementasi merchant pattern service untuk retailer Indonesia
///
/// Service ini menyediakan pola-pola untuk retailer besar di Indonesia
/// seperti Indomaret, Alfamart, Starbucks, dll.
class IndonesianMerchantPatternServiceImpl implements MerchantPatternService {
  late final List<MerchantPatternEntity> _patterns;

  IndonesianMerchantPatternServiceImpl() {
    _patterns = _buildPatterns();
  }

  @override
  List<MerchantPatternEntity> getPatterns() => List.unmodifiable(_patterns);

  @override
  MerchantPatternEntity? findMatch(String receiptText) {
    final upperText = receiptText.toUpperCase();
    MerchantPatternEntity? bestMatch;
    double bestScore = 0.0;

    for (final pattern in _patterns) {
      double score = 0.0;

      // Cek nama pola (bobot tertinggi)
      for (final namePattern in pattern.namePatterns) {
        if (upperText.contains(namePattern)) {
          score += 0.6;
        }
      }

      // Cek header pola
      for (final headerPattern in pattern.headerPatterns) {
        if (upperText.contains(headerPattern)) {
          score += 0.2;
        }
      }

      // Cek alamat pola
      for (final addressPattern in pattern.addressPatterns) {
        if (upperText.contains(addressPattern)) {
          score += 0.1;
        }
      }

      if (score > bestScore && score >= 0.6) {
        bestScore = score;
        bestMatch = pattern;
      }
    }

    return bestMatch;
  }

  @override
  MerchantPatternEntity? findMatchInHeader(List<String> headerLines) {
    final headerText = headerLines.join('\n').toUpperCase();

    // Prioritaskan merchant dengan priority tertinggi
    final sortedPatterns = List<MerchantPatternEntity>.from(_patterns)
      ..sort((a, b) => b.priority.compareTo(a.priority));

    for (final pattern in sortedPatterns) {
      if (pattern.matchesName(headerText)) {
        return pattern;
      }
    }

    return null;
  }

  @override
  MerchantPatternEntity? findById(String id) {
    try {
      return _patterns.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  MerchantPatternEntity? findByName(String merchantName) {
    final upperName = merchantName.toUpperCase();

    // Cek exact match
    for (final pattern in _patterns) {
      if (pattern.merchantName.toUpperCase() == upperName) {
        return pattern;
      }
    }

    // Cek alias
    for (final pattern in _patterns) {
      for (final alias in pattern.aliases) {
        if (alias.toUpperCase() == upperName) {
          return pattern;
        }
      }
    }

    return null;
  }

  /// Membangun daftar pola merchant Indonesia
  List<MerchantPatternEntity> _buildPatterns() {
    return [
      // ==================== MINIMARKETS ====================
      MerchantPatternEntity(
        id: 'indomaret',
        merchantName: 'Indomaret',
        namePatterns: ['INDOMARET', 'INdicart', 'TOSERBA', 'POINT'],
        addressPatterns: ['JL.', 'JALAN', 'KAB', 'KOTA'],
        headerPatterns: ['TOKO', 'MINIMARKET'],
        defaultCategoryName: 'Belanja Harian',
        aliases: ['Indo', 'Indomaret Point', 'IndoMart'],
        priority: 100,
      ),

      MerchantPatternEntity(
        id: 'alfamart',
        merchantName: 'Alfamart',
        namePatterns: ['ALFAMART', 'ALFA', 'MIDI', 'DAN+DAN'],
        addressPatterns: ['JL.', 'JALAN', 'KAB', 'KOTA'],
        headerPatterns: ['TOKO', 'MINIMARKET'],
        defaultCategoryName: 'Belanja Harian',
        aliases: ['Alfa', 'Alfamidi'],
        priority: 100,
      ),

      MerchantPatternEntity(
        id: 'superindo',
        merchantName: 'Superindo',
        namePatterns: ['SUPERINDO', 'SUPER INDO'],
        addressPatterns: ['JL.', 'JALAN'],
        headerPatterns: ['SUPERMARKET', 'HYPERMARKET'],
        defaultCategoryName: 'Belanja Harian',
        aliases: [],
        priority: 95,
      ),

      MerchantPatternEntity(
        id: 'giant',
        merchantName: 'Giant',
        namePatterns: ['GIANT', 'GIANT EXPRESS', 'GIANT EKSTRA'],
        addressPatterns: ['JL.', 'JALAN'],
        headerPatterns: ['SUPERMARKET', 'HYPERMARKET'],
        defaultCategoryName: 'Belanja Harian',
        aliases: [],
        priority: 95,
      ),

      MerchantPatternEntity(
        id: 'lotte_mart',
        merchantName: 'Lotte Mart',
        namePatterns: ['LOTTE', 'LOTTE MART', 'LOTTEMART'],
        addressPatterns: ['JL.', 'JALAN'],
        headerPatterns: ['SUPERMARKET', 'HYPERMARKET', 'MALL'],
        defaultCategoryName: 'Belanja Harian',
        aliases: [],
        priority: 95,
      ),

      MerchantPatternEntity(
        id: 'hypermart',
        merchantName: 'Hypermart',
        namePatterns: ['HYPERMART', 'HYPER MART'],
        addressPatterns: ['JL.', 'JALAN', 'MALL'],
        headerPatterns: ['SUPERMARKET', 'HYPERMARKET'],
        defaultCategoryName: 'Belanja Harian',
        aliases: [],
        priority: 95,
      ),

      MerchantPatternEntity(
        id: 'lawson',
        merchantName: 'Lawson',
        namePatterns: ['LAWSON'],
        addressPatterns: ['JL.', 'JALAN'],
        headerPatterns: ['CONVENIENCE STORE', 'MINIMARKET'],
        defaultCategoryName: 'Belanja Harian',
        aliases: [],
        priority: 90,
      ),

      MerchantPatternEntity(
        id: 'circle_k',
        merchantName: 'Circle K',
        namePatterns: ['CIRCLE K', 'CIRCKLEK', 'CIRCLEK'],
        addressPatterns: ['JL.', 'JALAN'],
        headerPatterns: ['CONVENIENCE STORE'],
        defaultCategoryName: 'Belanja Harian',
        aliases: [],
        priority: 90,
      ),

      MerchantPatternEntity(
        id: 'seven_eleven',
        merchantName: '7-Eleven',
        namePatterns: ['7-ELEVEN', 'SEVEN', '7-11', '7ELEVEN'],
        addressPatterns: ['JL.', 'JALAN'],
        headerPatterns: ['CONVENIENCE STORE'],
        defaultCategoryName: 'Belanja Harian',
        aliases: [],
        priority: 90,
      ),

      MerchantPatternEntity(
        id: 'transmart',
        merchantName: 'Transmart',
        namePatterns: ['TRANSMART', 'TRANS MART', 'CARREFOUR'],
        addressPatterns: ['JL.', 'JALAN', 'MALL'],
        headerPatterns: ['DEPARTMENT STORE', 'SUPERMARKET'],
        defaultCategoryName: 'Belanja Harian',
        aliases: [],
        priority: 95,
      ),

      // ==================== COFFEE SHOPS & CAFES ====================
      MerchantPatternEntity(
        id: 'starbucks',
        merchantName: 'Starbucks',
        namePatterns: ['STARBUCKS', 'SBUX'],
        addressPatterns: ['JL.', 'JALAN', 'MALL'],
        headerPatterns: ['COFFEE', 'CAFE'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 100,
      ),

      MerchantPatternEntity(
        id: 'excelso',
        merchantName: 'Excelso',
        namePatterns: ['EXCELSO', 'EXCELCO'],
        addressPatterns: ['JL.', 'JALAN', 'MALL'],
        headerPatterns: ['COFFEE', 'CAFE'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 90,
      ),

      MerchantPatternEntity(
        id: 'coffee_bean',
        merchantName: 'The Coffee Bean',
        namePatterns: ['COFFEE BEAN', 'TEA LEAF'],
        addressPatterns: ['JL.', 'JALAN', 'MALL'],
        headerPatterns: ['COFFEE', 'CAFE'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 90,
      ),

      MerchantPatternEntity(
        id: 'jco',
        merchantName: 'J.Co',
        namePatterns: ['J.CO', 'JCO', 'JCO DONUTS'],
        addressPatterns: ['JL.', 'JALAN', 'MALL'],
        headerPatterns: ['DONUT', 'COFFEE'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 90,
      ),

      MerchantPatternEntity(
        id: 'dunkin',
        merchantName: 'Dunkin\' Donuts',
        namePatterns: ['DUNKIN', 'DUNKIN DONUTS'],
        addressPatterns: ['JL.', 'JALAN', 'MALL'],
        headerPatterns: ['DONUT'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 90,
      ),

      MerchantPatternEntity(
        id: 'kopi_kenangan',
        merchantName: 'Kopi Kenangan',
        namePatterns: ['KOPI KENANGAN', 'KENANGAN'],
        addressPatterns: ['JL.', 'JALAN'],
        headerPatterns: ['KOPI', 'COFFEE'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 85,
      ),

      MerchantPatternEntity(
        id: 'janji_jiwa',
        merchantName: 'Janji Jiwa',
        namePatterns: ['JANJI JIWA', 'JIWA', 'JIWA+JIWA'],
        addressPatterns: ['JL.', 'JALAN'],
        headerPatterns: ['KOPI', 'COFFEE'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 85,
      ),

      // ==================== FAST FOOD ====================
      MerchantPatternEntity(
        id: 'kfc',
        merchantName: 'KFC',
        namePatterns: ['KFC', 'KENTUCKY', 'FRIED CHICKEN'],
        addressPatterns: ['JL.', 'JALAN', 'MALL'],
        headerPatterns: ['RESTAURANT', 'FAST FOOD'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 100,
      ),

      MerchantPatternEntity(
        id: 'mcdonalds',
        merchantName: 'McDonald\'s',
        namePatterns: ['MCDONALD', 'MCD', 'MCDONALDS', 'MC DONALD'],
        addressPatterns: ['JL.', 'JALAN', 'MALL'],
        headerPatterns: ['RESTAURANT', 'FAST FOOD', 'BURGER'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 100,
      ),

      MerchantPatternEntity(
        id: 'burger_king',
        merchantName: 'Burger King',
        namePatterns: ['BURGER KING', 'BK', 'WHOPPER'],
        addressPatterns: ['JL.', 'JALAN', 'MALL'],
        headerPatterns: ['RESTAURANT', 'FAST FOOD', 'BURGER'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 95,
      ),

      MerchantPatternEntity(
        id: 'pizza_hut',
        merchantName: 'Pizza Hut',
        namePatterns: ['PIZZA HUT', 'PHD', 'PIZZAHUT'],
        addressPatterns: ['JL.', 'JALAN'],
        headerPatterns: ['RESTAURANT', 'PIZZA', 'DELIVERY'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 95,
      ),

      MerchantPatternEntity(
        id: 'dominos',
        merchantName: 'Domino\'s Pizza',
        namePatterns: ['DOM PIZZA', 'DOMINOS', 'DOMINO'],
        addressPatterns: ['JL.', 'JALAN'],
        headerPatterns: ['RESTAURANT', 'PIZZA', 'DELIVERY'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 90,
      ),

      MerchantPatternEntity(
        id: 'hokben',
        merchantName: 'Hoka Hoka Bento',
        namePatterns: ['HOKBEN', 'HOKA HOKA BENTO'],
        addressPatterns: ['JL.', 'JALAN', 'MALL'],
        headerPatterns: ['RESTAURANT', 'JAPANESE'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 90,
      ),

      MerchantPatternEntity(
        id: 'a&w',
        merchantName: 'A&W',
        namePatterns: ['A&W', 'A AND W', 'ROOT BEER'],
        addressPatterns: ['JL.', 'JALAN', 'MALL'],
        headerPatterns: ['RESTAURANT', 'FAST FOOD'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 85,
      ),

      MerchantPatternEntity(
        id: 'texas_chicken',
        merchantName: 'Texas Chicken',
        namePatterns: ['TEXAS', 'TEXAS CHICKEN'],
        addressPatterns: ['JL.', 'JALAN', 'MALL'],
        headerPatterns: ['RESTAURANT', 'FAST FOOD'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 85,
      ),

      MerchantPatternEntity(
        id: 'yoshinoya',
        merchantName: 'Yoshinoya',
        namePatterns: ['YOSHINOYA', 'GYUDON'],
        addressPatterns: ['JL.', 'JALAN', 'MALL'],
        headerPatterns: ['RESTAURANT', 'JAPANESE'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 85,
      ),

      MerchantPatternEntity(
        id: 'pepper_lunch',
        merchantName: 'Pepper Lunch',
        namePatterns: ['PEPPER LUNCH', 'PEPPERLUNCH'],
        addressPatterns: ['JL.', 'JALAN', 'MALL'],
        headerPatterns: ['RESTAURANT', 'STEAK'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 85,
      ),

      MerchantPatternEntity(
        id: 'sushi_tei',
        merchantName: 'Sushi Tei',
        namePatterns: ['SUSHI TEI', 'SUSHITEI'],
        addressPatterns: ['JL.', 'JALAN', 'MALL'],
        headerPatterns: ['RESTAURANT', 'JAPANESE', 'SUSHI'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 85,
      ),

      // ==================== FOOD DELIVERY ====================
      MerchantPatternEntity(
        id: 'gofood',
        merchantName: 'GoFood',
        namePatterns: ['GOFOOD', 'GO FOOD', 'GO-FOOD'],
        addressPatterns: [],
        headerPatterns: ['DELIVERY', 'FOOD DELIVERY'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 100,
      ),

      MerchantPatternEntity(
        id: 'grabfood',
        merchantName: 'GrabFood',
        namePatterns: ['GRABFOOD', 'GRAB FOOD', 'GRAB-FOOD'],
        addressPatterns: [],
        headerPatterns: ['DELIVERY', 'FOOD DELIVERY'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 100,
      ),

      MerchantPatternEntity(
        id: 'shopee_food',
        merchantName: 'ShopeeFood',
        namePatterns: ['SHOPEEFOOD', 'SHOPEE FOOD', 'SHOPEE-FOOD'],
        addressPatterns: [],
        headerPatterns: ['DELIVERY', 'FOOD DELIVERY'],
        defaultCategoryName: 'Makanan & Minuman',
        aliases: [],
        priority: 100,
      ),

      // ==================== E-COMMERCE ====================
      MerchantPatternEntity(
        id: 'tokopedia',
        merchantName: 'Tokopedia',
        namePatterns: ['TOKOPEDIA', 'TOKPED'],
        addressPatterns: [],
        headerPatterns: ['E-COMMERCE', 'MARKETPLACE'],
        defaultCategoryName: 'Belanja',
        aliases: [],
        priority: 100,
      ),

      MerchantPatternEntity(
        id: 'shopee',
        merchantName: 'Shopee',
        namePatterns: ['SHOPEE', 'SHOPEE MALL', 'SHOPEE EXPRESS'],
        addressPatterns: [],
        headerPatterns: ['E-COMMERCE', 'MARKETPLACE'],
        defaultCategoryName: 'Belanja',
        aliases: [],
        priority: 100,
      ),

      MerchantPatternEntity(
        id: 'lazada',
        merchantName: 'Lazada',
        namePatterns: ['LAZADA', 'LAZMALL'],
        addressPatterns: [],
        headerPatterns: ['E-COMMERCE', 'MARKETPLACE'],
        defaultCategoryName: 'Belanja',
        aliases: [],
        priority: 95,
      ),

      MerchantPatternEntity(
        id: 'blibli',
        merchantName: 'Blibli',
        namePatterns: ['BLIBLI', 'BLIBLI.COM'],
        addressPatterns: [],
        headerPatterns: ['E-COMMERCE', 'MARKETPLACE'],
        defaultCategoryName: 'Belanja',
        aliases: [],
        priority: 95,
      ),

      MerchantPatternEntity(
        id: 'bukalapak',
        merchantName: 'Bukalapak',
        namePatterns: ['BUKALAPAK', 'BUKALAPAK.COM'],
        addressPatterns: [],
        headerPatterns: ['E-COMMERCE', 'MARKETPLACE'],
        defaultCategoryName: 'Belanja',
        aliases: [],
        priority: 90,
      ),

      MerchantPatternEntity(
        id: 'jd_id',
        merchantName: 'JD.ID',
        namePatterns: ['JD.ID', 'JD ID', 'JDI D'],
        addressPatterns: [],
        headerPatterns: ['E-COMMERCE', 'MARKETPLACE'],
        defaultCategoryName: 'Belanja',
        aliases: [],
        priority: 90,
      ),

      MerchantPatternEntity(
        id: 'tiktok_shop',
        merchantName: 'TikTok Shop',
        namePatterns: ['TIKTOK SHOP', 'TIKTOKSHOP', 'TIKTOK'],
        addressPatterns: [],
        headerPatterns: ['E-COMMERCE', 'MARKETPLACE'],
        defaultCategoryName: 'Belanja',
        aliases: [],
        priority: 95,
      ),

      // ==================== TRANSPORTATION ====================
      MerchantPatternEntity(
        id: 'traveloka',
        merchantName: 'Traveloka',
        namePatterns: ['TRAVELOKA', 'TRAVELOKA.COM'],
        addressPatterns: [],
        headerPatterns: ['TRAVEL', 'BOOKING'],
        defaultCategoryName: 'Transportasi',
        aliases: [],
        priority: 100,
      ),

      MerchantPatternEntity(
        id: 'gojek',
        merchantName: 'Gojek',
        namePatterns: ['GOJEK', 'GO JEK', 'GO-RIDE', 'GO RIDE', 'GO-CAR', 'GO CAR'],
        addressPatterns: [],
        headerPatterns: ['RIDE', 'TRANSPORTATION'],
        defaultCategoryName: 'Transportasi',
        aliases: [],
        priority: 100,
      ),

      MerchantPatternEntity(
        id: 'grab',
        merchantName: 'Grab',
        namePatterns: ['GRAB', 'GRABCAR', 'GRAB CAR', 'GRABBIKE', 'GRAB BIKE'],
        addressPatterns: [],
        headerPatterns: ['RIDE', 'TRANSPORTATION'],
        defaultCategoryName: 'Transportasi',
        aliases: [],
        priority: 100,
      ),

      MerchantPatternEntity(
        id: 'blue_bird',
        merchantName: 'Blue Bird',
        namePatterns: ['BLUE BIRD', 'BLUEBIRD', 'TAKSI'],
        addressPatterns: [],
        headerPatterns: ['TAXI', 'TRANSPORTATION'],
        defaultCategoryName: 'Transportasi',
        aliases: [],
        priority: 95,
      ),

      MerchantPatternEntity(
        id: 'maxim',
        merchantName: 'Maxim',
        namePatterns: ['MAXIM'],
        addressPatterns: [],
        headerPatterns: ['RIDE', 'TRANSPORTATION'],
        defaultCategoryName: 'Transportasi',
        aliases: [],
        priority: 85,
      ),

      MerchantPatternEntity(
        id: 'in_drive',
        merchantName: 'inDrive',
        namePatterns: ['INDRIVE', 'IN-DRIVE', 'IN DRIVE'],
        addressPatterns: [],
        headerPatterns: ['RIDE', 'TRANSPORTATION'],
        defaultCategoryName: 'Transportasi',
        aliases: [],
        priority: 85,
      ),

      // ==================== UTILITIES / BILLS ====================
      MerchantPatternEntity(
        id: 'pln',
        merchantName: 'PLN',
        namePatterns: ['PLN', 'PERUSAHAAN LISTRIK NEGARA', 'LISTRIK'],
        addressPatterns: [],
        headerPatterns: ['TOKEN', 'PULSA', 'TAGIHAN'],
        defaultCategoryName: 'Tagihan & Utilitas',
        aliases: [],
        priority: 100,
      ),

      MerchantPatternEntity(
        id: 'pdam',
        merchantName: 'PDAM',
        namePatterns: ['PDAM', 'AIR MINUM'],
        addressPatterns: [],
        headerPatterns: ['TAGIHAN', 'AIR'],
        defaultCategoryName: 'Tagihan & Utilitas',
        aliases: [],
        priority: 95,
      ),

      MerchantPatternEntity(
        id: 'telkom',
        merchantName: 'Telkom',
        namePatterns: ['TELKOM', 'SPEEDY', 'INDIHOME', 'TELKOM INDONESIA'],
        addressPatterns: [],
        headerPatterns: ['INTERNET', 'TELEPHONE', 'TAGIHAN'],
        defaultCategoryName: 'Tagihan & Utilitas',
        aliases: [],
        priority: 95,
      ),

      MerchantPatternEntity(
        id: 'xl',
        merchantName: 'XL',
        namePatterns: ['XL', 'XL AXIATA', 'XLA'],
        addressPatterns: [],
        headerPatterns: ['PULSA', 'DATA', 'TAGIHAN'],
        defaultCategoryName: 'Tagihan & Utilitas',
        aliases: [],
        priority: 90,
      ),

      MerchantPatternEntity(
        id: 'telkomsel',
        merchantName: 'Telkomsel',
        namePatterns: ['TELKOMSEL', 'SIMPATI', 'AS', 'LOOP'],
        addressPatterns: [],
        headerPatterns: ['PULSA', 'DATA', 'TAGIHAN'],
        defaultCategoryName: 'Tagihan & Utilitas',
        aliases: [],
        priority: 90,
      ),

      MerchantPatternEntity(
        id: 'indosat',
        merchantName: 'Indosat',
        namePatterns: ['INDOSAT', 'IM3', 'MENTARI', 'MATRIX'],
        addressPatterns: [],
        headerPatterns: ['PULSA', 'DATA', 'TAGIHAN'],
        defaultCategoryName: 'Tagihan & Utilitas',
        aliases: [],
        priority: 90,
      ),

      MerchantPatternEntity(
        id: 'tri',
        merchantName: 'Tri',
        namePatterns: ['TRI', '3', 'THREE', '3care'],
        addressPatterns: [],
        headerPatterns: ['PULSA', 'DATA', 'TAGIHAN'],
        defaultCategoryName: 'Tagihan & Utilitas',
        aliases: [],
        priority: 85,
      ),

      MerchantPatternEntity(
        id: 'smartfren',
        merchantName: 'Smartfren',
        namePatterns: ['SMARTFREN', 'SMART'],
        addressPatterns: [],
        headerPatterns: ['PULSA', 'DATA', 'TAGIHAN'],
        defaultCategoryName: 'Tagihan & Utilitas',
        aliases: [],
        priority: 85,
      ),

      MerchantPatternEntity(
        id: 'netflix',
        merchantName: 'Netflix',
        namePatterns: ['NETFLIX'],
        addressPatterns: [],
        headerPatterns: ['SUBSCRIPTION', 'STREAMING'],
        defaultCategoryName: 'Hiburan',
        aliases: [],
        priority: 90,
      ),

      MerchantPatternEntity(
        id: 'spotify',
        merchantName: 'Spotify',
        namePatterns: ['SPOTIFY'],
        addressPatterns: [],
        headerPatterns: ['SUBSCRIPTION', 'MUSIC'],
        defaultCategoryName: 'Hiburan',
        aliases: [],
        priority: 90,
      ),

      // ==================== GAS STATIONS ====================
      MerchantPatternEntity(
        id: 'pertamina',
        merchantName: 'Pertamina',
        namePatterns: ['PERTAMINA', 'BBM', 'SPBU'],
        addressPatterns: ['KM', 'JL.', 'JALAN'],
        headerPatterns: ['POM BENSIN', 'SPBU'],
        defaultCategoryName: 'Transportasi',
        aliases: [],
        priority: 95,
      ),

      MerchantPatternEntity(
        id: 'shell',
        merchantName: 'Shell',
        namePatterns: ['SHELL', 'SHELL INDONESIA'],
        addressPatterns: ['KM', 'JL.', 'JALAN'],
        headerPatterns: ['SPBU', 'GAS STATION'],
        defaultCategoryName: 'Transportasi',
        aliases: [],
        priority: 90,
      ),

      // ==================== PHARMACIES ====================
      MerchantPatternEntity(
        id: 'kimia_farma',
        merchantName: 'Kimia Farma',
        namePatterns: ['KIMIA FARMA', 'KIMIAFARMA', 'KF'],
        addressPatterns: ['JL.', 'JALAN', 'APOTEK'],
        headerPatterns: ['APOTEK', 'PHARMACY', 'OBAT'],
        defaultCategoryName: 'Kesehatan',
        aliases: [],
        priority: 95,
      ),

      MerchantPatternEntity(
        id: 'k24',
        merchantName: 'K-24',
        namePatterns: ['K-24', 'K24', 'K24 MEDIA'],
        addressPatterns: ['JL.', 'JALAN', 'APOTEK'],
        headerPatterns: ['APOTEK', 'PHARMACY', 'OBAT'],
        defaultCategoryName: 'Kesehatan',
        aliases: [],
        priority: 90,
      ),

      MerchantPatternEntity(
        id: 'century',
        merchantName: 'Century Healthcare',
        namePatterns: ['CENTURY', 'CENTURY HEALTHCARE'],
        addressPatterns: ['JL.', 'JALAN', 'MALL'],
        headerPatterns: ['APOTEK', 'PHARMACY', 'HEALTHCARE'],
        defaultCategoryName: 'Kesehatan',
        aliases: [],
        priority: 90,
      ),

      // ==================== CONVENIENCE STORES ====================
      MerchantPatternEntity(
        id: 'familymart',
        merchantName: 'FamilyMart',
        namePatterns: ['FAMILYMART', 'FAMILY MART'],
        addressPatterns: ['JL.', 'JALAN'],
        headerPatterns: ['CONVENIENCE STORE'],
        defaultCategoryName: 'Belanja Harian',
        aliases: [],
        priority: 85,
      ),

      MerchantPatternEntity(
        id: 'fm',
        merchantName: 'FM',
        namePatterns: ['FAMILY MART', 'FAMILYMART', 'F M'],
        addressPatterns: ['JL.', 'JALAN'],
        headerPatterns: ['CONVENIENCE STORE'],
        defaultCategoryName: 'Belanja Harian',
        aliases: [],
        priority: 80,
      ),
    ];
  }
}
