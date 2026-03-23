import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base/base.dart';
import '../providers/app_providers.dart';
import '../utils/utils.dart';

/// Custom input field untuk nominal dengan format currency Indonesia
/// Menampilkan input besar di tengah dengan prefix "Rp"
class CurrencyInputField extends ConsumerStatefulWidget {
  final double? initialValue;
  final Function(double)? onChanged;
  final String? errorText;
  final bool enabled;
  final String? labelText;

  const CurrencyInputField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.errorText,
    this.enabled = true,
    this.labelText,
  });

  @override
  ConsumerState<CurrencyInputField> createState() => _CurrencyInputFieldState();
}

class _CurrencyInputFieldState extends ConsumerState<CurrencyInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  double? _currentValue;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _currentValue = widget.initialValue;

    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!.toCurrency(ref: ref, withPrefix: false);
    }

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Select all text when focused
        _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
      }
    });
  }

  @override
  void didUpdateWidget(CurrencyInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue && widget.initialValue != _currentValue) {
      _currentValue = widget.initialValue;
      _controller.text = (widget.initialValue ?? 0).toCurrency(ref: ref, withPrefix: false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final parsed = CurrencyInputFormatter.parseRupiahToDouble(value);
    // Jika kosong, kirim 0 agar parent tahu field di-clear
    final valueToSend = parsed ?? 0.0;
    _currentValue = valueToSend;
    widget.onChanged?.call(valueToSend);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final currencySymbol = ref.watch(currencyNotifierProvider).currencyOption.symbol;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const AppSpacingWidget.verticalSM(),
        ],
        AppGlassContainer.glassCard(
          padding: AppSpacing.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xl),
          borderRadius: AppRadius.lgAll,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              _DynamicCurrencyFormatter(ref: ref),
            ],
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            decoration: InputDecoration(
              prefixText: currencySymbol,
              prefixStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                textBaseline: TextBaseline.alphabetic,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: '0',
              hintStyle: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade300,
                textBaseline: TextBaseline.alphabetic,
              ),
            ),
            onChanged: widget.enabled ? _onChanged : null,
          ),
        ),
        if (hasError) ...[
          const AppSpacingWidget.verticalSM(),
          Padding(
            padding: AppSpacing.only(left: AppSpacing.lg),
            child: Text(
              widget.errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact version untuk digunakan dalam form biasa
class CompactCurrencyInputField extends ConsumerStatefulWidget {
  final double? value;
  final Function(double)? onChanged;
  final String? errorText;
  final String? labelText;
  final String? hintText;
  final bool enabled;

  const CompactCurrencyInputField({
    super.key,
    this.value,
    this.onChanged,
    this.errorText,
    this.labelText,
    this.hintText = 'Masukkan nominal',
    this.enabled = true,
  });

  @override
  ConsumerState<CompactCurrencyInputField> createState() => _CompactCurrencyInputFieldState();
}

class _CompactCurrencyInputFieldState extends ConsumerState<CompactCurrencyInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    if (widget.value != null) {
      _controller.text = widget.value!.toCurrency(ref: ref, withPrefix: false);
    }
  }

  @override
  void didUpdateWidget(CompactCurrencyInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && _controller.text != (widget.value ?? 0).toCurrency(ref: ref, withPrefix: false)) {
      _controller.text = (widget.value ?? 0).toCurrency(ref: ref, withPrefix: false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = ref.watch(currencyNotifierProvider).currencyOption.symbol;

    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        _DynamicCurrencyFormatter(ref: ref),
        LengthLimitingTextInputFormatter(20), // Limit max length
      ],
      decoration: InputDecoration(
        labelText: widget.labelText ?? 'Nominal',
        hintText: widget.hintText,
        prefixText: currencySymbol,
        border: const OutlineInputBorder(),
        errorText: widget.errorText,
      ),
      onChanged: widget.enabled ? (value) {
        final parsed = _DynamicCurrencyFormatter.parseCurrency(value);
        // Jika kosong, kirim 0 agar parent tahu field di-clear
        final valueToSend = parsed ?? 0.0;
        widget.onChanged?.call(valueToSend);
      } : null,
    );
  }
}

/// Provider-aware currency input formatter
/// Formats input based on the selected currency setting
class _DynamicCurrencyFormatter extends TextInputFormatter {
  final WidgetRef ref;

  _DynamicCurrencyFormatter({required this.ref});

  String get _thousandSeparator => ref.read(currencyNotifierProvider).currencyOption.thousandSeparator;

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

    // Hapus karakter non-digit
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
    var formattedValue = _formatNumberWithSeparator(value);

    // Kembalikan dengan proper cursor position
    var selectionEnd = formattedValue.length;
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: selectionEnd),
    );
  }

  String _formatNumberWithSeparator(int value) {
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

  /// Parse formatted string kembali ke double
  static double? parseCurrency(String formatted) {
    var rawValue = formatted.replaceAll(RegExp(r'[^\d]'), '');
    if (rawValue.isEmpty) return null;
    return int.tryParse(rawValue)?.toDouble();
  }
}
