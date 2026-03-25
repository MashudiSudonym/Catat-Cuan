import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catat_cuan/presentation/providers/app_providers.dart';

/// Currency input formatter for dynamic currency
/// Format depends on selected currency: IDR (Rp 1.000.000) or USD (US$ 1,000,000)
class CurrencyInputFormatter extends TextInputFormatter {
  static const String _defaultPrefix = 'Rp ';
  static const String _thousandSeparator = '.';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Jika user menghapus semua text, biarkan kosong
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Hapus karakter non-digit (termasuk prefix "Rp " yang mungkin ada)
    var rawValue = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Jika kosong setelah filter, return empty
    if (rawValue.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Parse ke integer
    var value = int.tryParse(rawValue) ?? 0;

    // Format hanya angka dengan pemisah ribuan (TANPA prefix)
    // Prefix akan ditambahkan oleh TextField's prefixText
    var formattedValue = _formatNumberWithSeparator(value);

    // Kembalikan dengan proper cursor position
    var selectionEnd = formattedValue.length;
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: selectionEnd),
    );
  }

  /// Format integer dengan pemisah ribuan (TANPA prefix)
  /// Contoh: 1000000 -> "1.000.000"
  static String _formatNumberWithSeparator(int value) {
    if (value == 0) return '0';

    // Format dengan pemisah ribuan
    var buffer = StringBuffer();
    var valueStr = value.toString();

    // Tambahkan pemisah ribuan dari kanan
    for (var i = 0; i < valueStr.length; i++) {
      var pos = valueStr.length - i;
      if (i > 0 && pos % 3 == 0) {
        buffer.write(_thousandSeparator);
      }
      buffer.write(valueStr[i]);
    }

    return buffer.toString();
  }

  /// Format integer ke format Rupiah TANPA prefix
  /// Prefix akan ditangani oleh TextField's prefixText
  /// Contoh: 1000000 -> "1.000.000"
  static String formatRupiah(int value) {
    if (value == 0) return '0';
    return _formatNumberWithSeparator(value);
  }

  /// Format double ke format Rupiah TANPA prefix
  /// Prefix akan ditangani oleh TextField's prefixText
  /// Contoh: 1000000.50 -> "1.000.000"
  /// Note: Untuk versi ini, kita bulatkan ke integer
  static String formatRupiahFromDouble(double value) {
    return formatRupiah(value.round());
  }

  /// Parse formatted string kembali ke integer
  /// Contoh: "1.000.000" -> 1000000
  static int? parseRupiah(String formatted) {
    // Hapus karakter non-digit (pemisah ribuan)
    var rawValue = formatted.replaceAll(RegExp(r'[^\d]'), '');
    if (rawValue.isEmpty) return null;
    return int.tryParse(rawValue);
  }

  /// Parse formatted string kembali ke double
  static double? parseRupiahToDouble(String formatted) {
    var parsed = parseRupiah(formatted);
    return parsed?.toDouble();
  }

  /// Helper untuk menampilkan format currency dalam text widget
  static Widget buildCurrencyText(double amount, {
    TextStyle? style,
    int? maxDecimals,
  }) {
    return Text(
      formatRupiahFromDouble(amount),
      style: style,
    );
  }

  /// Get formatted string dengan atau tanpa prefix
  static String formatAmount(double amount, {bool withPrefix = true}) {
    var formatted = formatRupiahFromDouble(amount);
    return withPrefix ? '$_defaultPrefix$formatted' : formatted;
  }

  /// Validate apakah string input valid untuk currency
  static bool isValidCurrencyInput(String input) {
    if (input.isEmpty) return false;
    var rawValue = input.replaceAll(RegExp(r'[^\d]'), '');
    return rawValue.isNotEmpty;
  }
}

/// Extension untuk memudahkan formatting
extension CurrencyFormatterExtension on double {
  /// Format double ke string Rupiah
  String toRupiah() {
    return CurrencyInputFormatter.formatRupiahFromDouble(this);
  }

