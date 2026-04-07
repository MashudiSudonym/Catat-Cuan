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
    // If user deletes all text, let it be empty
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Remove non-digit characters (including "Rp " prefix that may be present)
    var rawValue = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // If empty after filter, return empty
    if (rawValue.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Parse to integer
    var value = int.tryParse(rawValue) ?? 0;

    // Format numbers only with thousand separator (WITHOUT prefix)
    // Prefix will be added by TextField's prefixText
    var formattedValue = _formatNumberWithSeparator(value);

    // Return with proper cursor position
    var selectionEnd = formattedValue.length;
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: selectionEnd),
    );
  }

  /// Format integer with thousand separator (WITHOUT prefix)
  /// Example: 1000000 -> "1.000.000"
  static String _formatNumberWithSeparator(int value) {
    if (value == 0) return '0';

    // Format with thousand separator
    var buffer = StringBuffer();
    var valueStr = value.toString();

    // Add thousand separator from right
    for (var i = 0; i < valueStr.length; i++) {
      var pos = valueStr.length - i;
      if (i > 0 && pos % 3 == 0) {
        buffer.write(_thousandSeparator);
      }
      buffer.write(valueStr[i]);
    }

    return buffer.toString();
  }

  /// Format integer to Rupiah format WITHOUT prefix
  /// Prefix will be handled by TextField's prefixText
  /// Example: 1000000 -> "1.000.000"
  static String formatRupiah(int value) {
    if (value == 0) return '0';
    return _formatNumberWithSeparator(value);
  }

  /// Format double to Rupiah format WITHOUT prefix
  /// Prefix will be handled by TextField's prefixText
  /// Example: 1000000.50 -> "1.000.000"
  /// Note: For this version, we round to integer
  static String formatRupiahFromDouble(double value) {
    return formatRupiah(value.round());
  }

  /// Parse formatted string back to integer
  /// Example: "1.000.000" -> 1000000
  static int? parseRupiah(String formatted) {
    // Remove non-digit characters (thousand separator)
    var rawValue = formatted.replaceAll(RegExp(r'[^\d]'), '');
    if (rawValue.isEmpty) return null;
    return int.tryParse(rawValue);
  }

  /// Parse formatted string back to double
  static double? parseRupiahToDouble(String formatted) {
    var parsed = parseRupiah(formatted);
    return parsed?.toDouble();
  }

  /// Helper to display currency format in text widget
  static Widget buildCurrencyText(double amount, {
    TextStyle? style,
    int? maxDecimals,
  }) {
    return Text(
      formatRupiahFromDouble(amount),
      style: style,
    );
  }

  /// Get formatted string with or without prefix
  static String formatAmount(double amount, {bool withPrefix = true}) {
    var formatted = formatRupiahFromDouble(amount);
    return withPrefix ? '$_defaultPrefix$formatted' : formatted;
  }

  /// Validate if input string is valid for currency
  static bool isValidCurrencyInput(String input) {
    if (input.isEmpty) return false;
    var rawValue = input.replaceAll(RegExp(r'[^\d]'), '');
    return rawValue.isNotEmpty;
  }
}

/// Extension for easier formatting
extension CurrencyFormatterExtension on double {
  /// Format double to Rupiah string
  String toRupiah() {
    return CurrencyInputFormatter.formatRupiahFromDouble(this);
  }

  /// Format double to Rupiah string without prefix
  String toRupiahWithoutPrefix() {
    return CurrencyInputFormatter.formatAmount(this, withPrefix: false);
  }
}

extension CurrencyFormatterExtensionInt on int {
  /// Format int to Rupiah string
  String toRupiah() {
    return CurrencyInputFormatter.formatRupiah(this);
  }

  /// Format int to Rupiah string without prefix
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
