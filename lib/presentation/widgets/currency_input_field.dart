import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base/base.dart';
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
      _controller.text = CurrencyInputFormatter.formatRupiahFromDouble(widget.initialValue!);
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
      _controller.text = CurrencyInputFormatter.formatRupiahFromDouble(widget.initialValue ?? 0);
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
              CurrencyInputFormatter(),
            ],
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            decoration: InputDecoration(
              prefixText: 'Rp ',
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
class CompactCurrencyInputField extends StatefulWidget {
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
  State<CompactCurrencyInputField> createState() => _CompactCurrencyInputFieldState();
}

class _CompactCurrencyInputFieldState extends State<CompactCurrencyInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    if (widget.value != null) {
      _controller.text = CurrencyInputFormatter.formatRupiahFromDouble(widget.value!);
    }
  }

  @override
  void didUpdateWidget(CompactCurrencyInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && _controller.text != CurrencyInputFormatter.formatRupiahFromDouble(widget.value ?? 0)) {
      _controller.text = CurrencyInputFormatter.formatRupiahFromDouble(widget.value ?? 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        CurrencyInputFormatter(),
        LengthLimitingTextInputFormatter(20), // Limit max length
      ],
      decoration: InputDecoration(
        labelText: widget.labelText ?? 'Nominal',
        hintText: widget.hintText,
        prefixText: 'Rp ',
        border: const OutlineInputBorder(),
        errorText: widget.errorText,
      ),
      onChanged: widget.enabled ? (value) {
        final parsed = CurrencyInputFormatter.parseRupiahToDouble(value);
        // Jika kosong, kirim 0 agar parent tahu field di-clear
        final valueToSend = parsed ?? 0.0;
        widget.onChanged?.call(valueToSend);
      } : null,
    );
  }
}
