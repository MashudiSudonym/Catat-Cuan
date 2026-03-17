/// Constants untuk kategori
class CategoryConstants {
  // Validation constants
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Default icons by type
  static const Map<String, List<String>> iconsByType = {
    'income': [
      '💰', // Gaji/Salary
      '🎁', // Bonus/Gift
      '💼', // Freelance/Work
      '🎀', // Hadiah/Prize
      '📈', // Investasi/Investment
      '💵', // Tunai/Cash
      '🏦', // Bank/Transfer
      '💳', // Kartu Kredit/Credit Card
      '🪙', // Bunga/Interest
      '📦', // Lainnya/Other
    ],
    'expense': [
      '🍔', // Makan/Food
      '🚗', // Transport/Transportation
      '🔄', // Langganan/Subscription
      '🛍️', // Belanja/Shopping
      '🎬', // Hiburan/Entertainment
      '💊', // Kesehatan/Health
      '📚', // Pendidikan/Education
      '📄', // Tagihan/Bills
      '⚡', // Utilitas/Utilities
      '🏠', // Rumah/Home
      '📦', // Lainnya/Other
    ],
  };

  // Default colors for categories (hex format)
  static const List<String> defaultColors = [
    '#4CAF50', // Green
    '#8BC34A', // Light Green
    '#CDDC39', // Lime
    '#FFEB3B', // Yellow
    '#FFC107', // Amber
    '#FF9800', // Orange
    '#FF5722', // Deep Orange
    '#F44336', // Red
    '#E91E63', // Pink
    '#9C27B0', // Purple
    '#673AB7', // Deep Purple
    '#3F51B5', // Indigo
    '#2196F3', // Blue
    '#03A9F4', // Light Blue
    '#00BCD4', // Cyan
    '#009688', // Teal
    '#607D8B', // Blue Gray
    '#795548', // Brown
    '#9E9E9E', // Gray
  ];

  /// Get default icons for income
  static List<String> get incomeIcons => iconsByType['income']!;

  /// Get default icons for expense
  static List<String> get expenseIcons => iconsByType['expense']!;

  /// Get all default icons
  static List<String> getAllIcons() {
    return [...incomeIcons, ...expenseIcons];
  }

  /// Get default color by index
  static String getDefaultColor(int index) {
    return defaultColors[index % defaultColors.length];
  }

  /// Get random default color
  static String getRandomColor() {
    final now = DateTime.now();
    return defaultColors[now.millisecond % defaultColors.length];
  }

  /// Get default icon by type
  static String getDefaultIcon(String type) {
    final icons = iconsByType[type] ?? ['📦'];
    final now = DateTime.now();
    return icons[now.millisecond % icons.length];
  }

  /// Auto-detect icon based on category name
  /// Returns appropriate icon based on keywords in the name
  static String detectIconFromName(String name, String type) {
    final lowerName = name.toLowerCase();

    // Income keywords mapping
    if (type == 'income') {
      final incomeKeywords = {
        'gaji': '💰',
        'salary': '💰',
        'upah': '💼',
        'bonus': '🎁',
        'hadiah': '🎀',
        'prize': '🎀',
        'investasi': '📈',
        'investment': '📈',
        'saham': '📈',
        'tunai': '💵',
        'cash': '💵',
        'uang': '💵',
        'bank': '🏦',
        'transfer': '🏦',
        'tf': '🏦',
        'kartu': '💳',
        'kredit': '💳',
        'bunga': '🪙',
        'interest': '🪙',
      };

      for (final entry in incomeKeywords.entries) {
        if (lowerName.contains(entry.key)) {
          return entry.value;
        }
      }
    }

    // Expense keywords mapping
    if (type == 'expense') {
      final expenseKeywords = {
        'makan': '🍔',
        'food': '🍔',
        'minum': '🍔',
        'jajan': '🍔',
        'resto': '🍔',
        'warung': '🍔',
        'transport': '🚗',
        'bensin': '🚗',
        'bbm': '🚗',
        'motor': '🚗',
        'mobil': '🚗',
        'ojek': '🚗',
        'grab': '🚗',
        'gojek': '🚗',
        'langganan': '🔄',
        'subscription': '🔄',
        'netflix': '🔄',
        'spotify': '🔄',
        'youtube': '🔄',
        'belanja': '🛍️',
        'shopping': '🛍️',
        'tokped': '🛍️',
        'shopee': '🛍️',
        'hiburan': '🎬',
        'film': '🎬',
        'bioskop': '🎬',
        'game': '🎬',
        'kesehatan': '💊',
        'obat': '💊',
        'dokter': '💊',
        'rs': '💊',
        'rumah sakit': '💊',
        'pendidikan': '📚',
        'sekolah': '📚',
        'kuliah': '📚',
        'buku': '📚',
        'kursus': '📚',
        'tagihan': '📄',
        'bill': '📄',
        'listrik': '⚡',
        'air': '⚡',
        'pulsa': '⚡',
        'internet': '⚡',
        'wifi': '⚡',
        'utilitas': '⚡',
        'rumah': '🏠',
        'home': '🏠',
        'kos': '🏠',
        'kontrakan': '🏠',
      };

      for (final entry in expenseKeywords.entries) {
        if (lowerName.contains(entry.key)) {
          return entry.value;
        }
      }
    }

    // Return random icon from type if no match
    return getDefaultIcon(type);
  }

  /// Auto-detect color based on category name
  /// Returns consistent color based on name hash
  static String detectColorFromName(String name) {
    final lowerName = name.toLowerCase();
    final hash = lowerName.codeUnits.fold<int>(
      0,
      (sum, unit) => sum + unit,
    );

    // Different color ranges for different starting letters
    final firstChar = lowerName.isNotEmpty ? lowerName[0] : 'a';

    // Map first character to color range
    late int startIndex;
    if (RegExp(r'[a-d]').hasMatch(firstChar)) {
      startIndex = 0; // Greens
    } else if (RegExp(r'[e-h]').hasMatch(firstChar)) {
      startIndex = 3; // Yellows/Oranges
    } else if (RegExp(r'[i-l]').hasMatch(firstChar)) {
      startIndex = 6; // Reds/Pinks
    } else if (RegExp(r'[m-p]').hasMatch(firstChar)) {
      startIndex = 9; // Purples
    } else if (RegExp(r'[q-t]').hasMatch(firstChar)) {
      startIndex = 12; // Blues
    } else {
      startIndex = 15; // Teals/Grays
    }

    final offset = hash % 4; // Variate within range
    final colorIndex = (startIndex + offset) % defaultColors.length;

    return defaultColors[colorIndex];
  }

  /// Validate category name
  static String? validateName(String name) {
    if (name.trim().isEmpty) {
      return 'Nama kategori tidak boleh kosong';
    }
    if (name.trim().length < minNameLength) {
      return 'Nama kategori minimal $minNameLength karakter';
    }
    if (name.trim().length > maxNameLength) {
      return 'Nama kategori maksimal $maxNameLength karakter';
    }
    return null;
  }
}