  /// Format double ke string Rupiah tanpa prefix
  String toRupiahWithoutPrefix() {
    return CurrencyInputFormatter.formatAmount(this, withPrefix: false);
  }
}

extension CurrencyFormatterExtensionInt on int {
  /// Format int ke string Rupiah
  String toRupiah() {
    return CurrencyInputFormatter.formatRupiah(this);
  }

  /// Format int ke string Rupiah tanpa prefix
  String toRupiahWithoutPrefix() {
    var formatted = CurrencyInputFormatter.formatRupiah(this);
    return formatted.substring(3);
  }
}

/// Provider-aware currency formatting extension for double
extension CurrencyFormatterExtensionWithRef on double {
  /// Format double to currency string based on current currency setting
  /// Example: 1000000 -> "Rp 1.000.000" (IDR) or "US$ 1,000,000" (USD)
  String toCurrency({required WidgetRef ref, bool withPrefix = true}) {
    final currencyOption = ref.read(currencyProvider).currencyOption;
    final parts = toStringAsFixed(0).split('.');
    final integerPart = _formatWithSeparator(int.parse(parts[0]), currencyOption.thousandSeparator);
    return withPrefix ? '${currencyOption.symbol}$integerPart' : integerPart;
  }

  String _formatWithSeparator(int value, String separator) {
    if (value == 0) return '0';

    final buffer = StringBuffer();
    final valueStr = value.toString();

    // Add thousand separator from right
    for (var i = 0; i < valueStr.length; i++) {
      final pos = valueStr.length - i;
      if (i > 0 && pos % 3 == 0) {
        buffer.write(separator);
      }
      buffer.write(valueStr[i]);
    }

    return buffer.toString();
  }

  /// Deprecated: Use toCurrency(ref: ref) instead
  @Deprecated('Use toCurrency(ref: ref) instead')
  String toRupiah() {
    return CurrencyInputFormatter.formatRupiahFromDouble(this);
  }

  /// Deprecated: Use toCurrency(ref: ref, withPrefix: false) instead
  @Deprecated('Use toCurrency(ref: ref, withPrefix: false) instead')
  String toRupiahWithoutPrefix() {
    return CurrencyInputFormatter.formatAmount(this, withPrefix: false);
  }
}

/// Provider-aware currency formatting extension for int
extension CurrencyFormatterExtensionIntWithRef on int {
  /// Format int to currency string based on current currency setting
  /// Example: 1000000 -> "Rp 1.000.000" (IDR) or "US$ 1,000,000" (USD)
  String toCurrency({required WidgetRef ref, bool withPrefix = true}) {
    final currencyOption = ref.read(currencyProvider).currencyOption;
    final integerPart = _formatWithSeparator(this, currencyOption.thousandSeparator);
    return withPrefix ? '${currencyOption.symbol}$integerPart' : integerPart;
  }

  String _formatWithSeparator(int value, String separator) {
    if (value == 0) return '0';

    final buffer = StringBuffer();
    final valueStr = value.toString();

    // Add thousand separator from right
    for (var i = 0; i < valueStr.length; i++) {
      final pos = valueStr.length - i;
      if (i > 0 && pos % 3 == 0) {
        buffer.write(separator);
      }
      buffer.write(valueStr[i]);
    }

    return buffer.toString();
  }

  /// Deprecated: Use toCurrency(ref: ref) instead
  @Deprecated('Use toCurrency(ref: ref) instead')
  String toRupiah() {
    return CurrencyInputFormatter.formatRupiah(this);
  }

  /// Deprecated: Use toCurrency(ref: ref, withPrefix: false) instead
  @Deprecated('Use toCurrency(ref: ref, withPrefix: false) instead')
  String toRupiahWithoutPrefix() {
    final formatted = CurrencyInputFormatter.formatRupiah(this);
    return formatted.substring(3);
  }
}
